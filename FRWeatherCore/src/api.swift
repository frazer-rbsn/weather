//
//  api.swift
//  FRWeatherCore
//
//  Created by Frazer on 17/07/2024.
//

import Foundation

// MARK: - Protocol

/**
 Defines an interface for retrieving geocoding data from a remote service.
 */
public protocol GeocodingDataRequesting {

  /**
   Requests a list of places that match the query in `location`.

   - parameter location: A named physical location.
   */
  func geocodedPlaces(for location: String) async -> Result<[GeocodingData.Place], APIError>
}

/**
 Defines an interface for retrieving weather data from a remote service.
 */
public protocol WeatherDataRequesting {

  /**
   Requests current weather data for the given coordinates.

   - parameter latitude: The latitude of the location.
   - parameter longitude: The longitude of the location.
   */
  func currentWeather(latitude: String, longitude: String) async -> Result<WeatherData, APIError>
}

// MARK: - Implementation

/**
 The default implementation of the API for requesting geocoding and weather data.

 In order to use ``geocodedPlaces(for:)``, you must have the `GEOCODING_API_KEY` set in your
 environment.
 */
public class API: GeocodingDataRequesting, WeatherDataRequesting {

  let session: URLSession

  // `URLSession` is injectable so we can add canned mock responses from the API for testing
  public init(session: URLSession = URLSession.shared) {
    self.session = session
  }

  private let geocodingEndpoint = "https://geocode.maps.co/search"
  
  private static let geocodingAPIKeyEnvironmentKey = "GEOCODING_API_KEY"

  private var geocodingAPIKey: String? {
    ProcessInfo.processInfo.environment[Self.geocodingAPIKeyEnvironmentKey]
  }

  // MARK: Geocoding

  public func geocodedPlaces(for location: String) async -> Result<[GeocodingData.Place], APIError> {

    // Check for empty string
    guard !location.replacingOccurrences(of: " ", with: "").isEmpty else {
      return .failure(.emptyQuery)
    }
    
    guard let geocodingAPIKey, !geocodingAPIKey.isEmpty else {
      return .failure(.miscErrorString("\(Self.geocodingAPIKeyEnvironmentKey) environment variable not set. Please generate an API Key from maps.co and set the API key to the \(Self.geocodingAPIKeyEnvironmentKey) in your environment."))
    }

    // Construct request URL
    var url = URL(string: geocodingEndpoint)!
    let queryItems: [URLQueryItem] = [
      .init(name: "q", value: location),
      .init(name: "api_key", value: geocodingAPIKey)
    ]
    url.append(queryItems: queryItems)

    // Make request
    let (data, urlResponse): (Data, URLResponse)
    print("Searching for \(location)...")
    do {
      (data, urlResponse) = try await session.data(from: url)
    } catch {
      return .failure(handleURLSessionError(error))
    }

    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      return .failure(.unexpectedResponseType(type(of: urlResponse)))
    }

    // Status should be OK
    guard httpResponse.statusCode == 200 else {
      return .failure(handleGeocodingError(for: httpResponse))
    }

    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

    do {
      // Try decoding the JSON response to our GeocodingData model
      let places = try jsonDecoder.decode([GeocodingData.Place].self, from: data)
      print("Geocoding data request successful. Found \(places.count) results")
      return .success(places)
    } catch {
      return .failure(.geocodingDataDecodingError(error))
    }
  }

  private func handleGeocodingError(for httpResponse: HTTPURLResponse) -> APIError {
    // TODO:
    // A request within a second of the previous one will cause a response of HTTP 429
    return .miscErrorString("Some error occurred when processing the Geocoding request.")
  }

  // MARK: Weather Data

  private let weatherEndpoint = "https://api.open-meteo.com/v1/forecast"

  private let currentWeatherRequestedParams = 
  """
  temperature_2m,apparent_temperature,precipitation,rain,showers,snowfall,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m
  """

  public func currentWeather(latitude: String, longitude: String) async -> Result<WeatherData, APIError> {

    // Check for empty strings
    guard !latitude.replacingOccurrences(of: " ", with: "").isEmpty,
          !longitude.replacingOccurrences(of: " ", with: "").isEmpty else {
      return .failure(.invalidCoordinates(latitude: latitude, longitude: longitude))
    }

    // Construct request URL
    var url = URL(string: weatherEndpoint)!
    let queryItems: [URLQueryItem] = [
      .init(name: "latitude", value: latitude),
      .init(name: "longitude", value: longitude),
      .init(name: "current", value: currentWeatherRequestedParams), // TODO: Make configurable
      .init(name: "wind_speed_unit", value: "mph") // By default, the wind speed is returned in kph
    ]
    url.append(queryItems: queryItems)

    // Make request
    let (data, urlResponse): (Data, URLResponse)
    print("Retrieving weather data for location lat: \(latitude) long: \(longitude)...")
    do {
      (data, urlResponse) = try await session.data(from: url)
    } catch {
      return .failure(handleURLSessionError(error))
    }

    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      return .failure(.unexpectedResponseType(type(of: urlResponse)))
    }

    // Status should be OK
    guard httpResponse.statusCode == 200 else {
      return .failure(handleWeatherError(for: httpResponse))
    }

    let jsonDecoder = JSONDecoder()
    // We don't set `jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase` here as it can't
    // handle keys with numbers in them. So keys like "temperature_2m" don't get processed.

    do {
      // Try decoding the JSON response to our WeatherData model
      let weatherData = try jsonDecoder.decode(WeatherData.self, from: data)
      print("Successfully retrieved weather data")
      return .success(weatherData)
    } catch {
      return .failure(.weatherDataDecodingError(error))
    }
  }

  private func handleURLSessionError(_ error: Error) -> APIError {
    guard let error = error as? NSError else {
      return .miscError(error)
    }

    switch error.code {
      case NSURLErrorNotConnectedToInternet:
        return .noInternetConnection
      default:
        return .miscError(error)
    }
  }

  private func handleWeatherError(for httpResponse: HTTPURLResponse) -> APIError {
    return .miscErrorString("Some error occurred when processing the Weather request.")
  }
}

public enum APIError: LocalizedError {
  case emptyQuery
  case invalidCoordinates(latitude: String, longitude: String)
  case openMeteoError(string: String)
  case unexpectedResponseType(Any.Type)
  case geocodingDataDecodingError(Error)
  case weatherDataDecodingError(Error)
  case noInternetConnection
  case miscError(Error)
  case miscErrorString(String)

  public var errorDescription: String? {
    switch self {
      case .emptyQuery:
        return "At least one query parameter was empty."
      case let .invalidCoordinates(latitude: latitude, longitude: longitude):
        return "At least one coordinate parameter was invalid. Latitude: '\(latitude)' longitude: '\(longitude)'"
      case .openMeteoError(string: let string):
        return "Error from OpenMeteo: \(string)"
      case .unexpectedResponseType(let type):
        return "Unexpected response type: \(type)"
      case .geocodingDataDecodingError(let error):
        return "Error when decoding data from Geocoding API: \(error)"
      case .weatherDataDecodingError(let error):
        return "Error when decoding data from Weather API: \(error)"
      case .miscError(let error):
        return "Misc error: \(error.localizedDescription)"
      case .miscErrorString(let errorString):
        return "Misc error: \(errorString)"
      case .noInternetConnection:
        return "Please check your internet connection."
    }
  }
}

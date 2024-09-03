//
//  model.swift
//  FRWeatherCore
//
//  Created by Frazer on 17/07/2024.
//

import Foundation

/**
 A model for parsing responses from the Maps.co Geocoding API.
 */
public struct GeocodingData: Decodable, Equatable {

  /**
   A physical location on Earth.
   */
  public struct Place: Codable, Identifiable, Equatable {
    public typealias ID = Int64

    /**
     The unique identifier for this location. Equivalent to `placeId`.
     */
    public var id: ID {
      placeId
    }

    /**
     The unique identifier for this location. Equivalent to `id`.
     */
    public let placeId: Int64

    /**
     The displayed description of this location.
     */
    public let displayName: String

    /**
     The latitude of this location.
     */
    public let lat: String

    /**
     The longitude of this location.
     */
    public let lon: String

    public init(placeId: Int64, displayName: String, lat: String, lon: String) {
      self.placeId = placeId
      self.displayName = displayName
      self.lat = lat
      self.lon = lon
    }
  }
}

/**
 A model for parsing responses from the OpenMeteo API.

 Based on the generated Swift code from https://open-meteo.com/en/docs
 */
public struct WeatherData: Decodable, Equatable {

  /**
   The latitude of this request.
   */
  public let latitude: Float

  /**
   The longitude of this request.
   */
  public let longitude: Float

  /**
   Information about the current weather conditions at a specific location.
   */
  public let current: Current

  /**
   Information about the units used for the data in this request.
   */
  public let currentUnits: CurrentUnits

  public init(latitude: Float, longitude: Float, current: Current, currentUnits: CurrentUnits) {
    self.latitude = latitude
    self.longitude = longitude
    self.current = current
    self.currentUnits = currentUnits
  }

  enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
    case current
    case currentUnits = "current_units"
  }

  /**
   A container model for parsing information about current weather conditions.

   Based on the generated Swift code from https://open-meteo.com/en/docs
   */
  public struct Current: Equatable, Decodable {

    /**
     The air temperature at 2 meters above ground.
     */
    public let temperature: Float

    /**
     The apparent temperature.

     The perceived feels-like temperature combining wind chill factor, relative humidity and solar radiation.
     */
    public let apparentTemperature: Float

    /**
     Total precipitation (rain, showers, snow) sum of the preceding hour.
     */
    public let precipitation: Float

    /**
     Rain from large scale weather systems of the preceding hour.
     */
    public let rain: Float

    /**
     Showers from convective precipitation from the preceding hour.
     */
    public let showers: Float

    /**
     Snowfall amount of the preceding hour
     */
    public let snowfall: Float

    /**
     The percentage of cloud cover as an area fraction.
     */
    public let cloudCover: Float

    /**
     The wind speed at 10 meters above ground.
     */
    public let windSpeed: Float

    /**
     The wind direction at 10 meters above ground.
     */
    public let windDirection: Float

    /**
     The speed of wind gusts at 10 meters above ground.
     */
    public let windGusts: Float

    public init(temperature: Float, apparentTemperature: Float, precipitation: Float, rain: Float, showers: Float, snowfall: Float, cloudCover: Float, windSpeed: Float, windDirection: Float, windGusts: Float) {
      self.temperature = temperature
      self.apparentTemperature = apparentTemperature
      self.precipitation = precipitation
      self.rain = rain
      self.showers = showers
      self.snowfall = snowfall
      self.cloudCover = cloudCover
      self.windSpeed = windSpeed
      self.windDirection = windDirection
      self.windGusts = windGusts
    }

    public init(from decoder: any Decoder) throws {
      let container: KeyedDecodingContainer<WeatherData.Current.CodingKeys> = try decoder.container(keyedBy: WeatherData.Current.CodingKeys.self)
      self.temperature = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.temperature)
      self.apparentTemperature = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.apparentTemperature)
      self.precipitation = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.precipitation)
      self.rain = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.rain)
      self.showers = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.showers)
      self.snowfall = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.snowfall)
      self.cloudCover = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.cloudCover)
      self.windSpeed = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.windSpeed)
      self.windDirection = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.windDirection)
      self.windGusts = try container.decode(Float.self, forKey: WeatherData.Current.CodingKeys.windGusts)
    }

    enum CodingKeys: String, CodingKey {
      case temperature = "temperature_2m"
      case apparentTemperature = "apparent_temperature"
      case precipitation
      case rain
      case showers
      case snowfall
      case cloudCover = "cloud_cover"
      case windSpeed = "wind_speed_10m"
      case windDirection = "wind_direction_10m"
      case windGusts = "wind_gusts_10m"
    }
  }

  /**
   A container model for information about the units used for the current weather data request.
   */
  public struct CurrentUnits: Decodable, Equatable {
    public let temperature: String
    public let apparentTemperature: String
    public let precipitation: String
    public let rain: String
    public let showers: String
    public let snowfall: String
    public let cloudCover: String
    public let windSpeed: String
    public let windDirection: String
    public let windGusts: String

    public init(temperature: String, apparentTemperature: String, precipitation: String, rain: String, showers: String, snowfall: String, cloudCover: String, windSpeed: String, windDirection: String, windGusts: String) {
      self.temperature = temperature
      self.apparentTemperature = apparentTemperature
      self.precipitation = precipitation
      self.rain = rain
      self.showers = showers
      self.snowfall = snowfall
      self.cloudCover = cloudCover
      self.windSpeed = windSpeed
      self.windDirection = windDirection
      self.windGusts = windGusts
    }
    
    enum CodingKeys: String, CodingKey {
      case temperature = "temperature_2m"
      case apparentTemperature = "apparent_temperature"
      case precipitation
      case rain
      case showers
      case snowfall
      case cloudCover = "cloud_cover"
      case windSpeed = "wind_speed_10m"
      case windDirection = "wind_direction_10m"
      case windGusts = "wind_gusts_10m"
    }
  }
}

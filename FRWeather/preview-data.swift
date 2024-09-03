//
//  preview-data.swift
//  FRWeather
//
//  Created by Frazer on 17/07/2024.
//

import Foundation
import FRWeatherCore

/**
 Mock data for use in SwiftUI Previews.
 */
struct PreviewData {
  static let place1 = GeocodingData.Place(
    placeId: 1,
    displayName: "Belfast City Hall, Belfast, County Antrim",
    lat: "50.200",
    lon: "-7.292"
  )

  static let place2 = GeocodingData.Place(
    placeId: 2,
    displayName: "Holywood Exchange, Belfast, County Down",
    lat: "50.201",
    lon: "-7.299"
  )

  static let place3 = GeocodingData.Place(
    placeId: 2,
    displayName: "Really Really Really Really Really Really Really Really Long Name",
    lat: "50.201",
    lon: "-7.299"
  )

  static let places: [GeocodingData.Place] = [
    place1,
    place2
  ]

  static let weatherDataCurrent = WeatherData.Current(
    temperature: 17.3,
    apparentTemperature: 16.7,
    precipitation: 0.3,
    rain: 0.3,
    showers: 0.4,
    snowfall: 0,
    cloudCover: 100,
    windSpeed: 12,
    windDirection: 90,
    windGusts: 20
  )

  static let weatherDataCurrentUnits = WeatherData.CurrentUnits(
    temperature: "°C",
    apparentTemperature: "°C",
    precipitation: "mm",
    rain: "mm",
    showers: "mm",
    snowfall: "cm",
    cloudCover: "%",
    windSpeed: "mp/h",
    windDirection: "°",
    windGusts: "mp/h"
  )

  static let weatherData = WeatherData(
    latitude: 50.2,
    longitude: -6.3,
    current: weatherDataCurrent,
    currentUnits: weatherDataCurrentUnits
  )
}

/**
 Implementation of the API for use in SwiftUI Previews.
 */
final class PreviewDataMockAPI: APIProtocol {

  var failureError: APIError?

  init(shouldFailWithError error: APIError? = nil) {
    self.failureError = error
  }

  func geocodedPlaces(for location: String) async -> Result<[FRWeatherCore.GeocodingData.Place], FRWeatherCore.APIError> {
    if let failureError {
      return .failure(failureError)
    } else {
      return .success(PreviewData.places)
    }
  }

  func currentWeather(latitude: String, longitude: String) async -> Result<FRWeatherCore.WeatherData, FRWeatherCore.APIError> {
    if let failureError {
      return .failure(failureError)
    } else {
      return .success(PreviewData.weatherData)
    }
  }
}

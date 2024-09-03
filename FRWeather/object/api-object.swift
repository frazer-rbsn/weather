//
//  api-object.swift
//  FRWeather
//
//  Created by Frazer on 20/07/2024.
//

import Foundation
import FRWeatherCore

typealias APIProtocol = GeocodingDataRequesting & WeatherDataRequesting

/**
 Allows an instance of an API to be passed around SwiftUI as an environment variable,
 and also contains caching logic for requests.
 */
class APIObject: ObservableObject, APIProtocol {

  private var api: APIProtocol

  /**
   An in-memory cache of weather data to prevent too many requests to the remote weather service.
   */
  private var weatherDataCache: [String: WeatherDataCachedItem] = [:]

  /**
   All reads and writes to ``weatherDataCache`` should go through this queue.
   */
  private let dataCacheAccessQueue = DispatchQueue(label: "FRWeatherApp.dataCacheAccessQueue")

  init(api: APIProtocol) {
    self.api = api
  }

  func geocodedPlaces(for location: String) async -> Result<[GeocodingData.Place], APIError> {
    // Caching not implemented here yet
    await api.geocodedPlaces(for: location)
  }

  func currentWeather(latitude: String, longitude: String) async -> Result<WeatherData, APIError> {
    if let cachedData = validCachedData(latitude: latitude, longitude: longitude) {
      print("Using cached data for weather data request for latitude: \(latitude) longitude: \(longitude)")
      return .success(cachedData)
    } else {
      print("Calling API for new data for weather data request for latitude: \(latitude) longitude: \(longitude)")
      let result = await api.currentWeather(latitude: latitude, longitude: longitude)

      if case let .success(data) = result {
        updateCacheData(latitude: latitude, longitude: longitude, data: data)
      }

      return result
    }
  }

  /**
   - returns: Weather data for this location if it exists in the cache and it is
              less than two minutes old.
   */
  private func validCachedData(latitude: String, longitude: String) -> WeatherData? {
    dataCacheAccessQueue.sync {
      let key = "LAT:\(latitude) LON: \(longitude)"
      // Cached data must be less than two minutes old
      if let cachedData = weatherDataCache[key], Date().timeIntervalSince(cachedData.cacheTime) < 120 {
        return cachedData.data
      } else {
        return nil
      }
    }
  }

  /**
   Updates the cache with the weather data for this location.
   */
  private func updateCacheData(latitude: String, longitude: String, data: WeatherData) {
    dataCacheAccessQueue.sync {
      let key = "LAT:\(latitude) LON: \(longitude)"
      let item = WeatherDataCachedItem(data: data)
      weatherDataCache[key] = item
    }
  }
}

private class WeatherDataCachedItem {
  let data: WeatherData
  let cacheTime: Date

  init(data: WeatherData) {
    self.data = data
    self.cacheTime = Date()
  }
}

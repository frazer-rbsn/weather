//
//  saved-location-object.swift
//  FRWeather
//
//  Created by Frazer on 19/07/2024.
//

import Foundation
import FRWeatherCore

private let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]

private let userDataDir = appSupportDir.appendingPathComponent("UserData")

private let fileUrl = userDataDir.appendingPathComponent("saved_locations.json")

/**
 Stores and publishes state for favourite locations.
 */
final class SavedLocationObject: ObservableObject {

  /**
   An ordered list of user-saved locations.
   */
  @Published var savedLocations: [GeocodingData.Place] {
    didSet {
      persist()
    }
  }

  init() {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

    if FileManager.default.fileExists(atPath: fileUrl.path) {
      do {
        let data = try Data(contentsOf: fileUrl)
        savedLocations = try jsonDecoder.decode([GeocodingData.Place].self, from: data)
      } catch {
        savedLocations = []
        print("Error when trying to load save locations")
        dump(error)
      }
    } else {
      // No saved locations, set as an empty array
      savedLocations = []
    }
  }

  init(placesForPreviews: [GeocodingData.Place]) {
    self.savedLocations = placesForPreviews
  }

  /**
   Writes the list of ``savedLocations`` to disk.
   */
  func persist() {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    jsonEncoder.outputFormatting = [.prettyPrinted]
    do {
      let data = try jsonEncoder.encode(savedLocations)
      try FileManager.default.createDirectory(at: fileUrl.deletingLastPathComponent(),
                                              withIntermediateDirectories: true,
                                              attributes: nil)
      try data.write(to: fileUrl)
    } catch {
      print("Error when trying to persist saved locations")
      dump(error)
    }
  }

  /**
   Reads the list of ``savedLocations`` from disk.
   */
  func toggleMember(place: GeocodingData.Place) {
    if isSaved(placeId: place.placeId) {
      // Is already saved, remove
      savedLocations.removeAll(where: { $0.placeId == place.placeId })
    } else {
      // Add to saved
      savedLocations.append(place)
    }
    persist()
  }

  /**
   - returns: `true` if a location with this ID is a saved location.
   */
  func isSaved(placeId: Int64) -> Bool {
    savedLocations.contains { $0.placeId == placeId }
  }
}

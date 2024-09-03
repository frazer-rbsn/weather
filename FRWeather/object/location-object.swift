//
//  location-object.swift
//  FRWeather
//
//  Created by Frazer on 17/07/2024.
//

import Foundation
import FRWeatherCore
import Combine

/**
 Stores and publishes state for a geocoded location search query.
 */
final class LocationSearchObject: ObservableObject {
  @Published var searchText: String = ""
}

/**
 Stores and publishes state for the results of a geocoded location search query.
 */
class LocationSearchResultsObject: ObservableObject {

  /**
   The search results - a list of locations that match the query. These items should be
   ordered by relevance.
   */
  @Published var places: [GeocodingData.Place] = []

  /**
   If a search query was performed and the server returned no results, this will be set to `true`.
   */
  @Published var noResults: Bool = false

  private var searchObjectCancellable: AnyCancellable?

  /**
   Used for debouncing the keystrokes to the search entry field.
   */
  private let backgroundScheduler = DispatchQueue.global(qos: .userInitiated)

  init(searchObject: LocationSearchObject, api: APIProtocol) {
    searchObjectCancellable = searchObject.$searchText
      .removeDuplicates()
      // The API will reject our request if it is less than a second after the previous one.
      .debounce(for: .milliseconds(1000), scheduler: backgroundScheduler)
      .sink { value in

      } receiveValue: { searchText in
        guard !searchText.isEmpty else { return }

        DispatchQueue.main.async {
          self.noResults = false

          Task {
            let result = await api.geocodedPlaces(for: searchText)

            switch result {
              case let .success(places):
                DispatchQueue.main.async {
                  self.places = places

                  if places.isEmpty {
                    self.noResults = true
                  }
                }
              case let .failure(error):
                print("Error occured when searching for query: '\(searchText)':")
                print(error.errorDescription ?? error.localizedDescription)
            }
          }
        }
      }
  }
}

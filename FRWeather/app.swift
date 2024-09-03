//
//  app.swift
//  FRWeather
//
//  Created by Frazer on 17/07/2024.
//

import SwiftUI
import FRWeatherCore

@main
struct FRWeatherApp: App {
  let api: APIProtocol
  let apiWrapper: APIObject
  let savedLocationsObject: SavedLocationObject

  init() {
    let api = API()
    let apiWrapper = APIObject(api: api)
    self.api = api
    self.apiWrapper = apiWrapper
    self.savedLocationsObject = SavedLocationObject()
  }

  init(api: APIProtocol) {
    let apiWrapper = APIObject(api: api)
    self.api = api
    self.apiWrapper = apiWrapper
    self.savedLocationsObject = SavedLocationObject()
  }

  var body: some Scene {
    WindowGroup {
      SavedLocationsView()
        .environmentObject(apiWrapper)
        .environmentObject(savedLocationsObject)
    }
  }
}

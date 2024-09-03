//
//  location-search-view.swift
//  FRWeather
//
//  Created by Frazer on 17/07/2024.
//

import SwiftUI
import FRWeatherCore

struct LocationSearchView: View {

  @StateObject private var searchObject: LocationSearchObject
  @StateObject private var searchResultsObject: LocationSearchResultsObject

  /**
   If `true`, this view should make the search field first responder automatically upon display.
   */
  @State var autoActivateSearch: Bool

  init(api: APIProtocol, autoActivateSearch: Bool) {
    self._autoActivateSearch = State(initialValue: autoActivateSearch)
    
    let searchObject = LocationSearchObject()
    self._searchObject = StateObject(wrappedValue: searchObject)

    let searchResultsObject = LocationSearchResultsObject(
      searchObject: searchObject,
      api: api
    )
    self._searchResultsObject = StateObject(wrappedValue: searchResultsObject)
  }

  var body: some View {
    NavigationStack {
      if searchResultsObject.places.isEmpty, searchResultsObject.noResults {
        _LocationSearchViewNoResults()
      } else {
        _LocationSearchView(places: $searchResultsObject.places)
      }
    }
    .searchable(text: $searchObject.searchText,
                isPresented: $autoActivateSearch,
                placement: .toolbar,
                prompt: Text("Search for a location"))
  }
}

private struct _LocationSearchView: View {

  @Binding var places: [GeocodingData.Place]

  @EnvironmentObject private var savedLocationObject: SavedLocationObject

  var body: some View {

    List(places) { place in
      Button(action: {
//        withAnimation {
          savedLocationObject.toggleMember(place: place)
//        }
      }, label: {
        LocationRowView(place: place,
                        isSaved: savedLocationObject.isSaved(placeId: place.placeId),
                        showIcon: true)
      })
    }
  }
}

private struct _LocationSearchViewNoResults: View {

  var body: some View {
    ContentUnavailableView("No results",
                           systemImage: "questionmark.circle",
                           description: Text("Please try a different query."))
  }
}

#Preview {
  _LocationSearchView(places: .constant(PreviewData.places))
    .environmentObject(APIObject(api: PreviewDataMockAPI()))
    .environmentObject(SavedLocationObject())
}

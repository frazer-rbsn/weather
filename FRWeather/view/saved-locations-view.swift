//
//  saved-locations-view.swift
//  FRWeather
//
//  Created by Frazer on 19/07/2024.
//

import SwiftUI
import FRWeatherCore

struct SavedLocationsView: View {

  var body: some View {
    VStack {
      _SavedLocationsWeatherView()

      // Buttons for adding/editing locations
      BottomToolbarView()
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }
  }
}

private struct _SavedLocationsWeatherView: View {

  @EnvironmentObject private var savedLocationObject: SavedLocationObject

  var body: some View {
    if savedLocationObject.savedLocations.isEmpty {
      EmptyWeatherGridView()
    } else {
      WeatherPageView()
    }
  }
}

private struct EmptyWeatherGridView: View {

  var body: some View {
    ContentUnavailableView("No saved locations",
                           systemImage: "globe",
                           description: Text("To add a saved location, tap the plus button below."))
  }
}

private struct WeatherPageView: View {

  @EnvironmentObject private var savedLocationObject: SavedLocationObject

  var body: some View {
    TabView {
      ForEach(savedLocationObject.savedLocations) { location in
        WeatherView(place: location)
      }
    }
    .tabViewStyle(.page(indexDisplayMode: .always))
    .indexViewStyle(.page(backgroundDisplayMode: .always))
  }
}

private struct BottomToolbarView: View {

  @State var showAddLocationsView: Bool = false
  @State var showEditLocationsView: Bool = false

  @EnvironmentObject private var apiWrapper: APIObject
  @EnvironmentObject private var savedLocationObject: SavedLocationObject

  var body: some View {
    HStack {
      Button("", systemImage: "plus", action: {
        showAddLocationsView = true
      })
      if savedLocationObject.savedLocations.count > 0 {
        Spacer()
        Button("", systemImage: "list.star", action: {
          showEditLocationsView = true
        })
      }
    }
    .font(.system(size: 24, weight: .black))
    .sheet(isPresented: $showAddLocationsView, content: {
      LocationSearchView(api: apiWrapper, autoActivateSearch: true)
        .padding(.top, 14)
    })
    .sheet(isPresented: $showEditLocationsView, content: {
      EditSavedLocationsView()
        .presentationDetents([.medium, .large])
    })

  }
}

private struct EditSavedLocationsView: View {
  @EnvironmentObject private var savedLocationObject: SavedLocationObject

  @Environment(\.editMode) private var editMode

  var body: some View {
    ZStack(alignment: .bottomTrailing) {

      List($savedLocationObject.savedLocations, editActions: [.all]) { $place in
        LocationRowView(place: place,
                        isSaved: savedLocationObject.isSaved(placeId: place.placeId),
                        showIcon: editMode?.wrappedValue.isEditing == false)
      }

      // Floating edit button
      EditButton()
        .bold()
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .contentShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .shadow(radius: 10)
        .padding(20)
    }
  }
}

#Preview {
  SavedLocationsView()
    .environmentObject(APIObject(api: PreviewDataMockAPI()))
    .environmentObject(SavedLocationObject(placesForPreviews: PreviewData.places))
}

#Preview {
  EditSavedLocationsView()
    .environmentObject(SavedLocationObject(placesForPreviews: PreviewData.places))
}

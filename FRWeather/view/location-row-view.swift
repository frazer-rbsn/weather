//
//  location-row-view.swift
//  FRWeather
//
//  Created by Frazer on 27/07/2024.
//

import Foundation
import SwiftUI
import FRWeatherCore

struct LocationRowView: View {

  let place: GeocodingData.Place
  let isSaved: Bool
  let showIcon: Bool

  var body: some View {
    HStack(spacing: showIcon ? 12 : 0) {

      // Heart/pin icon
      if showIcon {
        Image(systemName: isSaved ? "star.fill" : "mappin.circle")
          .imageScale(.large)
          .fixedSize(horizontal: true, vertical: true)
          .frame(width: 30)
      }

      Text(place.displayName)

      Spacer()
    }
//    .contentTransition(.symbolEffect(.replace))
    .padding(.horizontal, 2)
    .padding(.vertical, 12)
  }
}

#Preview {
  VStack {
    LocationRowView(place: PreviewData.place1, isSaved: false, showIcon: true)
    LocationRowView(place: PreviewData.place2, isSaved: true, showIcon: true)
  }
}

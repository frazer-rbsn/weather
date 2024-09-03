//
//  weather-view.swift
//  FRWeather
//
//  Created by Frazer on 17/07/2024.
//

import SwiftUI
import FRWeatherCore

struct WeatherView: View {

  let place: GeocodingData.Place

  private let locationDisplayName: String

  init(place: GeocodingData.Place) {
    self.place = place

    if let place = place.displayName.split(separator: ",").first {
      self.locationDisplayName = String(place)
    } else {
      self.locationDisplayName = place.displayName
    }
  }

  var body: some View {
    _WeatherView(place: place,
                 locationDisplayName: locationDisplayName)
  }
}

private struct _WeatherView: View {

  /// The location for which weather information is being displayed.
  let place: GeocodingData.Place

  /// A shortened name for display that represents the name of the location.
  let locationDisplayName: String

  /// The weather data to display, if loaded.
  @State var weatherData: WeatherData?

  /// The error that should be displayed to the user, if any.
  @State var displayedError: APIError?

  /// The task ID for the weather data fetch request.
  /// Keeping this id as state allows us to add a .refreshable
  /// modifier whilst keeping the .task modifier as well
  /// see: https://stackoverflow.com/questions/74977787/why-is-async-task-cancelled-in-a-refreshable-modifier-on-a-scrollview-ios-16
  @State private var requestTaskId: UUID = .init()

  @EnvironmentObject private var apiWrapper: APIObject

  var body: some View {
    ScrollView {
      // Error banner
      if let displayedError {
        Text(displayedError.errorDescription ?? displayedError.localizedDescription)
          .padding()
          .background(Color.red.opacity(0.2))
          .clipShape(.rect(cornerRadius: 10.0))
      }

      // Weather information
      WeatherInfoView(locationString: locationDisplayName, weatherData: weatherData)
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
        .task(id: requestTaskId) {
          await getWeatherData()
        }
    }
    .refreshable {
      // Refresh weather data on pull-down
      // Resetting the task ID causes the body of the .task
      // modifier to be called again
      requestTaskId = .init()
    }
  }

  @MainActor
  private func getWeatherData() async {
    self.displayedError = nil

    let result = await apiWrapper.currentWeather(latitude: place.lat,
                                                 longitude: place.lon)
    switch result {
      case let .success(weatherData):
        self.weatherData = weatherData
      case let .failure(error):
        if case .noInternetConnection = error {
          self.displayedError = error
        } else {
          self.displayedError = .miscErrorString("An error occurred. Please try again later.")
        }
        print(error.errorDescription ?? error.localizedDescription)
        self.weatherData = nil
    }
  }
}

private struct WeatherInfoView: View {
  let locationString: String
  let weatherData: WeatherData?

  var body: some View {
    VStack(spacing: 24) {
      // Location
      Text(locationString)
        .font(.system(size: 32, weight: .light, design: .rounded))

      // Temperature
      TemperatureView(weatherData: weatherData)

      VStack(spacing: 18) {
        // Rain
        // Hiding for now because precipitation value is always 0 for some reason
//        RainView(weatherData: weatherData)
        // Cloud
        CloudCoverView(weatherData: weatherData)
        // Wind
        WindView(weatherData: weatherData)
      }
      .padding(32)
    }
  }
}

private struct TemperatureView: View {
  let weatherData: WeatherData?

  var body: some View {
    VStack {
      // Actual air temperature
      HStack(alignment: .top, spacing: 4) {
        Text(tempValue)
          .font(.system(size: 90, weight: .bold, design: .rounded))
        Text(weatherData?.currentUnits.temperature ?? "")
          .font(.system(size: 32, weight: .bold, design: .rounded))
      }
      
      if tempValue != feelsLikeValue {
        // Feels like temperature
        Text(feelsLikeText)
          .font(.system(size: 21, weight: .medium, design: .rounded))
      }
    }
  }

  private var tempValue: String {
    if let weatherData {
      return String(Int(weatherData.current.temperature))
    } else {
      return "--"
    }
  }

  private var feelsLikeValue: String {
    if let weatherData {
      return String(Int(weatherData.current.apparentTemperature))
    } else {
      return ""
    }
  }

  private var feelsLikeText: String {
    if let weatherData {
      return "Feels like \(feelsLikeValue)\(weatherData.currentUnits.apparentTemperature)"
    } else {
      return ""
    }
  }
}

private struct RainView: View {
  let weatherData: WeatherData?

  var body: some View {
    HStack {
      // Rain icon
      Image(systemName: "cloud.rain.fill")
        .imageScale(.large)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.foreground, .blue)
        .font(.system(size: 21, weight: .black))

      // Rain value
      Text(rainValue)
        .font(.system(size: 21, weight: .medium, design: .rounded))
    }
  }

  private var rainValue: String {
    if let weatherData {
      return "\(Int(weatherData.current.precipitation)) \(weatherData.currentUnits.precipitation)"
    } else {
      return "--"
    }
  }
}

private struct CloudCoverView: View {
  let weatherData: WeatherData?

  var body: some View {
    HStack {
      // Cloud icon
      Image(systemName: "cloud")
        .imageScale(.large)
        .font(.system(size: 21))

      // Cloud cover
      Text(cloudCoverValue)
        .font(.system(size: 21, weight: .medium, design: .rounded))
    }
  }

  private var cloudCoverValue: String {
    if let weatherData {
      return "\(Int(weatherData.current.cloudCover)) \(weatherData.currentUnits.cloudCover)"
    } else {
      return "--"
    }
  }
}

private struct WindView: View {
  let weatherData: WeatherData?

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        // Wind icon
        Image(systemName: "wind")
          .imageScale(.large)
          .font(.system(size: 21))

        // Wind speed
        Text(windSpeedValue)
          .font(.system(size: 21, weight: .medium, design: .rounded))

        if weatherData != nil {
          // Wind direction arrow
          Image(systemName: "arrow.down")
            .imageScale(.medium)
            .font(.system(size: 21))
            .bold()
            .rotationEffect(Angle(degrees: windDirectionValue))
        }
      }

      // Wind gusts
      Text(windGustsValue)
        .font(.system(size: 16, weight: .regular, design: .rounded))
    }
  }

  private var windSpeedValue: String {
    if let weatherData {
      return "\(Int(weatherData.current.windSpeed)) \(weatherData.currentUnits.windSpeed)"
    } else {
      return "--"
    }
  }

  private var windDirectionValue: Double {
    if let weatherData {
      return Double(weatherData.current.windDirection)
    } else {
      return 0
    }
  }

  private var windGustsValue: String {
    if let weatherData {
      return "Gusts \(Int(weatherData.current.windGusts)) \(weatherData.currentUnits.windGusts)"
    } else {
      return "--"
    }
  }
}

#Preview("Normal") {
  WeatherView(place: PreviewData.place1)
    .environmentObject(APIObject(api: PreviewDataMockAPI()))
}

#Preview("Long name") {
  WeatherView(place: PreviewData.place3)
    .environmentObject(APIObject(api: PreviewDataMockAPI()))
}

#Preview("Connection problem") {
  WeatherView(place: PreviewData.place1)
    .environmentObject(APIObject(api: PreviewDataMockAPI(shouldFailWithError: .noInternetConnection)))
}

#Preview("Connection problem + no data") {
  _WeatherView(place: PreviewData.place1,
               locationDisplayName: "Somewhere",
               weatherData: nil)
  .environmentObject(APIObject(api: PreviewDataMockAPI(shouldFailWithError: .noInternetConnection)))
}

//
//  ForecastView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/28.
//

import SwiftUI
import WeatherKit

struct ForecastView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateController: AppStateController
    @State private var showingAR = false
    @State private var showingEdit = false

    let locationID: UUID?
    var location: Location? {
        var location: Location?
        if let locationID {
            if appStateController.currentLocation.id == locationID {
                location = appStateController.currentLocation
            } else {
                location = appStateController.location(ofID: locationID)
            }
        } else {
            // do nothing. nil will be returned.
        }
        return location
    }

    // These stings are not translated. English only
    private var stateMessage: String {
        var message = ""
        if let location {
            switch location.weather {
            case .none: message = "no weather forecast data"
            case .error: message = "error occurred"
            case .updating: message = "requesting weather forecast data ..."
            default: message = ""
            }
        }
        return message
    }

    private var markURL: URL? {
        return colorScheme == .light
            ? appStateController.attributionMarkLight
            : appStateController.attributionMarkDark
    }

    private var forecastAvailable: Bool {
        var available = false
        if let location {
            switch location.weather {
            case .weather(_, timestamp: _, location: _):
                available = true
            default: break
            }
        }
        return available
    }

    var body: some View {
        // Warning: without VStack, if-let-else does not work
        VStack {
            if let location {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.clear, Color(location.color), .clear]),
                                   startPoint: .top, endPoint: .trailing)
                    .opacity(0.3)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Color.clear.frame(width: 10, height: 90) // keeps the top space
                            Text("\(location.name)")
                                .font(.title)
                                .fontWeight(.thin)
                                .lineLimit(1)
                            Divider()
                            if case let .weather(forecast, timestamp: timestamp, location: _)
                                = location.weather {
                                HStack {
                                    Spacer()
                                    Image(systemName: "clock")
                                        .accessibilityHidden(true)
                                    Text("forecastView_hourly_forecast", comment: "ForecastView: label")
                                        .fontWeight(.thin)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 6)
                                    Spacer()
                                } // HStack
                                .padding(.top)

                                HourlyForecastView(forecast: hourWeathers(),
                                                   themeColor: Color(location.color))

                                HStack {
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .accessibilityHidden(true)
                                    Text("forecastView_daily_forecast", comment: "ForecastView: label")
                                        .fontWeight(.thin)
                                        .bold()
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 6)
                                    Spacer()
                                }
                                .padding(.top, 8)
//                                .padding()
                                DailyForecastView(dailyForecast: forecast.dailyForecast,
                                                  themeColor: Color(location.color))

                                Text(String("updated at \(timestamp.description)")) // English only
                                    .font(.caption)
                                    .fontWeight(.thin)
                                    .foregroundColor(.secondary)
                                    .padding()

                                if let markURL {
                                    AsyncImage(url: markURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 30)
                                    } placeholder: {
                                        Color.clear
                                    }
                                }
                                if let legalPageURL = appStateController.attributionLegalPage {
                                    Link(String("weather data sources"), // English only
                                         destination: legalPageURL)
                                        .font(.caption)
                                }
                            } else {
                                Text(stateMessage)
                                    .fontWeight(.thin)
                                    .padding()

                                if location.weather == .updating {
                                    Button("btn_cancel_the_forecast_data_request", action: {
                                        if let task = location.task {
                                            task.cancel()
                                            // appStateController.setTask(nil, toID: location.id)
                                        } else {
                                            assertionFailure("invalid: no task to be canceled")
                                            // do nothing in release mode
                                        }
                                    })
                                }
                            } // if case let
                            Color.clear.frame(width: 10, height: 50) // keeps the bottom space
                            Spacer()
                        } // VStack
                    } // ScrollView
                } // ZStack
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button(action: { showingEdit = true }, label: {
                            Image(systemName: "square.and.pencil")
                        })
                        .accessibilityLabel("edit")

                        Button(action: { showingAR = true }, label: {
                            Image(systemName: "arkit")
                        })
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel("display in ar")
                        .disabled(!forecastAvailable)
                    }
                }
            } else {
                VStack {
                    Text("forecastView_select_a_location", comment: "ForecastView: text")
                    // TODO: remove comment
                    // #if DEBUG
                    Button("test AR", action: { showingAR = true })
                        .padding()
                    // #endif
                }
            } // if-else
        } // VStack
        .sheet(isPresented: $showingEdit) {
            // because when showing edit view, the location ID should not be nil
            // use force-unwrapping, `locationID!`
            AddLocationView(appStateController: appStateController,
            isNew: false, locationID: locationID!)
        }
        .fullScreenCover(isPresented: $showingAR) {
            ARWeatherView(name: location?.name ?? "",
                          modelIndex: location?.model ?? 2, // #0: village, #2: town, #3: island
                          hourlyForecast: hourlyForecast())
        }
    } // body

    private func hourlyForecast() -> [HourForecast] {
        var forecasts: [HourForecast] = []
        let hourWeathers = hourWeathers()
        if !hourWeathers.isEmpty {
            forecasts = hourWeathers.map { hourWeather in
                HourForecast.make(from: hourWeather)
            }
        } else {
            // do nothing in release mode because this won't happen

            // TODO: remove comment
            // #if DEBUG
            forecasts = SampleForecast.sampleHourlyForecasts
            // #endif
        }
        return forecasts
    }

    private func hourWeathers() -> [HourWeather] {
        var weathers: [HourWeather] = []
        if let location,
           case .weather(let weather, timestamp: _, location: _) = location.weather {
            let recentForecast = weather.hourlyForecast.filter {
                let interval = $0.date.timeIntervalSinceNow
                return (interval >= 0) && (interval < 24 * 60 * 60) // [seconds] range
            }
            for index in 0 ..< recentForecast.count where index % AppConstant.hourlyForecastIntervalHours == 0 {
                // [hours] interval
                weathers.append(recentForecast[index])
            }
        }
        return weathers
    }
}

struct ForecastView_Previews: PreviewProvider {
    static let appStateController = AppStateController()
    static var previews: some View {
        ForecastView(appStateController: appStateController,
                     locationID: appStateController.locations[0].id)
    }
}

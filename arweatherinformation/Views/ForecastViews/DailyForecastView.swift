//
//  DailyForecastView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/07.
//

import SwiftUI
import WeatherKit

struct DailyForecastView: View {
    let dailyForecast: Forecast<DayWeather>
    let themeColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0 ..< dailyForecast.count, id: \.self) { index in
                    DailyForecastColumnView(forecast: dailyForecast[index],
                                            themeColor: themeColor)
                } // ForEach
            } // HStack
        } // ScrollView
    } // body
}

struct DailyForecastColumnView: View {
    let forecast: DayWeather
    let themeColor: Color

    private var abbreviatedDate: String {
        forecast.date.formatted(date: .abbreviated, // Oct 17, 2020
                                time: .omitted)
    }
    private var weekday: String {
        forecast.date.formatted(date: .complete, // Saturday, October 17, 2020
                                time: .omitted)
        .components(separatedBy: ",")
        .first ?? ""  // Saturday
    }

    private func forecastColor(_ chance: Double) -> Color {
        if chance == 0 { return Color("SunnyBGColor") }
        let bright = 1.0 - chance
        let color = Color(uiColor: UIColor(red: bright, green: bright, blue: bright, alpha: 1))
        return color
    }

    var body: some View {
        VStack {
            // symbolName
            VStack {
                Image(systemName: forecast.symbolName)
                    .font(.system(size: 40))
                Text(weekday)
//                Text(forecast.date.formatted(date: .abbreviated,
//                                             time: .omitted))
            }
            .background(in: Circle().inset(by: -20))
            .backgroundStyle(forecastColor(forecast.precipitationChance).gradient)
            .backgroundStyle(.white)
            .frame(height: 60)
//            .padding(20)
            .offset(x: 0, y: 30)

            VStack(alignment: .leading) {
                Group {
                    // <temperature high-low>
                    HStack {
                        Spacer()
                        Text(String(format: "%3.0f", forecast.highTemperature.value) + "°")
                        Text(" - ")
                        Text(String(format: "%3.0f", forecast.lowTemperature.value) + "°")
                        Spacer()
                    } // HStack
                    .font(.title)
                    .padding(.top, 24)
//                    .padding(.top, 8)

                    HStack {
                        Spacer()
                        Text(forecast.precipitationChance.formatted(.percent))
                            .font(.title)
                            .foregroundColor(Color.blue) // Color("RainTextColor"))
                        Spacer()
                    } // HStack
                } // Group

                // date
                Text(abbreviatedDate)
//                Text(forecast.date.formatted(date: .complete, // .abbreviated,
//                                             time: .omitted))
                .padding(8)

                // <condition>
                Text(forecast.condition.description)
                    .fontWeight(.thin)
                    .padding(.vertical, 4)

                Group {
                    // <high temperature>
                    HStack {
                        Image(systemName: "thermometer.high")
                        Text(forecast.highTemperature.description)
                    }
                    // <low temperature>
                    HStack {
                        Image(systemName: "thermometer.low")
                        Text(forecast.lowTemperature.description)
                    }
                    // <precipitation> : description of precipitation for this day
                    //    // <precipitation chance 0 to 1>
                    //    HStack {
                    //        Image(systemName: "cloud.rain")
                    //        Text(forecast.precipitationChance.formatted(.percent)) // %
                    //            .foregroundColor(Color("RainTextColor"))
                    //    }
                }

                Group {
                    // <rainfall amount>
                    HStack {
                        Image(systemName: "cloud.rain")
                            .foregroundColor(Color.blue)
                        Text(forecast.rainfallAmount.description)
                            // .foregroundColor(Color.blue) // Color("RainTextColor"))
                    }
                    // <snowfall amount>
                    HStack {
                        Image(systemName: "snowflake")
                            .foregroundColor(Color.white)
                        Text(forecast.snowfallAmount.description)
                            // .foregroundColor(Color.white) // Color("RainTextColor"))
                    }
                    // <wind>
                    HStack {
                        Image(systemName: "wind")
                        Text(forecast.wind.speed.description)
                    }
                    // <UVIndex>
                    HStack {
                        Image(systemName: "sun.dust")
                        Text(forecast.uvIndex.category.description)
                        Text(forecast.uvIndex.value.description)
                    }
                    // <moon>
                    // <sun>
                }
            } // VStack
            .fontWeight(.thin)
            .padding(16)
            .background(LinearGradient(gradient:
                                        Gradient(colors: [forecastColor(forecast.precipitationChance),
                                                          themeColor]),
                                       startPoint: .top,
                                       endPoint: .trailing)
                .opacity(0.5).cornerRadius(20))
            .padding(4)
        } // VStack
        .accessibilityElement(children: .combine)
    } // body
}

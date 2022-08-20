//
//  HourlyForecastView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/07.
//

import SwiftUI
import WeatherKit

struct HourlyForecastView: View {
    let forecast: [HourWeather]
    let themeColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(0 ..< forecast.count, id: \.self) { index in
                    HourlyForecastColumnView(forecast: forecast[index],
                                             themeColor: themeColor)
                } // ForEach
            } // HStack
        } // ScrollView
    } // body
}

struct HourlyForecastColumnView: View {
    let forecast: HourWeather
    let themeColor: Color

    private func forecastColor(_ chance: Double) -> Color {
        if chance == 0 { return Color("SunnyBGColor") }
        let bright = 0.5 - chance / 2
        let color = Color(uiColor: UIColor(red: bright, green: bright, blue: bright, alpha: 1))
        return color
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                VStack {
                    // <time>
                    Text(forecast.date.formatted(date: .omitted,
                                                 time: .shortened))
                    .fontWeight(.bold)
                    // <date>
                    Text(forecast.date.formatted(date: .abbreviated, time: .omitted))
                }
                Spacer()
            }
            .padding(.bottom, 12)

            // Symbol
            HStack {
                Spacer()
                Image(systemName: forecast.symbolName)
                    .font(.system(size: 40))
                Spacer()

            }
            .background(in: Circle().inset(by: -20))
            .backgroundStyle(forecastColor(forecast.precipitationChance).gradient)
            .backgroundStyle(.white)
            .frame(height: 60)

            Group {
                HStack {
                    Spacer()
                    // <Temperature>
                    Text(String(format: "%3.0f", forecast.temperature.value) + "°")
                        .font(.title)
                        .accessibilityLabel(forecast.temperature.description)
                    Spacer()
                } // HStack
                .padding(.top, 12)

                HStack {
                    Spacer()
                    // <Precipitation> [%]
                    Text(forecast.precipitationChance.formatted(.percent)) // %
                        .font(.title)
                        .foregroundColor(Color.cyan) // Color("RainTextColor"))
                    Spacer()
                } // HStack
            } // Group

            //    // <date>
            //    Text(forecast.date.formatted(date: .abbreviated, time: .omitted))
            //    .padding(8)

            // <condition>
            HStack {
                Spacer()
                Text(forecast.condition.description)
                    .fontWeight(.thin)

                Spacer()
            }
            .padding(.bottom, 4)

            Group {
                // <apparent temperature>
                // <temperature>
                // HStack {
                //    Image(systemName: "thermometer.medium")
                //    Text(forecast.temperature.description)
                // }
                //   Text(measureFormatter.string(from: forecast[index].temperature))
                // <humidity 0 to 1>
                HStack {
                    Image(systemName: "humidity.fill")
                        .foregroundColor(.cyan)
                        .frame(width: 30)
                    Text(forecast.humidity.formatted(.percent)) // %
                }
                // <dewPoint>
                // <pressure>
                // <pressureTrend>
                // <cloudCover>
                // <isDaylight>
                // <visibility>
                // <precipitation>
                //    HStack {
                //        Image(systemName: "cloud.rain")
                //        Text(forecast.precipitation.description)
                //    }
                // <precipitationAmount>
                HStack {
                    Image(systemName: "cloud.rain.fill")
                        .foregroundColor(.cyan)
                        .frame(width: 30)
                    Text(forecast.precipitationAmount.description)
                        // .foregroundColor(Color.blue) // Color("RainTextColor"))
                }
                // <wind>
                HStack {
                    Image(systemName: "wind")
                        .frame(width: 30)
                    Text(forecast.wind.speed.description)
                }
                // <uvIndex>
                HStack {
                    Image(systemName: "sun.dust.fill")
                        .frame(width: 30)
                        .foregroundColor(.yellow)
                    Text(forecast.uvIndex.category.description)
                    Text(forecast.uvIndex.value.description)
                } // HStack
            } // Group
        } // VStack
        .fontWeight(.thin)
        .padding(16)
        //    .background(LinearGradient(gradient: Gradient(colors: [forecastColor(forecast.precipitationChance),
        //                                                           themeColor]),
        //                               startPoint: .top,
        //                               endPoint: .trailing)
        //        .opacity(0.5).cornerRadius(20))
        .background(Color(forecast.isDaylight ? "HourlyForecastDaytime" : "HourlyForecastNight").cornerRadius(20))
        .foregroundColor(.white)
        .padding(4)
        .accessibilityElement(children: .combine)
    } // body
}

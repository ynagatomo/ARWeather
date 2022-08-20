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
        let bright = 0.5 - chance / 2
        let color = Color(uiColor: UIColor(red: bright, green: bright, blue: bright, alpha: 1))
        return color
    }

    var body: some View {
//        ZStack {
            VStack(alignment: .leading) {
                Text(weekday)
                    .padding(.vertical, 16)

                // symbolName
                HStack {
                    Spacer()
                    Image(systemName: forecast.symbolName)
                        .font(.system(size: 40))
                    Spacer()
                    // Text(weekday)
                }
                .background(in: Circle().inset(by: -20))
                .backgroundStyle(forecastColor(forecast.precipitationChance).gradient)
                .backgroundStyle(.white)
                .frame(height: 60)
    //            .padding(20)
//                .offset(x: 0, y: 30)

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

                    // <precipitation chance>
                    HStack {
                        Spacer()
                        Text(forecast.precipitationChance.formatted(.percent))
                            .font(.title)
                            .foregroundColor(Color.cyan) // Color("RainTextColor"))
                        Spacer()
                    } // HStack
                } // Group

                // date
                // Text(abbreviatedDate)
                // .padding(8)

                // <condition>
                HStack {
                    Spacer()
                    Text(forecast.condition.description)
                        .fontWeight(.thin)
                    Spacer()
                }
                .padding(.vertical, 4)

                //    Group {
                //        // <high temperature>
                //        Label(forecast.highTemperature.description,
                //              systemImage: "thermometer.high")
                // //                    HStack {
                // //                        Image(systemName: "thermometer.high")
                // //                        Text(forecast.highTemperature.description)
                // //                    }
                //        // <low temperature>
                //        Label(forecast.lowTemperature.description,
                //              systemImage: "thermometer.low")
                // //                    HStack {
                // //                        Image(systemName: "thermometer.low")
                // //                        Text(forecast.lowTemperature.description)
                // //                    }
                //        // <precipitation> : description of precipitation for this day
                //        //    // <precipitation chance 0 to 1>
                //        //    HStack {
                //        //        Image(systemName: "cloud.rain")
                //        //        Text(forecast.precipitationChance.formatted(.percent)) // %
                //        //            .foregroundColor(Color("RainTextColor"))
                //        //    }
                //    }

                Group {
                    // <rainfall amount>
//                    Label(forecast.rainfallAmount.description,
//                          systemImage: "cloud.rain")
                    HStack {
                        Image(systemName: "cloud.rain.fill")
                            .foregroundColor(Color.cyan)
                            .frame(width: 30)
                        Text(forecast.rainfallAmount.description)
                            // .foregroundColor(Color.blue) // Color("RainTextColor"))
                    }
                    // <snowfall amount>
//                    Label(forecast.snowfallAmount.description,
//                          systemImage: "snowflake")
                    HStack {
                        Image(systemName: "snowflake")
                            .foregroundColor(Color.white)
                            .frame(width: 30)
                        Text(forecast.snowfallAmount.description)
                            // .foregroundColor(Color.white) // Color("RainTextColor"))
                    }
                    // <wind>
//                    Label(forecast.wind.speed.description,
//                          systemImage: "wind")
                    HStack {
                        Image(systemName: "wind")
                            .frame(width: 30)
                        Text(forecast.wind.speed.description)
                    }
                    // <UVIndex>
//                    Label(forecast.uvIndex.category.description + forecast.uvIndex.value.description,
//                          systemImage: "sun.dust")
                    HStack {
                        Image(systemName: "sun.dust.fill")
                            .frame(width: 30)
                            .foregroundColor(.yellow)
                        Text(forecast.uvIndex.category.description)
                        Text(forecast.uvIndex.value.description)
                    }
                    // <moon>
                    // <sun>
                    // Sunrise
                    if let sunrise = forecast.sun.sunrise {
//                        Label(sunrise.formatted(date: .omitted,
//                                                time: .shortened),
//                              systemImage: "sunrise")
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .frame(width: 30)
                                .foregroundColor(.yellow)
                            Text(sunrise.formatted(date: .omitted,
                                                   time: .shortened))
                        }
                    }
                    // Sunset
                    if let sunrise = forecast.sun.sunset {
                        HStack {
//                            Label(sunrise.formatted(date: .omitted,
//                                                    time: .shortened),
//                                  systemImage: "sunset")
                            Image(systemName: "sunset.fill")
                                .frame(width: 30)
                                .foregroundColor(.orange)
                            Text(sunrise.formatted(date: .omitted,
                                                   time: .shortened))
                        }
                    }
                }
            } // VStack
            .fontWeight(.thin)
            .padding(16)
//            .background(LinearGradient(gradient:
//                                        Gradient(colors: [forecastColor(forecast.precipitationChance),
//                                                          themeColor]),
//                                       startPoint: .top,
//                                       endPoint: .trailing)
//                .opacity(0.5).cornerRadius(20))
            .background(Color("ForecastBGColor").cornerRadius(20))
            .foregroundColor(.white)
            .padding(4)
//        } // ZStack
        .accessibilityElement(children: .combine)
    } // body
}

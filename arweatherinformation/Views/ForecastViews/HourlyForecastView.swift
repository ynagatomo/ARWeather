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
//    let hourlyForecast: Forecast<HourWeather>
    let themeColor: Color

//    var forecast: [HourWeather] {
//        let recentForecast = hourlyForecast.filter {
//            let interval = $0.date.timeIntervalSinceNow
//            return (interval >= 0) && (interval < 24 * 60 * 60) // [seconds] range
//        }
//        var intervalForecast: [HourWeather] = []
//        for index in 0 ..< recentForecast.count where index % AppConstant.hourlyForecastIntervalHours == 0 {
//            // [hours] interval
//                intervalForecast.append(recentForecast[index])
//        }
//        return intervalForecast
//    }

//    let measureFormatter: MeasurementFormatter = {
//        let numFormatter = NumberFormatter()
//        numFormatter.maximumFractionDigits = 1
//        let measureFormatter = MeasurementFormatter()
//        measureFormatter.numberFormatter = numFormatter
//        return measureFormatter
//    }()

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

//    struct HourlyForecastView_Previews: PreviewProvider {
//        static let forecast = Forecast<HourWeather>()
//        static var previews: some View {
//            HourlyForecastView(hourlyForecast: forecast)
//        }
//    }

struct HourlyForecastColumnView: View {
    let forecast: HourWeather
    let themeColor: Color

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
                Text(forecast.date.formatted(date: .omitted,
                                             time: .shortened))
            }
            .background(in: Circle().inset(by: -20))
            .backgroundStyle(forecastColor(forecast.precipitationChance).gradient)
            .backgroundStyle(.white)
            .frame(height: 60)
            .padding(20)
            .offset(x: 0, y: 30)

//            // symbolName
//            RoundedRectangle(cornerRadius: 20)
//                .frame(width: 80, height: 60)
//                .foregroundColor(forecastColor(forecast.precipitationChance))
//                .overlay {
//                    Image(systemName: forecast.symbolName) // symbols don't have color
//                        .font(.system(size: 40))
//                }
//                .offset(x: 0, y: 30)

            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Spacer()
                        // <Temperature>
                        Text(String(format: "%3.0f", forecast.temperature.value))
                            .font(.title)
                            .accessibilityLabel(forecast.temperature.description)
//                            .foregroundColor(.gray)
                        Spacer()
                    } // HStack
                    .padding(.top, 8)

                    HStack {
                        Spacer()
//                        // <PrecipitationAmount>
//                        Text(forecast.precipitationAmount.description)
//                            .font(.title2)
//                            .foregroundColor(.blue)
                        // <Precipitation> [%]
                        Text(forecast.precipitationChance.formatted(.percent)) // %
                            .font(.title2)
                            .foregroundColor(Color("RainTextColor"))
                        Spacer()
                    } // HStack
                } // Group

//                Group {
//                    // <time>
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(height: 40)
//                        .foregroundColor(
//                            forecast.isDaylight
//                            ? Color("DaylightBGColor")
//                            : Color("NightBGColor"))
//                        .overlay {
//                            Text(forecast.date.formatted(date: .omitted,
//                                                         time: .shortened))
//                            .foregroundColor(.white)
//                        }
                    // <date>
                    Text(forecast.date.formatted(date: .abbreviated, time: .omitted))
                    .padding(8)
//                } // Group

                // <condition>
                Text(forecast.condition.description)
                    .fontWeight(.thin)
//                    .bold()
                    .padding(.vertical, 4)

                Group {
                    // <apparent temperature>
                    // <temperature>
                    HStack {
                        Image(systemName: "thermometer.medium")
                        Text(forecast.temperature.description)
                    }
                    //   Text(measureFormatter.string(from: forecast[index].temperature))
                    // <humidity 0 to 1>
                    HStack {
                        Image(systemName: "humidity")
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
                        Image(systemName: "cloud.rain")
                        Text(forecast.precipitationAmount.description)
                            .foregroundColor(Color("RainTextColor"))
                    }
//                    // <precipitationChance 0 to 1>
//                    HStack {
//                        Image(systemName: "cloud.rain")
//                        Text(forecast.precipitationChance.formatted(.percent)) // %
//                        //               .foregroundColor(.blue)
//                    }
                    // <wind>
                    HStack {
                        Image(systemName: "wind")
                        Text(forecast.wind.speed.description)
                    }
                    // <uvIndex>
                    HStack {
                        Image(systemName: "sun.dust")
                        Text(forecast.uvIndex.category.description)
                        Text(forecast.uvIndex.value.description)
                    } // HStack
                } // Group
            } // VStack
            .fontWeight(.thin)
            .padding(16)
            .background(LinearGradient(gradient: Gradient(colors: [forecastColor(forecast.precipitationChance),
                                                                   themeColor]),
                                       startPoint: .top,
                                       endPoint: .trailing)
                .opacity(0.5).cornerRadius(20))
            .padding(4)
        } // VStack
        .accessibilityElement(children: .combine)
    } // body
}

//
//  HourlySample.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/07.
//
#if DEBUG
import SwiftUI

struct HourlySample: View {
    let forecast: [HourSampleWeather]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(0 ..< forecast.count, id: \.self) { index in
                    HourlySampleColumnView(forecast: forecast[index])
                } // ForEach
            } // HStack
        } // ScrollView
    } // body
}

struct HourlySample_Previews: PreviewProvider {
    static let forecast: [HourSampleWeather] = [
        HourSampleWeather(), HourSampleWeather(), HourSampleWeather(),
        HourSampleWeather(), HourSampleWeather(), HourSampleWeather(),
        HourSampleWeather(), HourSampleWeather()
    ]
    static var previews: some View {
        HourlySample(forecast: forecast)
    }
}

struct HourSampleWeather {
    struct Condition { let description = "condition" }
    struct Temperature { let description = "23.56 °C"; let value: Double = 23.56 }
    struct Wind { let speed = Speed() }
    struct Speed { let description = "1.2 km/h" }
    struct UvIndex { let category = Category(); let value = Value() }
    struct Category { let description = "Hard" }
    struct Value { let description = "5" }
    let date: Date = Date()
    let isDaylight: Bool = true
    let condition = Condition()
    let precipitationChance: Double = 0.5
    let symbolName = "cloud"
    let temperature = Temperature()
    let humidity: Double = 0.5
    let wind = Wind()
    let uvIndex = UvIndex()
}

struct HourlySampleColumnView: View {
    let forecast: HourSampleWeather

//    private func gray(_ chance: Double) -> Color {
//        let bright = 1.0 - chance
//        return Color(uiColor: UIColor(red: bright, green: bright, blue: bright, alpha: 1))
//    }
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
                    .fontWeight(.thin)
//                    .font(.callout)
                }
                .background(in: Circle().inset(by: -20))
                .backgroundStyle(forecastColor(forecast.precipitationChance).gradient)
                .backgroundStyle(.white)
                .frame(height: 60)
                .padding(20)
                .offset(x: 0, y: 30)

//                // symbolName
//                RoundedRectangle(cornerRadius: 20)
//                    .frame(width: 80, height: 60)
//                    .foregroundColor(
//                        forecast.precipitationChance == 0
//                        ? Color("SunnyBGColor")
//                        : gray(forecast.precipitationChance))
//                    .overlay {
//                        Image(systemName: forecast.symbolName) // symbols don't have color
//                            .font(.system(size: 40))
//                    }
//                    .offset(x: 0, y: 30)
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(String(format: "%3.0f", forecast.temperature.value))
                            .font(.title)
                            .foregroundColor(.gray)
//                            .bold()
                        Spacer()
                    }
                    .padding(.top, 8)

                    HStack {
                        Spacer()
                        Text(forecast.precipitationChance.formatted(.percent)) // %
                            .font(.title3)
                            .foregroundColor(Color.blue) // Color("RainTextColor"))
//                            .bold()
                        Spacer()
                    }

                    // time
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                        .foregroundColor(
                            forecast.isDaylight
                            ? Color("DaylightBGColor")
                            : Color("NightBGColor"))
                        .overlay {
                            Text(forecast.date.formatted(date: .omitted,
                                                         time: .shortened))
                            .foregroundColor(.white)
                        }
                    // date
                    Text(forecast.date.formatted(date: .abbreviated, time: .omitted))

                    // condition
                    Text(forecast.condition.description).bold()
                        .padding(.vertical, 4)
                    //                // symbolName
                    //                RoundedRectangle(cornerRadius: 20)
                    //                    .frame(height: 60)
                    //                    .foregroundColor(
                    //                        forecast.precipitationChance == 0
                    //                        ? Color("SunnyBGColor")
                    //                        : gray(forecast.precipitationChance))
                    //                    .overlay {
                    //                        Image(systemName: forecast.symbolName) // symbols don't have color
                    //                            .font(.system(size: 40))
                    //                    }

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
                    Group {
                        // <precipitationChange 0 to 1>
                        HStack {
                            Image(systemName: "cloud.rain")
                            Text(forecast.precipitationChance.formatted(.percent)) // %
                        }
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
                        }
                    } // Group
                } // VStack
                .fontWeight(.thin)
                .padding(16)
//                .background(Color.blue.opacity(0.5).cornerRadius(20))
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .blue]),
                                           startPoint: .top, endPoint: .trailing)
                    .opacity(0.5).cornerRadius(20))

//                .padding(.top, 60) // symbol space
                .padding(4)
            } // VStack

    } // body
}
#endif

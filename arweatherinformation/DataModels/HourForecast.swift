//
//  HourForecast.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/12.
//

import Foundation
import WeatherKit

struct HourForecast {
    enum Condition {
        case fine, rain, snow
    }
    // Date
    let dateDescription: String
    let isDaylight: Bool
    // Condition
    let condition: Condition
    let conditionDescription: String
    // Temperature
    let temperature: Double
    let temperatureDescription: String
    // Cloud cover
    let cloudCover: Double
    // Precipitation
    let precipitationChance: Double
    let precipitationChanceDescription: String
    let precipitationAmount: Double
    let precipitationAmountDescription: String
    // Wind
    let windSpeed: Double
    let windSpeedDescription: String
    let windDirection: Double
    let windDirectionDescription: String
    //    // Humidity
    //    let humidity: Double
    //    let humidityDescription: String
    //    // UV Index
    //    let uvIndexCategoryDescription: String
    //    let uvIndexValue: Int

    static func make(from hourWeather: HourWeather) -> Self {
        var condition: Condition
        switch hourWeather.precipitation {
        case .none: condition = .fine
        case .rain, .sleet: condition = .rain
        case .hail, .snow, .mixed: condition = .snow
        default: condition = .fine
        }

        // let windSpeed = hourWeather.wind.speed.converted(to: .metersPerSecond) // [m/s]

        return HourForecast(
            dateDescription: hourWeather.date.formatted(date: .omitted,
                                                        time: .shortened),
            isDaylight: hourWeather.isDaylight,
            condition: condition,
            conditionDescription: hourWeather.condition.description,
            temperature: hourWeather.temperature.value,
            temperatureDescription: hourWeather.temperature.description,
            cloudCover: hourWeather.cloudCover,
            precipitationChance: hourWeather.precipitationChance,
            precipitationChanceDescription: hourWeather.precipitationChance.formatted(.percent),
            precipitationAmount: hourWeather.precipitationAmount.value,
            precipitationAmountDescription: hourWeather.precipitationAmount.description,
            windSpeed: hourWeather.wind.speed.value, // [km/h]
            // windSpeed: windSpeed.value, // [m/s]
            windSpeedDescription: hourWeather.wind.speed.description, // [km/h]
            // windSpeedDescription: windSpeed.description,
            windDirection: hourWeather.wind.direction.value, // [degrees]
            windDirectionDescription: hourWeather.wind.direction.description
            //     humidity: hourWeather.humidity,
            //     humidityDescription: hourWeather.humidity.description,
            //     uvIndexCategoryDescription: hourWeather.uvIndex.category.description,
            //     uvIndexValue: hourWeather.uvIndex.value
        )
    }
}

// TODO: remove comment
// #if DEBUG
struct SampleForecast {
    static let sampleHourlyForecasts: [HourForecast] = [
        HourForecast(dateDescription: "8:00", // #0
                     isDaylight: true,
                     condition: .fine,
                     conditionDescription: "clear",
                     temperature: 10.23,
                     temperatureDescription: "10.23 °C",
                     cloudCover: 0.1,
                     precipitationChance: 0.0,
                     precipitationChanceDescription: "0%",
                     precipitationAmount: 0,
                     precipitationAmountDescription: "0 mm",
                     windSpeed: 0,
                     windSpeedDescription: "0 km/h",
                     windDirection: 0,
                     windDirectionDescription: "0.0 °"),
        HourForecast(dateDescription: "11:00", // #1
                     isDaylight: true,
                     condition: .fine,
                     conditionDescription: "clear",
                     temperature: 18.23,
                     temperatureDescription: "18.23 °C",
                     cloudCover: 0.2,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 10,
                     precipitationAmountDescription: "10 mm",
                     windSpeed: 20,
                     windSpeedDescription: "20 km/h",
                     windDirection: 45,
                     windDirectionDescription: "45.0 °"),
        HourForecast(dateDescription: "14:00", // #2
                     isDaylight: true,
                     condition: .rain,
                     conditionDescription: "rainly",
                     temperature: 8.23,
                     temperatureDescription: "8.23 °C",
                     cloudCover: 0.5,
                     precipitationChance: 0.61,
                     precipitationChanceDescription: "61%",
                     precipitationAmount: 20,
                     precipitationAmountDescription: "20 mm",
                     windSpeed: 20,
                     windSpeedDescription: "20 km/h",
                     windDirection: 90,
                     windDirectionDescription: "90.0 °"),
        HourForecast(dateDescription: "17:00", // #3
                     isDaylight: true,
                     condition: .snow,
                     conditionDescription: "snow",
                     temperature: -1.25,
                     temperatureDescription: "-1.25 °C",
                     cloudCover: 0.7,
                     precipitationChance: 0.55,
                     precipitationChanceDescription: "55%",
                     precipitationAmount: 20,
                     precipitationAmountDescription: "20 mm",
                     windSpeed: 30,
                     windSpeedDescription: "30 km/h",
                     windDirection: 135,
                     windDirectionDescription: "135.0 °"),
        HourForecast(dateDescription: "20:00", // #4
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 2.23,
                     temperatureDescription: "2.23 °C",
                     cloudCover: 0.9,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 10,
                     precipitationAmountDescription: "10 mm",
                     windSpeed: 80,
                     windSpeedDescription: "80 km/h",
                     windDirection: 180,
                     windDirectionDescription: "180.0 °"),
        HourForecast(dateDescription: "23:00", // #5
                     isDaylight: false,
                     condition: .rain,
                     conditionDescription: "rainy",
                     temperature: 3.23,
                     temperatureDescription: "3.23 °C",
                     cloudCover: 1.0,
                     precipitationChance: 0.88,
                     precipitationChanceDescription: "88%",
                     precipitationAmount: 50,
                     precipitationAmountDescription: "50 mm",
                     windSpeed: 100,
                     windSpeedDescription: "100 km/h",
                     windDirection: 225,
                     windDirectionDescription: "225.0 °"),
        HourForecast(dateDescription: "2:00", // #6
                     isDaylight: false,
                     condition: .snow,
                     conditionDescription: "snowy",
                     temperature: 0.23,
                     temperatureDescription: "0.23 °C",
                     cloudCover: 0.5,
                     precipitationChance: 0.78,
                     precipitationChanceDescription: "78%",
                     precipitationAmount: 50,
                     precipitationAmountDescription: "50 mm",
                     windSpeed: 50,
                     windSpeedDescription: "50 km/h",
                     windDirection: 270,
                     windDirectionDescription: "270.0 °"),
        HourForecast(dateDescription: "5:00", // #7
                     isDaylight: true,
                     condition: .fine,
                     conditionDescription: "clear",
                     temperature: 5.23,
                     temperatureDescription: "5.23 °C",
                     cloudCover: 0.3,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 10.0,
                     precipitationAmountDescription: "10.0 mm",
                     windSpeed: 100,
                     windSpeedDescription: "100 km/h",
                     windDirection: 300,
                     windDirectionDescription: "300.0 °")
    ]
}
// #endif

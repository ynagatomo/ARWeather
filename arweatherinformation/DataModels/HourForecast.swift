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

#if DEBUG
struct SampleForecast {
    static let sampleHourlyForecasts: [HourForecast] = [
        HourForecast(dateDescription: "8:00", // "July 11, 2022 22:00",
                     isDaylight: true,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.1,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 10,
                     precipitationAmountDescription: "10 mm",
                     windSpeed: 0,
                     windSpeedDescription: "0 km/h",
                     windDirection: 0,
                     windDirectionDescription: "0.0 °"),
        HourForecast(dateDescription: "11:00", // "July 11, 2022 22:00",
                     isDaylight: true,
                     condition: .rain,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.2,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 20,
                     precipitationAmountDescription: "20 mm",
                     windSpeed: 10,
                     windSpeedDescription: "10 km/h",
                     windDirection: 45,
                     windDirectionDescription: "45.0 °"),
        HourForecast(dateDescription: "14:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.3,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 30,
                     precipitationAmountDescription: "30 mm",
                     windSpeed: 30,
                     windSpeedDescription: "30 km/h",
                     windDirection: 90,
                     windDirectionDescription: "90.0 °"),
        HourForecast(dateDescription: "17:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .rain,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.4,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 40,
                     precipitationAmountDescription: "40 mm",
                     windSpeed: 40,
                     windSpeedDescription: "40 km/h",
                     windDirection: 135,
                     windDirectionDescription: "135.0 °"),
        HourForecast(dateDescription: "20:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.5,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 50,
                     precipitationAmountDescription: "50 mm",
                     windSpeed: 50,
                     windSpeedDescription: "50 km/h",
                     windDirection: 180,
                     windDirectionDescription: "180.0 °"),
        HourForecast(dateDescription: "23:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.6,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 100,
                     precipitationAmountDescription: "100 mm",
                     windSpeed: 60,
                     windSpeedDescription: "60 km/h",
                     windDirection: 225,
                     windDirectionDescription: "225.0 °"),
        HourForecast(dateDescription: "2:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 0.7,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 200,
                     precipitationAmountDescription: "200 mm",
                     windSpeed: 100,
                     windSpeedDescription: "100 km/h",
                     windDirection: 270,
                     windDirectionDescription: "270.0 °"),
        HourForecast(dateDescription: "5:00", // "July 11, 2022 22:00",
                     isDaylight: false,
                     condition: .fine,
                     conditionDescription: "cloudy",
                     temperature: 20.23,
                     temperatureDescription: "20.23 °C",
                     cloudCover: 1.0,
                     precipitationChance: 0.18,
                     precipitationChanceDescription: "18%",
                     precipitationAmount: 1.23,
                     precipitationAmountDescription: "1.23 mm",
                     windSpeed: 200,
                     windSpeedDescription: "200 km/h",
                     windDirection: 315,
                     windDirectionDescription: "315.0 °")
    ]
}
#endif

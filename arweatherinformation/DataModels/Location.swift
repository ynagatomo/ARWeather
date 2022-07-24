//
//  Location.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import UIKit
import CoreLocation
import WeatherKit

struct Geolocation: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
}

struct ColorRGB: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

enum WeatherState: Equatable {
    case none
    case updating
    case error(WeatherError)
    case weather(Weather, timestamp: Date, location: Geolocation)

    var description: String {
        var string = ""
        switch self {
        case .none: string = "none"
        case .updating: string = "updating"
        case .weather(let weather, timestamp: _, location: _): string
            = "daily weather count = \(weather.dailyForecast.count)"
        case .error(let error): string = error.localizedDescription
        }
        return string
    }
}

struct Location: Codable, Identifiable {
    let id: UUID
    let favorite: Bool
    let name: String
    let note: String
    let color: UIColor
    let symbol: Int      // location symbol index
    let model: Int      // 3d model index (not used, reserved)
    let isHere: Bool    // true: current location
    let geolocation: Geolocation?   // registered location
    let weather: WeatherState
    let task: Task<Void, Never>?

    var location: CLLocation? {
        var location: CLLocation?
        if let geolocation {
            location = CLLocation(latitude: geolocation.latitude, longitude: geolocation.longitude)
        }
        return location
    }

    private enum CodingKeys: String, CodingKey {
        case id, favorite, name, note, color, symbol, model, isHere, geolocation
        // do not add weather because it is not coded
    }

    init(id: UUID, favorite: Bool, name: String, note: String, color: UIColor, symbol: Int,
         model: Int, isHere: Bool, geolocation: Geolocation?, weather: WeatherState, task: Task<Void, Never>?) {
        self.id = id
        self.favorite = favorite
        self.name = name
        self.note = note
        self.color = color
        self.symbol = symbol
        self.model = model
        self.isHere = isHere
        self.geolocation = geolocation
        self.weather = weather
        self.task = task
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        name = try container.decode(String.self, forKey: .name)
        note = try container.decode(String.self, forKey: .note)
        let colorRGB = try container.decode(ColorRGB.self, forKey: .color)
        color = UIColor(red: colorRGB.red, green: colorRGB.green, blue: colorRGB.blue, alpha: colorRGB.alpha)
        symbol = try container.decode(Int.self, forKey: .symbol)
        model = try container.decode(Int.self, forKey: .model)
        isHere = try container.decode(Bool.self, forKey: .isHere)
        geolocation = try container.decode(Geolocation?.self, forKey: .geolocation)
        weather = .none
        task = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(name, forKey: .name)
        try container.encode(note, forKey: .note)

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let colorRGB = ColorRGB(red: red, green: green, blue: blue, alpha: alpha)
        try container.encode(colorRGB, forKey: .color)

        try container.encode(symbol, forKey: .symbol)
        try container.encode(model, forKey: .model)
        try container.encode(isHere, forKey: .isHere)
        try container.encode(geolocation, forKey: .geolocation)
        // do not encode weather property
        // do not encode the task
    }
}

extension Location: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Location {
    func updateName(_ name: String) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: name,
                        note: self.note,
                        color: self.color,
                        symbol: self.symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: self.weather,
                        task: self.task
        )
    }

    func updateNote(_ note: String) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: self.name,
                        note: note,
                        color: self.color,
                        symbol: self.symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: self.weather,
                        task: self.task
        )
    }

    func updateSymbol(_ symbol: Int) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: self.name,
                        note: self.note,
                        color: self.color,
                        symbol: symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: self.weather,
                        task: self.task
        )
    }

    func updateGeolocation(_ geolocation: Geolocation?) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: self.name,
                        note: self.note,
                        color: self.color,
                        symbol: self.symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: geolocation,
                        weather: self.weather,
                        task: self.task
        )
    }

    func updateWeather(_ weather: WeatherState) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: self.name,
                        note: self.note,
                        color: self.color,
                        symbol: self.symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: weather,
                        task: self.task
        )
    }

    func updateTask(_ task: Task<Void, Never>?) -> Self {
        return Location(id: self.id,
                        favorite: self.favorite,
                        name: self.name,
                        note: self.note,
                        color: self.color,
                        symbol: self.symbol,
                        model: self.model,
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: self.weather,
                        task: task
        )
    }

    func updated(favorite: Bool, name: String, note: String, color: UIColor, symbol: Int) -> Self {
        return Location(id: self.id,
                        favorite: favorite,
                        name: name,
                        note: note,
                        color: color,
                        symbol: symbol,
                        model: self.model, // model is not modified for now
                        isHere: self.isHere,
                        geolocation: self.geolocation,
                        weather: self.weather,
                        task: self.task
        )
    }
}

//
//  AppConstant.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import Foundation

struct AppConstant {
    private init() {}

    // Keys of UserDefaults

    static let currentLocationStoreKey = "current" // a key of UserDefaults
    static let locationsStoreKey = "locations" // a key of UserDefaults

    static let onboardingDisplayed = "onboardingDisplayed" // @AppStorage
    static let weatherAPICallCount = "weatherAPICallCount" // @AppStorage
    static let startedCount = "startedCount" // @AppStorage
    static let displayingARGGuidance = "displayingARGGuidance" // @AppStorage
    static let soundEnable = "soundEnable" // @AppStorage
//    static let autoStopARPlaying = "autoStopARPlaying" // @AppStorage

    // Attributes

    static let twitterName = "@weatherarapp"

    // Default Locations

    static let defaultCurrentLocation = Location(id: UUID(),
                                                 favorite: false,
                                                 name: "Here",
                                                 note: "current location",
                                                 color: .gray,
                                                 symbol: 0, // location
                                                 model: 0,  // model index
                                                 isHere: true,
                                                 geolocation: nil,
                                                 weather: .none,
                                                 task: nil)
    static let defaultLocations = [
        Location(id: UUID(),
                 favorite: false,
                 name: "Yosemite Park",
                 note: "An American national park in California.",
                 color: .green,
                 symbol: 5,
                 model: 0,
                 isHere: false,
                 geolocation: Geolocation(latitude: 37.89092,
                                          longitude: -119.54016,
                                          altitude: 1200),
                 weather: .none,
                 task: nil),
        Location(id: UUID(),
                 favorite: false,
                 name: "Yakushima",
                 note: "An island in Japan. It's on the World Natural Heritage List.",
                 color: .blue,
                 symbol: 5,
                 model: 0,
                 isHere: false,
                 geolocation: Geolocation(latitude: 30.42965,
                                          longitude: 130.56806,
                                          altitude: 10),
                 weather: .none,
                 task: nil)
    ]

    // location symbols
    // Warning: The index number of locationSymbols is saved in UserDefaults.
    //          Do not change existing strings. Adding new strings is ok.
    static let locationSymbols: [String] = [
        "location", "house", "building.2", "leaf", "water.waves", "photo",
        "figure.run", "figure.outdoor.cycle", "sparkles", "globe"
    ]

    // maximum location count to be registered
    static let maximulLocationRegistrationCount: Int = 20

    // Weather services

    static let weatherDataExpireSeconds: Double = 3 * 60 * 60 // [seconds]
    static let weatherDataDistanceLimit: Double = 3_000 // [meters]

    // Weather forecast UI

    static let hourlyForecastIntervalHours: Int = 3 // [hours]

    // AR

    // static let arWorldOrigin = SIMD3<Float>(0, 0, -0.3) // [m]
}

//
//  AppConstant.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import Foundation
import UIKit

struct AppConstant {
    private init() {}

    // Keys of UserDefaults

    static let currentLocationStoreKey = "current" // a key of UserDefaults
    static let locationsStoreKey = "locations" // a key of UserDefaults

    static let onboardingDisplayed = "onboardingDisplayed" // @AppStorage
    static let weatherAPICallCount = "weatherAPICallCount" // @AppStorage
    static let startedCount = "startedCount" // @AppStorage, a count for showing AppReview
    static let displayingARGGuidance = "displayingARGGuidance" // @AppStorage
    static let soundEnable = "soundEnable" // @AppStorage

    // URLs

    // App Review URL: English only
    static let reviewURLString = "https://apps.apple.com/app/id1636107272?action=write-review"
    // Twitter URL: English only
    static let twitterURLString = "https://twitter.com/weatherarapp"
    // Support URL: localized
    static let supportURLString = NSLocalizedString("https://www.atarayosd.com/weather/app.html",
                          comment: "Support Web URL")
    // Developer URL: localized
    static let developerURLString = NSLocalizedString("https://www.atarayosd.com/developer.html",
                          comment: "Developer Web URL")

    // Attributes

    static let twitterName = "@weatherarapp"

    // Default Locations

    static let defaultCurrentLocation = Location(id: UUID(),
                                                 favorite: false,
                                                 name: "Here",
                                                 note: "current location",
                                                 color: .gray,
                                                 symbol: 0, // location
                                                 model: 2,  // town
                                                 isHere: true,
                                                 geolocation: nil,
                                                 weather: .none,
                                                 task: nil)
    static let defaultLocations = [
        Location(id: UUID(),
                 favorite: false,
                 name: "Yosemite Park",
                 note: "An American national park in California.",
                 color: UIColor(red: 0.010, green: 0.490, blue: 0.003, alpha: 1),
                 symbol: 5,
                 model: 1, // field
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
                 color: UIColor(red: 0.016, green: 0.171, blue: 0.752, alpha: 1),
                 symbol: 10,
                 model: 0, // village
                 isHere: false,
                 geolocation: Geolocation(latitude: 30.42965,
                                          longitude: 130.56806,
                                          altitude: 10), // ?
                 weather: .none,
                 task: nil),
        Location(id: UUID(),
                 favorite: false,
                 name: "Macquarie Island",
                 note: "An island in the southwestern Pacific Ocean.",
                 color: UIColor(red: 0.115, green: 0.315, blue: 0.662, alpha: 1),
                 symbol: 10,
                 model: 1, // field
                 isHere: false,
                 geolocation: Geolocation(latitude: -54.583333,
                                          longitude: 158.883333,
                                          altitude: 10), // ?
                 weather: .none,
                 task: nil),
        Location(id: UUID(),
                 favorite: false,
                 name: "Nordaustlandet",
                 note: "An island in the archipelago of Svalbard, Norway",
                 color: UIColor(red: 0.084, green: 0.339, blue: 0.596, alpha: 1),
                 symbol: 10,
                 model: 1, // field
                 isHere: false,
                 geolocation: Geolocation(latitude: 79.8,
                                          longitude: 22.4,
                                          altitude: 28), // about
                 weather: .none,
                 task: nil),
        Location(id: UUID(),
                 favorite: false,
                 name: "Showa-kichi",
                 note: "An observation base on East Ongul Island in Antarctica.",
                 color: UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1),
                 symbol: 10,
                 model: 1, // field
                 isHere: false,
                 geolocation: Geolocation(latitude: -69.006958,
                                          longitude: 39.583744,
                                          altitude: 65), // about
                 weather: .none,
                 task: nil)
    ]

    // location symbols
    // Warning: The index number of locationSymbols is saved in UserDefaults.
    //          Do not change existing strings. Adding new strings is ok.
    static let locationSymbols: [String] = [
        "location",             // #0
        "house",                // #1
        "building.2",           // #2
        "leaf",                 // #3
        "water.waves",          // #4
        "photo",                // #5
        "figure.run",           // #6
        "figure.outdoor.cycle", // #7
        "sparkles",             // #8
        "globe",                // #9
        "circle"                // #10
    ]

    // maximum location count to be registered
    static let maximulLocationRegistrationCount: Int = 20

    // Weather services

    static let weatherDataExpireSeconds: Double = 3 * 60 * 60 // [seconds]
    static let weatherDataDistanceLimit: Double = 3_000 // [meters]

    // Weather forecast UI

    static let hourlyForecastIntervalHours: Int = 3 // [hours]
}

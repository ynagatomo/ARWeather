//
//  DevConfiguration.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

#if DEBUG
import Foundation

struct DevConstant {
    private init() {}

    static let weatherDataExpireSeconds: [Double] = [5, 60] // [sec]
    static let showingARDebugOptions = false
    static let perspectiveCameraPosition = SIMD3<Float>(0, 0.1, 0.5) // for Simulator

    static let weatherServiceDelaySeconds: UInt64 = 5 // [seconds]
    static let isWeatherServiceDelay = false
    static let isThrowingWeatherError = false
}

final class DevConfiguration {
    static let share = DevConfiguration()
    private init() {}

    var weatherDataExpireSeconds = DevConstant.weatherDataExpireSeconds[0]
    var weatherDataExpireSecondsIndex = 0
    var isWeatherServiceDelay = DevConstant.isWeatherServiceDelay
    var isThrowingWeatherError = DevConstant.isThrowingWeatherError

    var showingARDebugOptions = DevConstant.showingARDebugOptions
}
#endif

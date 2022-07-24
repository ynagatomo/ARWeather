//
//  AppStateController.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import CoreLocation
import WeatherKit
import SwiftUI

@MainActor
final class AppStateController: ObservableObject {
    @AppStorage(AppConstant.weatherAPICallCount) var weatherAPICallCount = 0

    @Published var attributionLegalPage: URL?
    @Published var attributionMarkDark: URL?
    @Published var attributionMarkLight: URL?
    @Published var currentLocation: Location = AppConstant.defaultCurrentLocation
    @Published var locations: [Location] = AppConstant.defaultLocations

    // Location
    enum LocationUpdatingState: Int { case idle = 0, updating }
    private var locationUpdatingState = LocationUpdatingState.idle
    private let locationManager: LocationManager

    // Weather Services
    let weatherService: WeatherService

    init() {
        locationManager = LocationManager()

        // We can use for creating different WeatherService class instances for optimization.
        // But the shared one is used throughout the app because some specific optimizations
        // are not needed so far.
        weatherService = WeatherService.shared
    }

    func addLocation(_ location: Location) {
        locations.insert(location, at: 0)
    }

    func removeLocation(at index: Int) {
        locations.remove(at: index)
    }

    func replaceLocation(ofID locationID: UUID, with newLocation: Location) {
        if locationID == currentLocation.id {
            assert(newLocation.isHere == true)
            assert(newLocation.geolocation == nil)
            currentLocation = newLocation
        } else {
            if let registeredLocationIndex = locationIndex(ofID: locationID) {
                locations[registeredLocationIndex] = newLocation
            } else {
                assertionFailure("error. illegal location ID \(locationID)")
                // do nothing in release mode
            }
        }
    }

    func location(ofID: UUID) -> Location? {
        var location: Location?
        if ofID == currentLocation.id {
            location = currentLocation
        } else {
            location = locations.first(where: { $0.id == ofID })
        }
        return location
    }

    func isCurrentLocation(ofID: UUID) -> Bool {
        return ofID == currentLocation.id
    }

    func locationIndex(ofID: UUID) -> Int? {
        return locations.firstIndex(where: { $0.id == ofID })
    }

    // This function is used to set task nil or to set task the specific Task.
    // task: nil -> a task ... set a task
    //       a task -> nil ... clear the task
    //       a task -> a task ... invalid (this should not happen)
    func setTask(_ task: Task<Void, Never>?, toID locationID: UUID) {
        if let location = location(ofID: locationID) {
            assert(!(task != nil && location.task != nil))
            let newLocation = location.updateTask(task)
            replaceLocation(ofID: locationID, with: newLocation)
            debugLog("DEBUG: the new task (or nil) was stored into the location.task.")
        } else {
            assertionFailure("failed to find the location of ID \(locationID).")
            // do nothing in release mode
        }
    }
}

extension AppStateController {
    func storeLocations() {
        let encoder = JSONEncoder()

        // store the current-location data
        if let encodedData = try? encoder.encode(currentLocation) {
            UserDefaults.standard.set(encodedData, forKey: AppConstant.currentLocationStoreKey)
        } else {
            assertionFailure("error. failed to save current location data into UserDefaults.")
            // do nothing in release mode because this won't happen
        }
        debugLog("AppState: correntLocation was stored into UserDefaults.")

        // store the locations data
        if let encodedData = try? encoder.encode(locations) {
            UserDefaults.standard.set(encodedData, forKey: AppConstant.locationsStoreKey)
        } else {
            assertionFailure("error. failed to save locations data into UserDefaults.")
            // do nothing in release mode because this won't happen
        }
        debugLog("AppState: locations (\(locations.count)) was stored into UserDefaults.")
    }

    func loadLocations() {
        debugLog("AppState: loadLocations() was called.")
        let decoder = JSONDecoder()
        // load the current-location data
        if let savedData = UserDefaults.standard.data(forKey: AppConstant.currentLocationStoreKey) {
            if let decodedData = try? decoder.decode(Location.self, from: savedData) {
                currentLocation = decodedData
                debugLog("AppState: The current-location was loaded from the UserDefaults.")
            } else {
                assertionFailure("error. failed to load locations data from UserDefaults.")
                // do nothing in release mode because this won't happen
            }
        } else {
            debugLog("AppState: No current-location in the UserDefaults.")
            // no data in the UserDefaults
            // do nothing
        }

        if let savedData = UserDefaults.standard.data(forKey: AppConstant.locationsStoreKey) {
            if let decodedData = try? decoder.decode([Location].self, from: savedData) {
                locations = decodedData // restore the saved data
                debugLog("AppState: The locations was loaded from the UserDefaults.")
            } else {
                assertionFailure("error. failed to load locations data from UserDefaults.")
                // do nothing in release mode because this won't happen
            }
        } else {
            debugLog("AppState: No locations in the UserDefaults.")
            // no data in the UserDefaults
            // do nothing. Default locations will be used.
        }
    }
}

#if DEBUG
extension AppStateController {
    func doSomething() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(locations[0]) {
            debugLog(String(bytes: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let location = try decoder.decode(Location.self, from: data)
                debugLog("decoded data = \(location)")
            } catch {
                debugLog(error)
            }
        }
    }

    func locationServiceSupported() -> Bool {
        return locationManager.locationServiceSupported
    }

    func locationServicesAuthorized() -> Bool {
        return locationManager.locationServicesAuthorized
    }
}
#endif

// MARK: - Location

extension AppStateController {
    func requestAuthorization() {
        locationManager.requestAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func currentDeviceLocation() -> DeviceLocation? {
        return locationManager.currentLocation
    }
}

// MARK: - WeatherKit

extension AppStateController {
    func getAttribution() async {
        do {
            let attribution = try await weatherService.attribution
            attributionLegalPage = attribution.legalPageURL
            attributionMarkLight = attribution.combinedMarkLightURL
            attributionMarkDark = attribution.combinedMarkDarkURL
            debugLog("WK: The attribution was gotten.")
            debugLog("WK:  - legal page = \(String(describing: attributionLegalPage))")
            debugLog("WK:  - mark light = \(String(describing: attributionMarkLight))")
            debugLog("WK:  - mark dark = \(String(describing: attributionMarkDark))")
        } catch {
            debugLog("WK: failed to get the attribution.")
            // do nothing in release mode
        }
    }

    // swiftlint:disable function_body_length
    func checkWeather(for locationID: UUID) async {
        guard let location = location(ofID: locationID) else {
            assertionFailure("WK: failed to find the Location of id \(locationID)")
            return
        }

        var cllocation: CLLocation
        if location.isHere { // Current location
            if let deviceLocation = currentDeviceLocation() {
                cllocation = deviceLocation.cllocation
            } else {
                // clear the weather data because the current location was not gotten
                updateLocation(ofID: locationID, with: .none)
                debugLog("WK: The location is unknown.")
                return
            }
        } else { // Registered location
            if location.location != nil {
                cllocation = location.location!
            } else {
                // clear the weather data because the location of the registered location is nil
                updateLocation(ofID: locationID, with: .none)
                debugLog("WK: The location is unknown.")
                return
            }
        }

        debugLog("WK: The weather forecast will be checked in \(cllocation)")

        switch location.weather {
        case .updating:
            // do nothing, because it is updating now
            debugLog("WK: The weather forecast is already updating now.")
        case .weather(_, let timestamp, let geolocation):
            let now = Date()
            #if DEBUG
            let expireSeconds = DevConfiguration.share.weatherDataExpireSeconds
            #else
            let expireSeconds = AppConstant.weatherDataExpireSeconds
            #endif
            if now.timeIntervalSince(timestamp) < expireSeconds { // [seconds]
                // not expired (= available)
                if !location.isHere {
                    // The current weather data is available for registered place.
                    // keep using it. So just return.
                    return
                } else { // Here
                    // check the distance from weather data's location to current location
                    let distance = cllocation.distance(from: CLLocation(latitude: geolocation.latitude,
                                                       longitude: geolocation.longitude))
                    if distance < AppConstant.weatherDataDistanceLimit { // [meters]
                        // The current weather data is not expired and its location is near here.
                        // Keep using it. So just return.
                        return
                    } else {
                        // The distance is far. need to update the data.
                        // do nothing here
                    }
                }
            } else {
                // the weather data was expired for Here or Registered Locations need to update
                // do nothing here
            }

            // update the weather data
            await updateWeather(ofID: locationID, for: cllocation)

        case .none, .error:
            await updateWeather(ofID: locationID, for: cllocation)
            debugLog("WK: The weather forecast has been updated.")
        }
    }

    private func updateWeather(ofID locationID: UUID, for cllocation: CLLocation) async {
        do {
            updateLocation(ofID: locationID, with: .updating)
            #if DEBUG
            if DevConfiguration.share.isWeatherServiceDelay {
                try await Task.sleep(nanoseconds: DevConstant.weatherServiceDelaySeconds * 1_000_000_000)
            }
            if DevConfiguration.share.isThrowingWeatherError {
                throw WeatherError.unknown
            }
            #endif
            let weather = try await weatherService.weather(for: cllocation)
            let weatherState = WeatherState.weather(weather,
                                         timestamp: Date(),
                                         location: Geolocation(latitude: cllocation.coordinate.latitude,
                                                               longitude: cllocation.coordinate.longitude,
                                                               altitude: cllocation.altitude))
            updateLocation(ofID: locationID, with: weatherState)
            weatherAPICallCount += 1
        } catch let error as WeatherError {
            debugLog("WK: WeatherError: weather(for:) reported an error: \(error.localizedDescription)")
            updateLocation(ofID: locationID, with: .error(error))
        } catch let error as CancellationError {
            debugLog("WK: CancellationError: weather(for:) reported an error: \(error.localizedDescription)")
            updateLocation(ofID: locationID, with: .none)
        } catch {
            debugLog("WK: Error: weather(for:) reported an error: \(error.localizedDescription)")
            let error = WeatherError.unknown
            updateLocation(ofID: locationID, with: .error(error))
        }
    }

    private func updateLocation(ofID locationID: UUID, with weatherState: WeatherState) {
        if locationID == currentLocation.id { // Current Location
            currentLocation = currentLocation.updateWeather(weatherState)
        } else { // Registered Locations
            if let index = locations.firstIndex(where: { $0.id == locationID }) {
                locations[index] = locations[index].updateWeather(weatherState)
            } else {
                // When the location of the ID is not found, just do nothing.
                // For example, during loading the weather data, the location can be deleted by a user.
                debugLog("WK: It's ok but any Location was found with the id: \(locationID)")
            }
        }
    }
}

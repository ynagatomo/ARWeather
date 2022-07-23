//
//  AppStateController.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

// swiftlint:disable file_length
import CoreLocation
import WeatherKit
import SwiftUI

struct DeviceLocation {
    // Geographical coordinate information

    // Positive values indicate latitudes north of the equator.
    // Negative values indicate latitudes south of the equator.
    let latitude: Double // [degrees]
    // Measurements are relative to the zero meridian,
    // with positive values extending east of the meridian
    // and negative values extending west of the meridian.
    let longitude: Double // [degrees]

    // The altitude above mean sea level associated with a location
    // When verticalAccuracy contains 0 or a negative number,
    // the value of altitude is invalid.
    // The value of altitude is valid when verticalAccuracy contains
    // a postive number.
    let altitude: Double // [meters]

    // The radius of uncertainty for the location.
    // The location’s latitude and longitude identify the center of the circle,
    // and this value indicates the radius of that circle.
    // A negative value indicates that the latitude and longitude are invalid.
    let horizontalAccuracy: Double // [meters]

    // The validity of the altitude values, and their estimated uncertainty.
    // A positive verticalAccuracy value represents the estimated uncertainty
    // associated with altitude and ellipsoidalAltitude.
    // This value is available whenever altitude values are available.
    // If verticalAccuracy is 0 or a negative number, altitude and
    // ellipsoidalAltitude values are invalid.
    // If verticalAccuracy is a positive number, altitude and ellipsoidalAltitude
    // values are valid.
    // A positive verticalAccuracy value represents an uncertainty that’s
    // approximately 68 percent, or one standard deviation, above and below the
    // altitude values.
    let verticalAccuracy: Double // [meters]

    // The time at which this location was determined.
    let timestamp: Date

    var cllocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

//    static let zero = Self(latitude: 0, longitude: 0, altitude: 0, floor: nil,
//                           horizontalAccuracy: 10, verticalAccuracy: 10,
//                           timestamp: Date())
}

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
//   private let locationManager: CLLocationManager
//    let locationServiceSupported: Bool
//    @Published var locationServicesAuthorized = false
    private var locationUpdatingState = LocationUpdatingState.idle
//    private var deviceLocation: DeviceLocation?
    private let locationManager: LocationManager

    // Weather Services
    let weatherService: WeatherService

    init() {
//        locationManager = CLLocationManager()
//        // Check if the device supports the Significant-Change Location Service
//        locationServiceSupported = CLLocationManager.significantLocationChangeMonitoringAvailable()

        locationManager = LocationManager()

        // We can use for creating different WeatherService class instances for optimization.
        // But the shared one is used throughout the app because some specific optimizations
        // are not needed so far.
        weatherService = WeatherService.shared
//        super.init()
//        locationManager.delegate = self
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

// extension AppStateController {
//    func clearDeviceLocation() {
//        deviceLocation = nil
//    }
// }

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

//    func deviceLocation() async -> DeviceLocation? {
//        guard locationUpdatingState == .idle else { return nil }
//        locationUpdatingState = .updating
//        let currentLocation = await locationManager.currentLocation()
//        locationUpdatingState = .idle
//        return currentLocation
//    }
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
//            if let deviceLocation = await locationManager.currentLocation() {
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

//    // MARK: - LocationManager
//
//    extension AppStateController {
//        // Request the location service authorization for When In Use
//        //
//        // [Note] You must call this method or requestAlwaysAuthorization()
//        //     before you can receive location-related information.
//        //     You may call requestWhenInUseAuthorization() whenever the current
//        //     authorization status is not determined (CLAuthorizationStatus.notDetermined).
//        // [Note] This method runs asynchronously and prompts the user to grant permission
//        //     to the app to use location services. The user prompt contains the text from
//        //     the NSLocationWhenInUseUsageDescription key in your app Info.plist file,
//        //     and the presence of that key is required when calling this method.
//        func requestAuthorization() {
//            debugLog("requestAuthorization for When In Use was called.")
//            if locationServiceSupported {
//                locationManager.requestWhenInUseAuthorization()
//            }
//        }
//
//        // Start the location services
//        func startUpdatingLocation() {
//            debugLog("startUpdatingLocation() was called.")
//            // assert(updatingLocationState == .stop)
//            guard updatingLocationState == .stop else { return }
//            clearDeviceLocation()
//
//            // If the Significant-change location services is not supported, do nothing.
//            guard locationServiceSupported else { return }
//
//            // The Significant-change Location Service ignores the accuracy and distance filter.
//
//            // [Note] For iOS, the default value of this property is kCLLocationAccuracyBest.
//            // assert(locationManager.desiredAccuracy == kCLLocationAccuracyBest)
//
//            // [Note] The default value (Double [m]) of this property is
//            //        kCLDistanceFilterNone.
//            //
//            // assert(locationManager.distanceFilter == kCLDistanceFilterNone)
//            //    locationManager.distanceFilter = AppSettings.share.distanceFilter // [m]
//
//            // [Note] On supported platforms the default value of this property is true
//            // assert(locationManager.pausesLocationUpdatesAutomatically == true)
//
//            // [Note]
//            //    The default value of this property is CLActivityType.other.
//            //    fitness: The location manager is being used to track fitness activities
//            //    such as walking, running, cycling, and so on.
//            //    when the value of activityType is CLActivityType.fitness,
//            //    indoor positioning is disabled.
//            // locationManager.activityType = .fitness
//
//            // [Note]
//            //    With this service, the location manager ignores the values in its
//            //    distanceFilter and desiredAccuracy properties, so you don't need
//            //    to configure them.
//            updatingLocationState = .updating
//            locationManager.startMonitoringSignificantLocationChanges()
//        }
//
//        // Stop the location services
//        func stopUpdatingLocation() {
//            debugLog("stopUpdatingLocation() was called.")
//            if updatingLocationState == .updating {
//                updatingLocationState = .stop
//                locationManager.stopMonitoringSignificantLocationChanges()
//                clearDeviceLocation()
//            }
//        }
//    }
//
//    // MARK: - CLLocationManager Delegate
//
//    extension AppStateController: CLLocationManagerDelegate {
//        // [Note] If the user’s choice doesn’t change the authorization status
//        //     after you call the requestWhenInUseAuthorization() or requestAlwaysAuthorization()
//        //     method, the location manager doesn’t report the current authorization status to
//        //     this method—the location manager only reports changes.
//        //
//        // [Note] An app's authorization status changes in response to users’ actions.
//        //     Users can change permission for apps to use location information at any time.
//        //     The user can:
//        //     - Change an app’s location authorization in Settings > Privacy > Location Services,
//        //       or in Settings > (the app) > Location Services.
//        //     - Turn location services on or off globally in Settings > Privacy > Location Services.
//        //     - Choose Reset Location & Privacy in Settings > General > Reset.
//        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//            // Tells the delegate when the app creates the location manager
//            // and when the authorization status changes.
//            debugLog("locationManagerDidChangeAuthorization(_:) was called.")
//
//            var authorized = false
//            switch manager.authorizationStatus {
//            case .notDetermined,
//                 // The user has not chosen whether the app can use location services
//                 .restricted,
//                 // The app is not authorized to use location services
//                 .denied:
//                 // The user denied the use of location services for the app or they
//                 // are disabled globally in Settings.
//                authorized = false
//            case .authorizedAlways,
//                // The user authorized the app to start location services at any time
//                 .authorizedWhenInUse:
//                // The user authorized the app to start location services while it is in use
//                authorized = true
//            @unknown default:
//                fatalError("Unknown authorization status.")
//            }
//            locationServicesAuthorized = authorized
//            debugLog(" - authorized = \(authorized ? "Yes" : "No")")
//
//            // Significant-change location service does not handle the accuracy.
//            //
//            //    switch manager.accuracyAuthorization {
//            //    case .fullAccuracy:
//            //        // The user authorized the app to access location data with full accuracy
//            //    case .reducedAccuracy:
//            //        // The user authorized the app to access location data with reduced accuracy
//            //    @unknown default:
//            //        fatalError("Unknown accuracy level.")
//            //    }
//        }
//
//        // MARK: Handling Errors
//
//        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//            // Tells the delegate that the location manager was unable to retrieve a location value.
//            debugLog("locationManager(_:didFailWithError) was called. error = \(error.localizedDescription)")
//            if let error = error as? CLError, error.code == .denied {
//                // Location updates are not authorized.
//                stopUpdatingLocation()
//                return
//            }
//        }
//
//        // MARK: Responding to Location Events
//
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            // Tells the delegate that new location data is available
//            debugLog("locationManager(_:didUpdateLocations) was called.")
//            // [Note]
//            //    The locations parameter always contains at least one location
//            //    and may contain more than one. Locations are always reported
//            //    in the order in which they were determined, so the most recent
//            //    location is always the *last* item in the array
//            guard let location = locations.last else { return }
//
//            // [Note]
//            //    Before using a location value, check the time stamp of the CLLocation
//            //    object. Because the system may return cached locations, checking
//            //    the time stamp lets you know whether to update your interface right
//            //    away or perhaps wait for a new location.
//
//            debugLog("LOC: updated location = \(location)")
//
//            // update the device location and stop updating
//            if let newDeviceLocation = makeDeviceLocation(location: location) {
//                deviceLocation = newDeviceLocation
//                stopUpdatingLocation()
//                debugLog("LOC: updated device location = \(newDeviceLocation)")
//            }
//        }
//
//        private func makeDeviceLocation(location: CLLocation) -> DeviceLocation? {
//            // A negative value of horizontalAccuracy indicates that
//            // the latitude and longitude are invalid.
//            guard location.horizontalAccuracy >= 0 else { return nil }
//
//            let latitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude
//            let horizontalAccuracy = location.horizontalAccuracy
//
//            var altitude: Double = 0
//            // If verticalAccuracy is 0 or a negative value, altitude is invalid.
//            if location.verticalAccuracy > 0 {
//                altitude = location.altitude
//            }
//            let verticalAccuracy = location.verticalAccuracy
//
//            // Don't check the timestamp because when the device does not move,
//            // the location's timestamp will be very old.
//            let timestamp = location.timestamp
//            return DeviceLocation(latitude: latitude,
//                                  longitude: longitude,
//                                  altitude: altitude,
//                                  horizontalAccuracy: horizontalAccuracy,
//                                  verticalAccuracy: verticalAccuracy,
//                                  timestamp: timestamp)
//            //    let currentTime = Date()
//            //    var deviceLocation: DeviceLocation?
//            //    if currentTime.timeIntervalSince(timestamp) < 5 * 60 { // [sec]
//            //        deviceLocation = DeviceLocation(latitude: latitude,
//            //                                        longitude: longitude,
//            //                                        altitude: altitude,
//            //                                        horizontalAccuracy: horizontalAccuracy,
//            //                                        verticalAccuracy: verticalAccuracy,
//            //                                        timestamp: timestamp)
//            //    }
//            //    return deviceLocation
//        }
//
//        //    func locationManager(_ manager: CLLocationManager, didUpdateTo: CLLocation, from: CLLocation) {
//        //        // Tells the delegate that a new location value is available
//        //    }
//
//        func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
//            // Tells the delegate that updates will no longer be deferred
//            // swiftlint:disable line_length
//            debugLog("locationManager(_:didFinishDeferredUpdatesWithError) was called. error = \(error?.localizedDescription ?? "")")
//        }
//
//        // MARK: Pausing Location Updates
//
//        func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
//            // Tells the delegate that location updates were paused
//            debugLog("locationManagerDidPauseLocationUpdates(_:) was called.")
//        }
//
//        func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
//            // Tells the delegate that the delivery of location updates has resumed
//            debugLog("locationManagerDidResumeLocationUpdates(_:) was called.")
//        }
//
//        //    // MARK: Responding to Heading Events
//        //
//        //    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        //        // Tells the delegate that the location manager received updated heading information.
//        //        debugLog("locationManager(_:didUpdateHeading) was called.")
//        //    }
//        //
//        //    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
//        //        // Asks the delegate whether the heading calibration alert should be displayed
//        //        return true
//        //    }
//
//        //    // MARK: Responding to Region Events
//        //
//        //    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        //        // Tells the delegate that the user entered the specified region
//        //        debugLog("locationManager(_:didEnterRegion) was called.")
//        //    }
//        //
//        //    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        //        // Tells the delegate that the user left the specified region
//        //        debugLog("locationManager(_:didExitRegion) was called.")
//        //    }
//        //
//        //    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        //        // Tells the delegate about the state of the specified region
//        //        debugLog("locationManager(_:didDetermineState:for:) was called.")
//        //    }
//        //
//        //    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//        //        // Tells the delegate that a region monitoring error occurred
//        //        debugLog("locationManager(_:monitoringDidFailFor:withError:) was called. error = \(error.localizedDescription)")
//        //    }
//        //
//        //    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        //        // Tells the delegate that a new region is being monitored
//        //        debugLog("locationManager(_:didStartMonitoringFor:) was called.")
//        //    }
//
//        //    // MARK: Responding to Visit Events
//        //
//        //    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
//        //        // Tells the delegate that a new visit-related event was received
//        //        debugLog("locationManager(_:didVisit:) was called.")
//        //    }
//    }

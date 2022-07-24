//
//  LocationManager.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/02.
//

import CoreLocation

final class LocationManager: NSObject {
    private let manager: CLLocationManager
    let locationServiceSupported: Bool
    var locationServicesAuthorized = false
    var currentLocation: DeviceLocation?

    enum UpdatingState: Int { case idle = 0, updating }
    private var updatingState = UpdatingState.idle

    override init() {
        manager = CLLocationManager()
        // Check if the device supports the Significant-Change Location Service
        locationServiceSupported = CLLocationManager.significantLocationChangeMonitoringAvailable()
        super.init()
        manager.delegate = self
    }
}

// MARK: - LocationManager

extension LocationManager {
    // Request the location service authorization for When In Use
    //
    // [Note] You must call this method or requestAlwaysAuthorization()
    //     before you can receive location-related information.
    //     You may call requestWhenInUseAuthorization() whenever the current
    //     authorization status is not determined (CLAuthorizationStatus.notDetermined).
    // [Note] This method runs asynchronously and prompts the user to grant permission
    //     to the app to use location services. The user prompt contains the text from
    //     the NSLocationWhenInUseUsageDescription key in your app Info.plist file,
    //     and the presence of that key is required when calling this method.
    func requestAuthorization() {
        debugLog("LM: requestAuthorization for When In Use was called.")
        if locationServiceSupported {
            manager.requestWhenInUseAuthorization()
        } else {
            // do nothing. just ignore
        }
    }

    func startUpdatingLocation() {
        debugLog("LM: Updating Location started.")
        if locationServiceSupported {
            startUpdating()
        } else {
            // do nothing. just ignore
        }
    }

    // Start the location services
    //
    // The Significant-change Location Service ignores the accuracy and distance filter.
    // [Note] For iOS, the default value of this property is kCLLocationAccuracyBest.
    // assert(locationManager.desiredAccuracy == kCLLocationAccuracyBest)
    // [Note] The default value (Double [m]) of this property is
    //        kCLDistanceFilterNone.
    //
    // assert(locationManager.distanceFilter == kCLDistanceFilterNone)
    //    locationManager.distanceFilter = AppSettings.share.distanceFilter // [m]
    // [Note] On supported platforms the default value of this property is true
    // assert(locationManager.pausesLocationUpdatesAutomatically == true)
    // [Note]
    //    The default value of this property is CLActivityType.other.
    //    fitness: The location manager is being used to track fitness activities
    //    such as walking, running, cycling, and so on.
    //    when the value of activityType is CLActivityType.fitness,
    //    indoor positioning is disabled.
    // locationManager.activityType = .fitness
    // [Note]
    //    With this service, the location manager ignores the values in its
    //    distanceFilter and desiredAccuracy properties, so you don't need
    //    to configure them.
    private func startUpdating() {
        debugLog("LM: startUpdatingLocation() was called.")
        assert(updatingState == .idle)
        updatingState = .updating
        manager.startMonitoringSignificantLocationChanges()
    }

    // Stop the location services
    private func stopUpdating() {
        debugLog("LM: stopUpdatingLocation() was called.")
        // This can be called during not updating.
        // For example, called by denied error
        if updatingState == .updating {
            updatingState = .idle
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
}

// MARK: - CLLocationManager Delegate

// All delegate functions of CLLocationManagerDelegate are optionals.
//
// According to the experiments, delegate functions are called in the Main-thread.
extension LocationManager: CLLocationManagerDelegate {
    // [Note] If the user’s choice doesn’t change the authorization status
    //     after you call the requestWhenInUseAuthorization() or requestAlwaysAuthorization()
    //     method, the location manager doesn’t report the current authorization status to
    //     this method—the location manager only reports changes.
    //
    // [Note] An app's authorization status changes in response to users’ actions.
    //     Users can change permission for apps to use location information at any time.
    //     The user can:
    //     - Change an app’s location authorization in Settings > Privacy > Location Services,
    //       or in Settings > (the app) > Location Services.
    //     - Turn location services on or off globally in Settings > Privacy > Location Services.
    //     - Choose Reset Location & Privacy in Settings > General > Reset.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Tells the delegate when the app creates the location manager
        // and when the authorization status changes.
        debugLog("LM: locationManagerDidChangeAuthorization(_:) was called. status = \(manager.authorizationStatus)")

        var authorized = false
        switch manager.authorizationStatus {
        case .notDetermined,
             // The user has not chosen whether the app can use location services
             .restricted,
             // The app is not authorized to use location services
             .denied:
             // The user denied the use of location services for the app or they are disabled globally in Settings.
            authorized = false
        case .authorizedAlways,
            // The user authorized the app to start location services at any time
             .authorizedWhenInUse:
            // The user authorized the app to start location services while it is in use
            authorized = true
        @unknown default:
            fatalError("LM: Unknown authorization status.")
        }

        locationServicesAuthorized = authorized
        debugLog("LM: - authorized = \(authorized ? "Yes" : "No")")

        // When the authorization status changes, the current location is cleared.
        // If the status turned to not-authorized, the location should not be used any more.
        // If the status turned to authorized, the location update will immediately happen.
        currentLocation = nil

        // Significant-change location service does not handle the accuracy.
        //
        //    switch manager.accuracyAuthorization {
        //    case .fullAccuracy:
        //        // The user authorized the app to access location data with full accuracy
        //    case .reducedAccuracy:
        //        // The user authorized the app to access location data with reduced accuracy
        //    @unknown default:
        //        fatalError("Unknown accuracy level.")
        //    }
    }

    // MARK: Handling Errors

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Tells the delegate that the location manager was unable to retrieve a location value.
        debugLog("LM: locationManager(_:didFailWithError) was called. error = \(error.localizedDescription)")
    }

    // MARK: Responding to Location Events

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Tells the delegate that new location data is available
        debugLog("LM: locationManager(_:didUpdateLocations) was called.")
        // [Note]
        //    The locations parameter always contains at least one location
        //    and may contain more than one. Locations are always reported
        //    in the order in which they were determined, so the most recent
        //    location is always the *last* item in the array
        guard let location = locations.last else {
            // When no location, do nothing. Just continue updating.
            return
        }

        // [Note]
        //    Before using a location value, check the time stamp of the CLLocation
        //    object. Because the system may return cached locations, checking
        //    the time stamp lets you know whether to update your interface right
        //    away or perhaps wait for a new location.

        debugLog("LM: updated location = \(location)")

        // update the device location and stop updating
        if let newDeviceLocation = makeDeviceLocation(location: location) {
            self.currentLocation = newDeviceLocation
            debugLog("LM: current device location was updated \(newDeviceLocation)")
        } else {
            // do nothing. Just continue updating
        }
    }

    private func makeDeviceLocation(location: CLLocation) -> DeviceLocation? {
        // A negative value of horizontalAccuracy indicates that
        // the latitude and longitude are invalid.
        guard location.horizontalAccuracy >= 0 else { return nil }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let horizontalAccuracy = location.horizontalAccuracy

        var altitude: Double = 0
        // If verticalAccuracy is 0 or a negative value, altitude is invalid.
        if location.verticalAccuracy > 0 {
            altitude = location.altitude
        }
        let verticalAccuracy = location.verticalAccuracy

        // Don't check the timestamp because when the device does not move,
        // the location's timestamp will be very old.
        let timestamp = location.timestamp
        return DeviceLocation(latitude: latitude,
                              longitude: longitude,
                              altitude: altitude,
                              horizontalAccuracy: horizontalAccuracy,
                              verticalAccuracy: verticalAccuracy,
                              timestamp: timestamp)
        //    let currentTime = Date()
        //    var deviceLocation: DeviceLocation?
        //    if currentTime.timeIntervalSince(timestamp) < 5 * 60 { // [sec]
        //        deviceLocation = DeviceLocation(latitude: latitude,
        //                                        longitude: longitude,
        //                                        altitude: altitude,
        //                                        horizontalAccuracy: horizontalAccuracy,
        //                                        verticalAccuracy: verticalAccuracy,
        //                                        timestamp: timestamp)
        //    }
        //    return deviceLocation
    }

    //    func locationManager(_ manager: CLLocationManager, didUpdateTo: CLLocation, from: CLLocation) {
    //        // Tells the delegate that a new location value is available
    //    }

    //    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
    //        // Tells the delegate that updates will no longer be deferred
    //        // swiftlint:disable line_length
    //        debugLog("locationManager(_:didFinishDeferredUpdatesWithError) was called. error = \(error?.localizedDescription ?? "")")
    //    }

    //    // MARK: Pausing Location Updates
    //
    //    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    //        // Tells the delegate that location updates were paused
    //        debugLog("locationManagerDidPauseLocationUpdates(_:) was called.")
    //    }
    //
    //    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    //        // Tells the delegate that the delivery of location updates has resumed
    //        debugLog("locationManagerDidResumeLocationUpdates(_:) was called.")
    //    }

    //    // MARK: Responding to Heading Events
    //
    //    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    //        // Tells the delegate that the location manager received updated heading information.
    //        debugLog("locationManager(_:didUpdateHeading) was called.")
    //    }
    //
    //    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    //        // Asks the delegate whether the heading calibration alert should be displayed
    //        return true
    //    }

    //    // MARK: Responding to Region Events
    //
    //    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    //        // Tells the delegate that the user entered the specified region
    //        debugLog("locationManager(_:didEnterRegion) was called.")
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    //        // Tells the delegate that the user left the specified region
    //        debugLog("locationManager(_:didExitRegion) was called.")
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    //        // Tells the delegate about the state of the specified region
    //        debugLog("locationManager(_:didDetermineState:for:) was called.")
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    //        // Tells the delegate that a region monitoring error occurred
    //        debugLog("locationManager(_:monitoringDidFailFor:withError:) was called. error = \(error.localizedDescription)")
    //    }
    //
    //    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    //        // Tells the delegate that a new region is being monitored
    //        debugLog("locationManager(_:didStartMonitoringFor:) was called.")
    //    }

    //    // MARK: Responding to Visit Events
    //
    //    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    //        // Tells the delegate that a new visit-related event was received
    //        debugLog("locationManager(_:didVisit:) was called.")
    //    }
}

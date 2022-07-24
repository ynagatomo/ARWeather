//
//  DeviceLocation.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/24.
//

import CoreLocation

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
}

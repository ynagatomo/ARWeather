//
//  AddLocationView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/04.
//

import SwiftUI

struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appStateController: AppStateController

    private let isNew: Bool // true: new (adding), false: editing an existing location
    private let locationID: UUID?   // nil: editing a new location
    private let isCurrentLocation: Bool  // true: current location
    private let originalLocation: Location? // not nil: when editing an existing location

    @State private var locationFavorite: Bool
    @State private var locationName: String //  = "hello"
    @State private var locationNote: String
    @State private var locationLatitude: Double //  = 0
    @State private var locationLongitude: Double //  = 0
    @State private var locationBGColor: Color //  = Color.gray
    @State private var locationSymbol: Int //  = 0

    /// Initializes the view
    /// - Parameters:
    ///   - appStateController: app state controller
    ///   - isNew: true: adds a new location, false: edits an exiting location
    ///   - locationID: location's ID when editing an existing location
    init(appStateController: AppStateController, isNew: Bool,
         locationID: UUID?) {
        self.appStateController = appStateController
        self.isNew = isNew
        self.locationID = locationID

        _locationFavorite = State(initialValue: false)
        _locationName = State(initialValue: "")
        _locationNote = State(initialValue: "")
        _locationLatitude = State(initialValue: 0)
        _locationLongitude = State(initialValue: 0)
        _locationBGColor = State(initialValue: Color.gray)
        _locationSymbol = State(initialValue: 0)

        if !isNew {
            // editing an existing location
            assert(locationID != nil)
            if let locationID {
                isCurrentLocation = appStateController.isCurrentLocation(ofID: locationID)
                if let location = appStateController.location(ofID: locationID) {
                    originalLocation = location
                    _locationFavorite = State(initialValue: location.favorite)
                    _locationName = State(initialValue: location.name)
                    _locationNote = State(initialValue: location.note)
                    // _locationLatitude = State(initialValue: location.geolocation?.latitude ?? 0)
                    // _locationLongitude = State(initialValue: location.geolocation?.longitude ?? 0)
                    _locationBGColor = State(initialValue: Color(location.color))
                    _locationSymbol = State(initialValue: location.symbol)
                } else {
                    originalLocation = nil
                    assertionFailure("failed finding the location of id \(locationID)")
                }
            } else {
                isCurrentLocation = false
                originalLocation = nil
                assertionFailure("error. locationID should not be nil.")
            }
        } else {
            // editing a new location
            isCurrentLocation = false
            originalLocation = nil
        } // if !isNew
    }

    private func saveLocation() {
        if isNew {
            // add a new location
            let newLocation = Location(id: UUID(),
                                       favorite: locationFavorite,
                                       name: locationName,
                                       note: locationNote,
                                       color: UIColor(locationBGColor),
                                       symbol: locationSymbol,
                                       model: 0,  // 3d model index
                                       isHere: false,
                                       geolocation: Geolocation(latitude: locationLatitude,
                                                                longitude: locationLongitude,
                                                                altitude: 0),
                                       weather: .none,
                                       task: nil)
            appStateController.addLocation(newLocation) // add the new location
        } else {
            // override the existing location
            if let originalLocation {
                let editedLocation = originalLocation.updated(favorite: locationFavorite,
                    name: locationName,
                    note: locationNote,
                    color: UIColor(locationBGColor),
                    symbol: locationSymbol)
                appStateController.replaceLocation(ofID: originalLocation.id,
                                                   with: editedLocation)
            } else {
                assertionFailure("error. originalLocation should not nil.")
            }
        }
        appStateController.storeLocations()  // store all locations into the UserDefaults
    }

    var body: some View {
        VStack {
            HStack {
                Button("addview_btn_cancel", action: dismiss.callAsFunction).tint(.red)
                Spacer()
                Button("addview_btn_save", action: {
                    saveLocation()
                    dismiss.callAsFunction()
                }).buttonStyle(.borderedProminent)
            }
            Spacer()
            List {
                Section(header: Text("section_name", comment: "AddView: section")) {
                    TextField("addview_name", text: $locationName)
                    TextField("addview_note", text: $locationNote)
                } // Section
                if isNew {
                    Section(header: Text("section_location", comment: "AddView: section")) {
                        NumberField(title: "addview_latitude",
                                    value: $locationLatitude)
                        .onSubmit {
                            validateLatitude()
                        }
                        NumberField(title: "addview_longitude",
                                    value: $locationLongitude)
                        .onSubmit {
                            validateLongitude()
                        }
                        HStack {
                            Spacer()
                            Button("addview_btn_current_location", action: {
                                if let deviceLocation = appStateController.currentDeviceLocation() {
                                    locationLatitude = deviceLocation.latitude
                                    locationLongitude = deviceLocation.longitude
                                }
                            }).disabled(appStateController.currentDeviceLocation() == nil)
                        }
                    } // Section
                }
                Section(header: Text("section_background", comment: "AddView: section")) {
                    ColorPicker("addview_background_color", selection: $locationBGColor)
                    Picker(selection: $locationSymbol, content: {
                        ForEach(0 ..< AppConstant.locationSymbols.count, id: \.self) {
                            Image(systemName: AppConstant.locationSymbols[$0])
                        }
                    }, label: { Text("addview_location_symbol", comment: "AddView: picker") })
                } // Section
                Section(header: Text("section_place", comment: "AddView: section")) {
                    HStack {
                        Toggle(isOn: $locationFavorite) {
                            Label("addview_toggle_favorite", systemImage: locationFavorite ? "heart.fill" : "heart")
                        }
                        .toggleStyle(.button)
                    }
                } // Section
            } // List
        } // VStack
        .padding(20)
    }

    struct NumberField: View {
        let title: String
        @Binding var value: Double
        private let numberFormatter: NumberFormatter = {
            var formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6 // default = 0
            return formatter
        }()

        var body: some View {
            HStack {
                Text(title)
                Spacer()
                TextField(title, value: $value,
                          formatter: numberFormatter)
                .keyboardType(.decimalPad)
            }
        } // body
    } // View

    private func validateLatitude() {
        if locationLatitude > 90 {
            locationLatitude = 90
        } else if locationLatitude < -90 {
            locationLatitude = -90
        }
    }

    private func validateLongitude() {
        if locationLongitude > 180 {
            locationLongitude = 180
        } else if locationLongitude < -180 {
            locationLongitude = -180
        }
    }
}

struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationView(appStateController: AppStateController(),
                        isNew: true,
                        locationID: nil
        )
    }
}
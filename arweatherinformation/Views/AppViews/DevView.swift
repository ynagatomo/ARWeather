//
//  DevView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/28.
//

#if DEBUG
import SwiftUI

// swiftlint:disable line_length

struct DevView: View {
    @ObservedObject var appStateController: AppStateController
    @Environment(\.dismiss) var dismiss

    @AppStorage(AppConstant.weatherAPICallCount) var weatherAPICallCount = 0
    @AppStorage(AppConstant.startedCount) var startedCount = 0 // App started count

    @State private var weatherExpire = DevConfiguration.share.weatherDataExpireSecondsIndex
    @State private var weatherServiceDelay = DevConfiguration.share.isWeatherServiceDelay
    @State private var throwingWeatherError = DevConfiguration.share.isThrowingWeatherError

    var body: some View {
        VStack {
            HStack {
                Text(String("\(Bundle.main.appName) Ver. \(Bundle.main.appVersion) Build \(Bundle.main.buildNumberValue)"))
                Spacer()
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "x.circle")
                        .font(.system(size: 36))
                }
            } // HStack

            List {
                // Do something
                Section(content: {
                    Button(action: { appStateController.doSomething() },
                    label: {
                        Text("Do Something")
                    }).buttonStyle(.borderedProminent)
                }, header: { Text("Do something") })

                // UserDefaults
                Section(content: {
                    Text(String("App started count: \(startedCount)"))
                    Text(String("Weather API call count: \(weatherAPICallCount)"))
//                    Toggle("onboardingDisplayed", isOn: $onboardingDisplayed)
                }, header: { Text("UserDefaults") })

                // App State
                Section(content: {
                    Text(String("Significant Location supported: \(appStateController.locationServiceSupported() ? "Yes" : "No")"))
                    Text(String("Location Services Authorized: \(appStateController.locationServicesAuthorized() ? "Yes" : "No")"))
                }, header: { Text("App State") })

                // Weather Services
                Section(content: {
                    Picker(selection: $weatherExpire, label: Text(String("Weather data  valid duration [seconds]"))) {
                        ForEach(0 ..< DevConstant.weatherDataExpireSeconds.count, id: \.self) {
                            Text(String(format: "%3.0f", DevConstant.weatherDataExpireSeconds[$0]) + " seconds")
                        }
                    }
                    .onChange(of: weatherExpire) { index in
                        DevConfiguration.share.weatherDataExpireSeconds
                            = DevConstant.weatherDataExpireSeconds[index]
                        DevConfiguration.share.weatherDataExpireSecondsIndex = index
                    }

                    Toggle(String("Weather Service Delay \(DevConstant.weatherServiceDelaySeconds) [seconds] Enable"), isOn: $weatherServiceDelay)
                        .onChange(of: weatherServiceDelay) { value in
                            DevConfiguration.share.isWeatherServiceDelay = value
                        }
                    Toggle(String("Throwing Weather Error Enable"), isOn: $throwingWeatherError)
                        .onChange(of: throwingWeatherError) { value in
                            DevConfiguration.share.isThrowingWeatherError = value
                        }
                }, header: { Text("Weather Services") })
            } // List
            .listStyle(SidebarListStyle())

            Spacer()
        } // VStack
        .tint(Color("HomeBGColor"))
        .fontWeight(.thin)
        .padding(40)
    }
}

struct DevView_Previews: PreviewProvider {
    static var previews: some View {
        DevView(appStateController: AppStateController())
    }
}
#endif

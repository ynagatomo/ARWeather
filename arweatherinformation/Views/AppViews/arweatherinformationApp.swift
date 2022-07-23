//
//  arweatherinformationApp.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/13.
//

import SwiftUI
import StoreKit

@main
struct ARWeatherApp: App {
    @StateObject var appStateController = AppStateController()
    @AppStorage(AppConstant.onboardingDisplayed) var onboardingDisplayed = true
    @AppStorage(AppConstant.startedCount) var startedCount = 0 // App started count
    @AppStorage(AppConstant.soundEnable) var soundEnable = true // Playing Sound?
    @Environment(\.requestReview) private var requestReview

    var body: some Scene {
        WindowGroup {
            LocationListView(appStateController: appStateController)
                .onAppear {
                    appStateController.loadLocations()
                    appStateController.requestAuthorization()
                    appStateController.startUpdatingLocation()
                    SoundManager.share.setup(soundEnable)
                    checkAppReview()
                }
                .task {
                    await appStateController.getAttribution()
                }
                .sheet(isPresented: $onboardingDisplayed) {
                    OnboardingView()    // displayed only once
                }
        }
    }

    private func checkAppReview() {
        startedCount += 1
        if startedCount % 10 == 0 {
            requestReview()
            debugLog("DEBUG: requestReview() was called.")
//            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                SKStoreReviewController.requestReview(in: scene)
//            }
        }
    }
}

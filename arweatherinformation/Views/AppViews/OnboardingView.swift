//
//  OnboardingView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/06.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Image("twoPerson640")
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)

            Text("Onboarding_title", comment: "Onboarding title")
                .font(.largeTitle)
                .padding(6)

            Text("Onboarding_message", comment: "Onboarding message")
                .padding(.horizontal)
                .foregroundColor(.secondary)

            Button("onboarding_btn_begin", action: { dismiss.callAsFunction() })
                .buttonStyle(.borderedProminent)
                .tint(Color("HomeBGColor"))
                .padding()
        }
        .fontWeight(.thin)
        .padding(60)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

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
//            Color.gray
//                .frame(width: 200, height: 160)
//                .padding(20)

//            Image(systemName: "cloud.sun.rain.fill")
//                .renderingMode(.original)
//                .font(.system(size: 80))
//                .padding()
//                .padding(.horizontal, 40)
//                .background(Color.gray.opacity(0.2).cornerRadius(20))
//                .padding(.bottom)
//                .accessibilityHidden(true)

            Image("twoPerson640")
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)

            Text("check the weather forecast for the places you care about", comment: "Onboarding title")
                .font(.largeTitle)
                .padding(6) // .horizontal)

            // swiftlint:disable line_length
            Text("you can check the hourly and daily weather forecasts for your current location or registered location. You can also see the weather forecast three-dimensionally by augmented reality.", comment: "Onboarding descripton")
                .padding(.horizontal)
//                .padding(.top, 4)
                .foregroundColor(.secondary)

            Button("begin", action: { dismiss.callAsFunction() })
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

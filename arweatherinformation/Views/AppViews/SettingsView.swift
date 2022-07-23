//
//  SettingsView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/28.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(AppConstant.displayingARGGuidance) private var displayingARGGuidance = true
    @AppStorage(AppConstant.onboardingDisplayed) var onboardingDisplayed = true
    @AppStorage(AppConstant.soundEnable) var soundEnable = true // Playing Sound?
//    @AppStorage(AppConstant.autoStopARPlaying) var autoStopARPlaying = true

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("done", action: dismiss.callAsFunction)
//                Button(action: dismiss.callAsFunction) {
//                    Image(systemName: "x.circle")
//                        .font(.system(size: 36))
//                }
            } // HStack
            Text("settings").font(.title)

            List {
                Section(header: Text("display", comment: "Settings: section - display")) {
                    Toggle("display ar guidance", isOn: $displayingARGGuidance)
                    Toggle("display introduction", isOn: $onboardingDisplayed)
                }

                Section(header: Text("sound", comment: "Settings: section - sound")) {
                    Toggle("enable sound", isOn: $soundEnable)
                        .onChange(of: soundEnable) { value in
                            SoundManager.share.enable = value
                        }
                }

//                Section(header: Text("")) {
//                    Toggle("finish ar playing automatically to save battery and to reduce the heat",
//                           isOn: $autoStopARPlaying)
//                }
            }

//            Spacer()
        } // VStack
        .fontWeight(.thin)
        .padding(40)
        .tint(Color("ControlColor"))
    } // body
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

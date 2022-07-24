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

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("settings_btn_done", action: dismiss.callAsFunction)
            } // HStack
            Text("settings_title", comment: "Settings: Title").font(.title)

            List {
                Section(header: Text("section_display", comment: "Settings: section - display")) {
                    Toggle("toggle_display_ar_guidance", isOn: $displayingARGGuidance)
                    Toggle("toggle_display_introduction", isOn: $onboardingDisplayed)
                }

                Section(header: Text("section_sound", comment: "Settings: section - sound")) {
                    Toggle("toggle_enable_sound", isOn: $soundEnable)
                        .onChange(of: soundEnable) { value in
                            SoundManager.share.enable = value
                        }
                }
            }
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

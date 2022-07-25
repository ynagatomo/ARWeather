//
//  AboutView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/28.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("about_btn_close", action: dismiss.callAsFunction)
            } // HStack

            Image("onePerson640")
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)

            Text(String("\(Bundle.main.appName) Ver. \(Bundle.main.appVersion) Build \(Bundle.main.buildNumberValue)"))
                .padding()

            Divider()

            Link(String("App Review"),  // English only
                 destination: URL(string: AppConstant.reviewURLString)!).padding(1)
            Link(String("Twitter @weatherarapp"), // English only
                 destination: URL(string: AppConstant.twitterURLString)!).padding(1)
            Link(String("Support Web"), // English only
                 destination: URL(string: AppConstant.supportURLString)!).padding(1)
            Link(String("Developer Web"), // English only
                 destination: URL(string: AppConstant.developerURLString)!).padding(1)
            Spacer()
        } // VStack
        .fontWeight(.thin)
        .padding(60)
        .tint(Color("HomeBGColor"))
    } // body
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

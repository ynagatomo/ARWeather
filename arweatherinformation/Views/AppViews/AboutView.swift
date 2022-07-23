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
                Button("close", action: dismiss.callAsFunction)
//                    .font(.title3)
//                Button(action: dismiss.callAsFunction) {
//                    Image(systemName: "x.circle")
//                        .font(.system(size: 36))
//                }
            } // HStack

            Image("onePerson640")
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)

//            Image(systemName: "cloud.sun.rain.fill")
//                .renderingMode(.original)
//                .font(.system(size: 80))
//                .padding()
//                .padding(.horizontal, 40)
//                .background(Color.gray.opacity(0.2).cornerRadius(20))
//                .padding(.bottom)
//                .accessibilityHidden(true)

//            Text("ar weather", comment: "app name")
//                .font(.title)
//                .padding(6) // .horizontal)

            Text(String("\(Bundle.main.appName) Ver. \(Bundle.main.appVersion) Build \(Bundle.main.buildNumberValue)"))
                .padding()

            Divider()

            Link("app review",
                 destination: URL(string: "http://www.atarayosd.com/")!).padding(1) // TODO: URL
            Link("twitter @weatherarapp",
                 destination: URL(string: "https://twitter.com/weatherarapp")!).padding(1)
            Link("support",
                 destination: URL(string: "https://www.atarayosd.com/weather/app.html")!).padding(1)
            Link("developer",
                 destination: URL(string: "https://www.atarayosd.com/")!).padding(1)
            Spacer()
        } // VStack
        .fontWeight(.thin)
        .padding(60)
        .tint(Color("HomeBGColor"))
//        .controlSize(.large)
    } // body
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

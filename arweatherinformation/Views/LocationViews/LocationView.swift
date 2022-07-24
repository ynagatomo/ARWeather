//
//  LocationView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/04.
//

import SwiftUI

struct LocationView: View {
    let location: Location

    var body: some View {
        ZStack {
            HStack {
                Image(systemName: AppConstant.locationSymbols[location.symbol])
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(.white).opacity(0.3)
                    .padding(.horizontal, 20)
                    .accessibilityHidden(true)
                Spacer()
            } // HStack
            VStack {
                Text(location.name)
                    .font(.title)
                    .fontWeight(.thin)
                    .lineLimit(1)
                    .padding(6)
                Text(location.note)
                    .font(.caption)
                    .fontWeight(.thin)
                    .lineLimit(2, reservesSpace: true)
                    .padding(6) // .horizontal)
            } // VStack
            .accessibilityElement(children: .combine)
        } // ZStack
        .background(in: RoundedRectangle(cornerRadius: 10).inset(by: -10))
        .backgroundStyle(Color(location.color).gradient)
        .foregroundStyle(.white)
        .padding(12)
        .shadow(radius: 10)
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: Location(id: UUID(),
                                        favorite: false,
                                        name: "Shiojiri",
                                        note: "It's a very good place in Nagano. We live over ten years.",
                                        color: .orange,
                                        symbol: 0,
                                        model: 0,
                                        isHere: false,
                                        geolocation: Geolocation(latitude: 0, longitude: 0, altitude: 0),
                                        weather: .none,
                                        task: nil))
    }
}

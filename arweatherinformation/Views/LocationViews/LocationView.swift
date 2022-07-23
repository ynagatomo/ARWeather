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
                Spacer()
            } // HStack
            VStack {
                Text(location.name)
                    .font(.title)
                    .fontWeight(.thin)
//                    .bold()
                    .lineLimit(1)
                    .padding(6)
                Text(location.note)
                    .font(.caption)
                    .fontWeight(.thin)
//                    .foregroundColor(.secondary)
                    .lineLimit(2, reservesSpace: true)
                    .padding(6) // .horizontal)
            } // VStack
        } // ZStack
        .background(in: RoundedRectangle(cornerRadius: 10).inset(by: -10))
        .backgroundStyle(Color(location.color).gradient)
        .foregroundStyle(.white)
        .padding(12)
        .shadow(radius: 10)
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundColor(Color(location.color))
//                //    .fill(
//                //        LinearGradient(gradient: Gradient(colors: [.clear, .blue]),
//                //          startPoint: .top, endPoint: .bottom)
//                //    )
//                .frame(height: 140)
//                .opacity(0.5)
//            HStack {
//                Image(systemName: AppConstant.locationSymbols[location.symbol])
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 80)
//                    .foregroundColor(Color(location.color))
//                    .padding(.horizontal, 20)
//                VStack {
//                    Text(location.name)
//                        .font(.title2)
//                        .lineLimit(1)
//                        .padding()
//                    Text(location.note)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                        .padding(.horizontal)
//                } // VStack
//                Spacer()
//            } // HStack
//        } // ZStack
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

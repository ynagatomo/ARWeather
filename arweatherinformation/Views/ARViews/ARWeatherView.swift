//
//  ARWeatherView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/12.
//

import SwiftUI

struct ARWeatherView: View {
    //    @ObservedObject var appStateController: AppStateController
    let name: String
    let modelIndex: Int
    let hourlyForecast: [HourForecast]
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppConstant.displayingARGGuidance) private var displayingARGGuidance = true
    @State private var showingGuidance = false
    @State private var hourIndex = 0
    @State private var scale = 0  // 0: small, 1: middle, 2: large

    var body: some View {
        ARContainerView(hourForecast: hourlyForecast[hourIndex],
                        scale: scale,
                        modelIndex: modelIndex)
            // .ignoresSafeArea()
            .overlay {
                VStack {
                    HStack(alignment: .top) {
                        // Share (placeholder for ARView's button)
                        Color.clear
                            .frame(width: 40, height: 40)
                            .padding(.leading, 40)
                            .disabled(true)
                        Spacer()
                        ForecastInfoView(name: name,
                                         forecast: hourlyForecast[hourIndex],
                                         position: (hourIndex, hourlyForecast.count))
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                        // Spacer()
                        // Close [X]
                        Button(action: dismiss.callAsFunction) {
                            Image(systemName: "xmark.circle")
                                .font(.title)
                                .padding(.trailing, 40)
                                .padding(.top, 40)
                        }
                    } // HStack
                    Spacer()
                    // Control Panel
                    HStack {
                        // Backward [<-]
                        Button(action: goBackward) {
                            Image(systemName: "arrowshape.backward")
                                .font(.title)
                        }
                        .padding(.horizontal, 10)
                        // Scale Change [S]
                        Button(action: scaleUp) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.title)
                        }
                        .padding(.horizontal, 20)
                        // Foreward [->]
                        Button(action: goForeward) {
                            Image(systemName: "arrowshape.forward")
                                .font(.title)
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.5).cornerRadius(10))
                    .tint(.white)
                    .padding(.bottom, 20)
                } // VStack
            } // overlay
            .alert("ar guidance", isPresented: $showingGuidance) {
                Button("ok") { }
                Button("do not show again") {
                    displayingARGGuidance = false
                }
            } message: {
                Text("ar guidance message")
            }
            .onAppear {
                showingGuidance = displayingARGGuidance
            }
    } // body

    private func goBackward() {
        if hourIndex > 0 {
            hourIndex -= 1
            SoundManager.share.play(.hourflip)
        } else {
            hourIndex = hourlyForecast.count - 1
            SoundManager.share.play(.hourflipend)
        }
    }

    private func goForeward() {
        if hourIndex == hourlyForecast.count - 1 {
            hourIndex = 0 // reset
            SoundManager.share.play(.hourflipend)
        } else {
            hourIndex += 1
            SoundManager.share.play(.hourflip)
        }
    }

    private func scaleUp() {
        if scale == 2 {
            scale = 0
        } else {
            scale += 1
        }
        // hapticsSimpleSuccess()
        SoundManager.share.play(.scaleup)
    }

    //  Haptics: too noisy
    //    private func hapticsSimpleSuccess() {
    //        let generator = UINotificationFeedbackGenerator()
    //        generator.notificationOccurred(.success)
    //    }
}

#if DEBUG
struct ARWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        ARWeatherView(name: "Sample",
                      modelIndex: 0,
                      hourlyForecast: SampleForecast.sampleHourlyForecasts)
    }
}
#endif

struct ForecastInfoView: View {
    let name: String
    let forecast: HourForecast
    let position: (current: Int, total: Int)

    var body: some View {
        VStack {
            HStack {
                ForEach(0 ..< position.total, id: \.self) { pos in
                    Image(systemName: pos == position.current ? "square.fill" : "square.dotted")
                        .font(.caption)
                }
            }
            Text(name)
                .lineLimit(1)
            Text(forecast.dateDescription)
                .font(.title2).bold()
            HStack {
                Text(forecast.conditionDescription)
                Text(forecast.temperatureDescription)
            }
            HStack {
                Image(systemName: "cloud.rain")
                Text(forecast.precipitationChanceDescription)
                Text(forecast.precipitationAmountDescription)
            }
            HStack {
                Image(systemName: "wind")
                Text(forecast.windSpeedDescription)
                Text(forecast.windDirectionDescription)
            }
        }
        .fontWeight(.thin)
        .padding(8)
        .foregroundColor(.white)
        .background(Color.black.opacity(0.5).cornerRadius(10))
    }
}

//
//  ARContainerView.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/12.
//

import SwiftUI

struct ARContainerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController
    let hourForecast: HourForecast
    let scale: Int  // 0: small, 1: middle, 2: large
    let modelIndex: Int // 0: field

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ARViewController {
        let arViewController = ARViewController()
        arViewController.setup(modelIndex: modelIndex)
        // swiftlint:disable line_length
        debugLog("AR: makeUIViewController(context:) was called. hourForecast.date = \(hourForecast.dateDescription) scale = \(scale)")
        return arViewController
    }

    func updateUIViewController(_ uiViewController: ARViewController,
                                context: Context) {
        // swiftlint:disable line_length
        debugLog("AR: updateUIViewController(_:context:) was called. hourForecast.date = \(hourForecast.dateDescription) scale = \(scale)")
        uiViewController.update(hourForecast: hourForecast, scale: scale)
    }

    class Coordinator: NSObject {
        var parent: ARContainerView
        init(_ parent: ARContainerView) {
            self.parent = parent
        }
    }
}

#if DEBUG
struct ARContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ARContainerView(hourForecast: SampleForecast.sampleHourlyForecasts[0],
        scale: 0,
        modelIndex: 0)
    }
}
#endif

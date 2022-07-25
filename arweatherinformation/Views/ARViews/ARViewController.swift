//
//  ARViewController.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/12.
//

import UIKit
import ARKit
import RealityKit

final class ARViewController: UIViewController {
    private var arView: ARView!
//    private var cameraTrackingState: ARCamera.TrackingState = .notAvailable
    private var arScene: ARScene!
    private var alertLabel: UILabel!
    private var modelIndex: Int = 0
    private var hourForecast: HourForecast!
    private var scale: Int = 0

    #if targetEnvironment(simulator)
    let perspectiveCamera = PerspectiveCamera() // : Entity
    #endif

    //    static var isPeopeOcclusionSupported: Bool {
    //        ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth)
    //    }
    //    static var isObjectOcclusionSupported: Bool {
    //        ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    //    }

    //    init() {
    //        super.init(nibName: nil, bundle: nil)
    //    }
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }

    override func viewDidLoad() {
        debugLog("AR: ARViewController.viewDidLoad() was called.")
        super.viewDidLoad()

        #if targetEnvironment(simulator)
        arView = ARView(frame: .zero)
        #else
        if ProcessInfo.processInfo.isiOSAppOnMac {
            arView = ARView(frame: .zero, cameraMode: .nonAR,
                            automaticallyConfigureSession: true)
        } else {
            // automaticallyConfigureSession = true is Ok
            // for scene reconstruction for mesh
            arView = ARView(frame: .zero, cameraMode: .ar,
                            automaticallyConfigureSession: true) // false)
        }
        #endif
        // arView.session.delegate = self

        #if DEBUG
        arView.debugOptions = []
        #endif
        view = arView

        let anchorEntity = AnchorEntity(world: .zero) // AppConstant.arWorldOrigin)
        arView.scene.addAnchor(anchorEntity)

        #if targetEnvironment(simulator)
        anchorEntity.addChild(perspectiveCamera)
        perspectiveCamera.position = DevConstant.perspectiveCameraPosition
        #endif

        // Share button
        let config = UIImage.SymbolConfiguration(pointSize: 28)
        let image = UIImage(systemName: "square.and.arrow.up",
                            withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let button = UIButton()
        button.frame = CGRect(x: CGFloat(38), y: CGFloat(38),
                              width: CGFloat(44), height: CGFloat(44))
        button.setImage(image, for: .normal)
        button.addTarget(self,
                         action: #selector(ARViewController.shareButtonTapped(sender:)),
                         for: .touchUpInside)
        view.addSubview(button)

        arScene = ARScene(arView: arView, anchor: anchorEntity)
        arScene.setup(modelIndex: modelIndex)
    }

    override func viewDidAppear(_ animated: Bool) {
        debugLog("AR: ARViewController.viewDidAppear() was called.")
        super.viewDidAppear(animated)

        // Setup the alert Label
        // At viewDidLoaded(), the ARView frame-size is not determined.
        // So the altertLabel should be set here, viewDidAppear()
        alertLabel = UILabel()
        alertLabel.font = UIFont.systemFont(ofSize: 18)
        alertLabel.textAlignment = NSTextAlignment.center
        alertLabel.numberOfLines = 0
        alertLabel.frame.size = CGSize(width: 300, height: 150)
        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
        alertLabel.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        alertLabel.text = ""
        alertLabel.textColor = UIColor.green
        // alertLabel.backgroundColor = UIColor.black
        alertLabel.layer.borderColor = UIColor.green.cgColor
        alertLabel.layer.borderWidth = 1
        alertLabel.layer.masksToBounds = true
        alertLabel.layer.cornerRadius = 10
        alertLabel.isHidden = true
        self.view.addSubview(alertLabel)

        // Set the delegate after setting of AlertLabel
        // because the delegate calls use the AlertLabel
        arView.session.delegate = self

        // Start the AR session.
        #if !targetEnvironment(simulator)
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            let config = ARWorldTrackingConfiguration()
            config.worldAlignment = .gravityAndHeading // -Z is heading to north

            //    if AppSettings.share.enablePeopleOcclusion { // People occlusion
            //        if ARViewController.isPeopeOcclusionSupported {
            //            config.frameSemantics.insert(.personSegmentationWithDepth)
            //            debugLog("AR: people occlusion was enabled.")
            //        }
            //    }

            //    // [Note]
            //    // When you enable scene reconstruction, ARKit provides a polygonal mesh
            //    // that estimates the shape of the physical environment.
            //    // If you enable plane detection, ARKit applies that information to the mesh.
            //    // Where the LiDAR scanner may produce a slightly uneven mesh on a real-world surface,
            //    // ARKit smooths out the mesh where it detects a plane on that surface.
            //    // If you enable people occlusion, ARKit adjusts the mesh according to any people
            //    // it detects in the camera feed. ARKit removes any part of the scene mesh that
            //    // overlaps with people
            //    if AppSettings.share.enableObjectOcclusion { // Object occlusion
            //        if ARViewController.isObjectOcclusionSupported {
            //            // Enable the object occlusion
            //            config.sceneReconstruction = .mesh
            //            arView.environment.sceneUnderstanding.options.insert(.occlusion)
            //            debugLog("AR: object occlusion was enabled.")
            //        }
            //    }
            arView.session.run(config)
        }
        #endif

        // start handling the render-loop
        arScene.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arScene.stopSession()
        #if !targetEnvironment(simulator)
        arView.session.pause()
        #endif
    }
}

extension ARViewController {
    func setup(modelIndex: Int) {
        self.modelIndex = modelIndex
    }

    func update(hourForecast: HourForecast, scale: Int) {
        debugLog("AR: ARViewController.update() was called.")
        self.hourForecast = hourForecast
        self.scale = scale

        arScene.update(hourForecast: hourForecast, scale: scale)
    }

    func showAlertLabel(with message: String) {
        alertLabel.text = message
        // alertLabel.isEnabled = true
        alertLabel.isHidden = false
    }

    /// Takes a shot of AR screen
    ///
    /// Caution in dev-time: without info.plist setting for access to the photo library, app will crash immediately
    /// JPEG is used because PNG is too big for screen-shot.
    @objc func shareButtonTapped(sender: UIButton) {
        arView.snapshot(saveToHDR: false) { (image) in
            if let compressedImage = UIImage(data: (image?.jpegData(compressionQuality: 0.5))!) {
                let items: [Any] = [AppConstant.twitterName + ": "
                                    + self.hourForecast.dateDescription
                                    + " " + self.hourForecast.conditionDescription
                                    + " " + self.hourForecast.temperatureDescription
                                    + " " + self.hourForecast.precipitationAmountDescription,
                                    compressedImage ]
                let avc = UIActivityViewController(activityItems: items,
                                                   applicationActivities: nil)
                if let presenter = avc.popoverPresentationController {
                    presenter.sourceView = sender
                    presenter.sourceRect = sender.bounds
                    presenter.permittedArrowDirections = .any
                }
                self.present(avc, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    /// tells that ARAnchors was added cause of like a plane-detection
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // debugLog("AR: AR-DELEGATE: didAdd anchors: [ARAnchor] : \(anchors)")
        // <AREnvironmentProbeAnchor> can be added for environmentTexturing
    }

    /// tells that ARAnchors were changed cause of like a progress of plane-detection
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // debugLog("AR: AR-DELEGATE: ARSessionDelegate: session(_:didUpdate) was called. \(anchors) were updated.")
        // <AREnvironmentProbeAnchor> can be added for environmentTexturing
    }

    /// tells that the ARAnchors were removed
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        // debugLog("AR: AR-DELEGATE: The session(_:didRemove) was called.  [ARAnchor] were removed.")
        //
        assertionFailure("The session(_:didUpdate) should not be called.")
    }

    /// tells that the AR session was interrupted due to app switching or something
    func sessionWasInterrupted(_ session: ARSession) {
        debugLog("AR: AR-DELEGATE: The sessionWasInterrupted(_:) was called.")
        // Nothing to do. The system handles all.

        // DispatchQueue.main.async {
        //   - do something if necessary
        // }
    }

    /// tells that the interruption was ended
    func sessionInterruptionEnded(_ session: ARSession) {
        debugLog("AR: AR-DELEGATE: The sessionInterruptionEnded(_:) was called.")
        // Nothing to do. The system handles all.

        // DispatchQueue.main.async {
        //   - reset the AR tracking
        //   - do something if necessary
        // }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // swiftlint:disable line_length
        debugLog("AR: AR-DELEGATE: The session(_:cameraDidChangeTrackingState:) was called. cameraState = \(camera.trackingState)")

        arScene.updateCameraTrackingState(state: camera.trackingState)
    }

    //    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    //        // You can get the camera's (device's) position in the virtual space
    //        // from the transform property.
    //        // The 4th column represents the position, (x, y, z, -).
    //        let cameraTransform = frame.camera.transform
    //        // The orientation of the camera, expressed as roll, pitch, and yaw values.
    //        let cameraEulerAngles = frame.camera.eulerAngles // simd_float3
    //    }

    /// tells that an error was occurred
    ///
    /// - When the users don't allow to access the camera, this delegate will be called.
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func session(_ session: ARSession, didFailWithError error: Error) {
        debugLog("AR: AR-DELEGATE: The didFailWithError was called.")
        debugLog("AR: AR-DELEGATE:     error = \(error.localizedDescription)")
        guard let arerror = error as? ARError else { return }

        #if DEBUG
        // print the errorCase
        let errorCase: String
        switch arerror.errorCode {
        case ARError.Code.requestFailed.rawValue: errorCase = "requestFailed"
        case ARError.Code.cameraUnauthorized.rawValue: errorCase = "cameraUnauthorized"
        case ARError.Code.fileIOFailed.rawValue: errorCase = "fileIOFailed"
        case ARError.Code.insufficientFeatures.rawValue: errorCase = "insufficientFeatures"
        case ARError.Code.invalidConfiguration.rawValue: errorCase = "invalidConfiguration"
        case ARError.Code.invalidReferenceImage.rawValue: errorCase = "invalidReferenceImage"
        case ARError.Code.invalidReferenceObject.rawValue: errorCase = "invalidReferenceObject"
        case ARError.Code.invalidWorldMap.rawValue: errorCase = "invalidWorldMap"
        case ARError.Code.microphoneUnauthorized.rawValue: errorCase = "microphoneUnauthorized"
        case ARError.Code.objectMergeFailed.rawValue: errorCase = "objectMergeFailed"
        case ARError.Code.sensorFailed.rawValue: errorCase = "sensorFailed"
        case ARError.Code.sensorUnavailable.rawValue: errorCase = "sensorUnavailable"
        case ARError.Code.unsupportedConfiguration.rawValue: errorCase = "unsupportedConfiguration"
        case ARError.Code.worldTrackingFailed.rawValue: errorCase = "worldTrackingFailed"
        case ARError.Code.geoTrackingFailed.rawValue: errorCase = "geoTrackingFailed"
        case ARError.Code.geoTrackingNotAvailableAtLocation.rawValue: errorCase = "geoTrackingNotAvailableAtLocation"
        case ARError.Code.locationUnauthorized.rawValue: errorCase = "locationUnauthorized"
        case ARError.Code.invalidCollaborationData.rawValue: errorCase = "invalidCollaborationData"
        default: errorCase = "unknown"
        }
        debugLog("AR: AR-DELEGATE:     errorCase = \(errorCase)")

        // print the errorWithInfo
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        // remove optional error messages and connect into one string
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        debugLog("AR: AR-DELEGATE:     errorWithInfo: \(errorMessage)")
        #endif

        // handle the issues
        if arerror.errorCode == ARError.Code.cameraUnauthorized.rawValue {
            // Error: The camera access is not allowed.
            debugLog("AR: AR-DELEGATE:     The camera access is not authorized.")

            // Show the alert message.
            // "The use of the camera is not permitted.\nPlease allow it with the Settings app."
            showAlertLabel(with:
                           NSLocalizedString("cameraAlert_not_permitted", comment: "Camera Alert message"))

        } else if arerror.errorCode == ARError.Code.unsupportedConfiguration.rawValue {
            // Error: Unsupported Configuration
            // It means that now the AR session is trying to run on macOS(w/M1) or Simulator.
            debugLog("AR: AR-DELEGATE:     unsupportedConfiguration. (running on macOS or Simulator)")
            assertionFailure("invalid ARSession on macOS or Simulator.")
            // Nothing to do in release mode.
        } else {
            // Error: Something else
            // Nothing to do.
        }
    }
}

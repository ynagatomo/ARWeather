//
//  ARScene.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/07/12.
//

import UIKit
import ARKit
import RealityKit
import Combine

final class ARScene {
    private var anchor: AnchorEntity!
    private var arView: ARView!
//    private var isFirstTime = true
    private var renderLoopSubscription: Cancellable?

    private var modelIndex: Int = 0
    private var hourForecast: HourForecast!
    private var scaleIndex: Int = 0     // 0: small, 1: middle, 2: large
    private var baseEntity: Entity?
    private var cloudEntities: [ModelEntity] = [] // cloud model entities
    private var cloudGrid: [SIMD3<Float>] = []    // cloud position grid
    private var rainEntities: [ModelEntity] = []  // rain or snow model entities
    private var rainFallSpeed: [Double] = []      // rain or snow fall speed [m/s]
    private var rainFallSpeedBase: Double = 0     // rain or snow fall speed base [m/s]

    enum SceneState: Int {
        case none = 0, setup
    }
    private var sceneState = SceneState.none

    init(arView: ARView, anchor: AnchorEntity) {
        self.anchor = anchor
        self.arView = arView
    }

    func startSession() {
        renderLoopSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            DispatchQueue.main.async {
                self.updateScene(deltaTime: event.deltaTime)
            }
        }
    }

    func stopSession() {
        renderLoopSubscription?.cancel()
        renderLoopSubscription = nil
    }
}

// MARK: - render loop

extension ARScene {
    private func updateScene(deltaTime: Double) {
        // limit the wind speed [km/h] within the StageModelSpec.windSpeedMax
        let windSpeedKPH = hourForecast.windSpeed > StageModelSpec.windSpeedMax
                            ? StageModelSpec.windSpeedMax
                            : hourForecast.windSpeed
        // convert the wind speed [km/h] to [m/s] with the stage speed coefficient
        let windSpeedMPS = windSpeedKPH * 1_000 / 60 / 60 / StageModelSpec.windSpeedStageCoefficient
        // move clouds on the X axis
        cloudEntities.forEach { entity in
            var newX = entity.position.x + Float(windSpeedMPS * deltaTime) // [m/s] * dT
            // when x will be cloud-width * N plus cloud-width/2, change the sign + to -
            // to flip the x-position
            if newX > StageModelSpec.cloudSize.x
                * Float(StageModelSpec.terrainModelSpecs[modelIndex].cloudNumberXZ.x / 2)
                + StageModelSpec.cloudSize.x / 2 {
                newX *= -1
            }
            entity.position = SIMD3<Float>(newX,
                                      entity.position.y,
                                      entity.position.z)
            // clipping
            let squareDistance = entity.position.x * entity.position.x
                                + entity.position.y * entity.position.y
                                + entity.position.z * entity.position.z
            entity.isEnabled =
                squareDistance <= StageModelSpec.terrainModelSpecs[modelIndex].squareStageRadius
                ? true : false
        }
        // move rain or snow on the Y aixs
        for index in 0 ..< rainEntities.count {
            let entity = rainEntities[index]
            var newY = entity.position.y - Float(rainFallSpeed[index] * deltaTime)
            if newY < 0.015 {
                newY = StageModelSpec.terrainModelSpecs[modelIndex].cloudsPosition.y + 0.015
                rainFallSpeed[index] = rainFallSpeedBase * Double.random(in: 0.8 ... 1.2)
            }
            entity.position = SIMD3<Float>(entity.position.x,
                                           newY,
                                           entity.position.z)
        }
    }
}

extension ARScene {
    // MARK: setup

    func setup(modelIndex: Int) {
        self.modelIndex = modelIndex
        // prepare the cloud grid
        prepareCloudGrid()
    }

    private func prepareCloudGrid() {
        cloudGrid = []
        for zindex in 0 ..< StageModelSpec.terrainModelSpecs[modelIndex].cloudNumberXZ.z {
            for xindex in 0 ..< StageModelSpec.terrainModelSpecs[modelIndex].cloudNumberXZ.x {
                let xpos = Float(xindex) * StageModelSpec.cloudSize.x
                            - Float(StageModelSpec.terrainModelSpecs[modelIndex].cloudNumberXZ.x / 2)
                                * StageModelSpec.cloudSize.x
                            + Float.random(in: -0.01 ... 0.01)
                let zpos = Float(zindex) * StageModelSpec.cloudSize.z
                            - Float(StageModelSpec.terrainModelSpecs[modelIndex].cloudNumberXZ.z / 2)
                                * StageModelSpec.cloudSize.z
                            + Float.random(in: -0.01 ... 0.01)
                let ypos = Float.random(in: -0.01 ... 0.02)
                cloudGrid.append(SIMD3<Float>(xpos, ypos, zpos))
            }
        }
    }

    // MARK: update

    func update(hourForecast: HourForecast, scale: Int) {
        self.hourForecast = hourForecast
        self.scaleIndex = scale

        if let entity = baseEntity {
            anchor.removeChild(entity)
            baseEntity = nil
        } else {
            // do nothing. this is the first time.
        }

        assert(baseEntity == nil)
        baseEntity = Entity()
        let posAndScale = StageModelSpec.stagePositionAndScale(modelIndex: modelIndex,
                                                               scaleIndex: scaleIndex)
        // set the stage model in front of the camera
        // it is necessary to handle camera rotation and position due to the space heading to north
        let modifiedPosition: SIMD3<Float>
//        if isFirstTime {
//            // when the first time, the camera's transformation is not stable
//            modifiedPosition = .zero
//            isFirstTime = false
//        } else {
            // modify the initial baseEntity position due to heading to north
            modifiedPosition = simd_act(arView.cameraTransform.rotation, SIMD3<Float>(0, 0, -0.3))
                                    + arView.cameraTransform.translation
                                    + posAndScale.position
//        }
        debugLog("AR: camera rotation = \(arView.cameraTransform.rotation)")
        debugLog("AR: camera position = \(arView.cameraTransform.translation)")
        debugLog("AR: modified position = \(modifiedPosition)")
        baseEntity?.position = modifiedPosition // posAndScale.position
        baseEntity?.scale = posAndScale.scale
        anchor.addChild(baseEntity!)

        if let baseModel = AssetManager.shared.loadAndCloneModelEntity(name:
                                                            StageModelSpec.baseFilename) {
            baseEntity?.addChild(baseModel)
            setupSkydome(of: baseModel)
        } else {
            assertionFailure("AR: failed to load the base-model. \(StageModelSpec.baseFilename)")
            // Do nothing in release mode because this won't happen.
        }

        if let terrainModel = AssetManager.shared.loadAndCloneModelEntity(name:
                                    StageModelSpec.terrainModelSpecs[modelIndex].filename) {
            baseEntity?.addChild(terrainModel)
            setupTerrain(of: terrainModel)
        } else {
            // swiftlint:disable line_length
            assertionFailure("AR: failed to load the terrain-model. \(StageModelSpec.terrainModelSpecs[modelIndex].filename)")
            // Do nothing in release mode because this won't happen.
        }

        // generate clouds and add them to the base-entity
        setupClouds()

        // generate rain or snow and add them to the base-entity
        setupRain()
    }

    // setup Skydome

    private func setupSkydome(of model: ModelEntity) {
        assert(model.model?.materials.count == 4, "The base model should have four materials.")
        // materials[0]: sky-dome's material
        if let pbMaterial = model.model?.materials[0] as? PhysicallyBasedMaterial {
            var modifiedMaterial = pbMaterial
            modifiedMaterial.emissiveColor.color = StageModelSpec.skydomeColor(isDaylight: hourForecast.isDaylight,
                                                                               condition: hourForecast.condition)
            model.model?.materials[0] = modifiedMaterial
        } else {
            assertionFailure("AR: failed to access to the material of the skydome model.")
            // do nothing in the release mode
        }
    }

    // setup Terrain

    private func setupTerrain(of model: ModelEntity) {
        let colors = StageModelSpec.terrainColors(modelIndex: modelIndex,
                                                  isDaylight: hourForecast.isDaylight,
                                                  condition: hourForecast.condition)

        for index in 0 ..< colors.count {
            if let pbMaterial = model.model?.materials[index] as? PhysicallyBasedMaterial {
                var modifiedMaterial = pbMaterial
                modifiedMaterial.emissiveColor.color = colors[index]
                model.model?.materials[index] = modifiedMaterial
            } else {
                assertionFailure("AR: failed to access to the material of the terrain model. index = \(index)")
                // do nothing in the release mode
            }
        }
    }

    // setup Clouds

    private func setupClouds() {
        // calculate the number of clouds and their positions according to the cover rate (0.0 to 1.0)
        let positions = calculateCloudPositions(cover: hourForecast.cloudCover)
        // generate cloud model-entities
        cloudEntities = generateClouds(at: positions)
        // setup the cloud-base-entity
        let cloudBaseEntity = Entity()
        let windDirection = hourForecast.windDirection // [degrees] (0:N, 90:E, 180:S, 270:W)
        let angleInDegrees = -90 - windDirection // [degrees]
        let angleInRadian = Double.radianFrom(degree: angleInDegrees)

        cloudBaseEntity.orientation = simd_quatf(angle: Float(angleInRadian), axis: SIMD3<Float>(0, 1, 0))
        baseEntity?.addChild(cloudBaseEntity)
        // add them to the base-entity
        cloudEntities.forEach { entity in
            cloudBaseEntity.addChild(entity)
        }
    }

    // Calculate cloud's positions in X-Z plane
    // Y positions are given by StageModelSpec but small rand number can be applied.
    private func calculateCloudPositions(cover: Double) -> ArraySlice<SIMD3<Float>> {
        guard cover > 0 else { return [] }

        cloudGrid.shuffle()
        let number = Int(Double(cloudGrid.count) * cover)
        return cloudGrid.prefix(number)
    }

    private func generateClouds(at positions: ArraySlice<SIMD3<Float>>) -> [ModelEntity] {
        guard !positions.isEmpty else { return [] }

        var models: [ModelEntity] = []
        if let cloudModel = AssetManager.shared.loadAndCloneModelEntity(name: StageModelSpec.cloudFilename) {
            if let pbMaterial = cloudModel.model?.materials[0] as? PhysicallyBasedMaterial {
                var modifiedMaterial = pbMaterial
                modifiedMaterial.emissiveColor.color = StageModelSpec.cloudColor(isDaylight: hourForecast.isDaylight,
                                                                                 condition: hourForecast.condition)
                cloudModel.model?.materials[0] = modifiedMaterial

                models = positions.compactMap { position in
                    let model = cloudModel.clone(recursive: true)
                    model.position = position + StageModelSpec.terrainModelSpecs[modelIndex].cloudsPosition
                    return model
                }
            } else {
                assertionFailure("AR: failed to access to the material of the cloud model.")
                // do nothing in the release mode
            }
        } else {
            assertionFailure("AR: failed to load the cloud model.")
            // do nothing in the release mode
        }

        return models
    }

    // MARK: setup Rain or Snow

    private func setupRain() {
        rainEntities = []
        rainFallSpeed = []
        guard hourForecast.precipitationAmount != 0 else { return }

        let rainMaxNumber: Double = StageModelSpec.rainMaxNumber // [rains/unit]
        let rainAmountMax: Double = StageModelSpec.rainAmountMax // Precipitation Amount Max [mm]
        let rainAmount = hourForecast.precipitationAmount > rainAmountMax ?
                            rainAmountMax : hourForecast.precipitationAmount
        let rainRate = rainAmount / rainAmountMax
        let rainNumber = Int(rainMaxNumber * rainRate)
        guard rainNumber != 0 else { return }

        rainEntities = generateRains(rainNumber: rainNumber)
        rainFallSpeedBase = StageModelSpec.rainFallSpeed * rainRate
                                + StageModelSpec.rainFallSpeed // [m/s]
        rainFallSpeed = rainEntities.map { _ in rainFallSpeedBase }

        let rainBaseEntity = Entity()
        let windAngle = Float(Double.radianFrom(degree: hourForecast.windDirection))
        // when wind speed > 10 [km/h], rain angle is PI/16
        let rainAngle = hourForecast.windSpeed > StageModelSpec.rainWindSpeedMin
                        ? Float.pi / 16 : 0
        rainBaseEntity.orientation = simd_quatf(angle: -windAngle, axis: SIMD3<Float>(0, 1, 0))
                                    * simd_quatf(angle: -rainAngle, axis: SIMD3<Float>(1, 0, 0))

        baseEntity?.addChild(rainBaseEntity)
        rainEntities.forEach { entity in
            rainBaseEntity.addChild(entity)
        }
    }

    private func generateRains(rainNumber: Int) -> [ModelEntity] {
        var models: [ModelEntity] = []

        for unitIndex in 0 ..< 7 { // eight rain units
            if let model = generateRainSquare(rainNumber: rainNumber) {
                model.position = StageModelSpec.terrainModelSpecs[modelIndex].cloudsPosition
                + SIMD3<Float>(0,
                               Float(unitIndex) * -StageModelSpec.rainUnitHeight / 2
                               - StageModelSpec.rainUnitHeight / 2,
                               0)
                models.append(model)
            }
        }

        return models
    }

    // swiftlint:disable function_body_length
    private func generateRainSquare(rainNumber: Int) -> ModelEntity? {
        let width = StageModelSpec.rainSquareWidth   // rain or snow width [m]
        let height = hourForecast.condition == .snow
        ? StageModelSpec.snowSquareHeight            // snow height [m]
        : StageModelSpec.rainSquareHeight            // rain height [m]

        var positions: [SIMD3<Float>] = []
        var counts: [UInt8] = []
        var indices: [UInt32] = []
        for rainIndex in 0 ..< rainNumber {
            // fallRadius = stage radius - 0.01 [m] ... excepting edge 1 cm
            let fallRadius = StageModelSpec.terrainModelSpecs[modelIndex].stageRadius - 0.01
            let radius = Float.random(in: -fallRadius ... fallRadius)
            let angle = Float.random(in: -Float.pi * 2 ... Float.pi * 2)
            let yoffset = Float.random(in:
                -(StageModelSpec.rainUnitHeight - StageModelSpec.rainSquareHeight) ... 0)
            let origin = SIMD3<Float>(radius * cosf(angle),
                                      yoffset,
                                      radius * sinf(angle))

            positions.append(contentsOf: [
                // top vertex positions
                SIMD3<Float>(origin.x + width / 2, origin.y, origin.z - width / 2 ), // #0
                SIMD3<Float>(origin.x - width / 2, origin.y, origin.z - width / 2 ), // #1
                SIMD3<Float>(origin.x - width / 2, origin.y, origin.z + width / 2 ), // #2
                SIMD3<Float>(origin.x + width / 2, origin.y, origin.z + width / 2 ), // #3
                // bottom vertex positions
                SIMD3<Float>(origin.x + width / 2, origin.y - height, origin.z - width / 2 ), // #4
                SIMD3<Float>(origin.x - width / 2, origin.y - height, origin.z - width / 2 ), // #5
                SIMD3<Float>(origin.x - width / 2, origin.y - height, origin.z + width / 2 ), // #6
                SIMD3<Float>(origin.x + width / 2, origin.y - height, origin.z + width / 2 ) // #7
            ])
            counts.append(contentsOf: [4, 4, 4, 4, 4, 4]) // six faces, four vertices each
            let offset = UInt32(rainIndex * 8) // 8 vertices per rain-square
            indices.append(contentsOf:
                            [0, 1, 2, 3, // face 0 (top: +y)
                             0, 3, 7, 4, // face 1 (+x)
                             0, 4, 5, 1, // face 2 (-z)
                             2, 1, 5, 6, // face 3 (-x)
                             3, 2, 6, 7, // face 4 (+z)
                             7, 6, 5, 4].map { // face 5 (bottom: -y)
                $0 + offset
            })
        }

        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.primitives = .polygons(counts, indices)
        descriptor.materials = .allFaces(0)

        let color = StageModelSpec.rainColor(isDaylight: hourForecast.isDaylight,
                                             condition: hourForecast.condition)
        let material = UnlitMaterial(color: color)
        var model: ModelEntity?
        if let mesh = try? MeshResource.generate(from: [descriptor]) {
            model = ModelEntity(mesh: mesh, materials: [material])
        }
        return model
    }
}

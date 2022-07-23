//
//  AssetManager.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import Foundation
import RealityKit

class AssetManager {
    static let shared = AssetManager()

    // private var cachedEntities: [String: Entity] = [:]
    private var cachedModelEntities: [String: ModelEntity] = [:]

    private init() { }

    //    func loadAndCloneEntity(name: String) -> Entity? {
    //        debugLog("AM: loadAndCloneEntity(name: \(name)) was called.")
    //        // load the Entity of the file name
    //        guard let entity = loadEntity(name: name) else { return nil }
    //        // clone it
    //        return entity.clone(recursive: true)
    //    }

    func loadAndCloneModelEntity(name: String) -> ModelEntity? {
        debugLog("AM: loadAndCloneModelEntity(name: \(name)) was called.")
        // load the ModelEntity of the file name
        guard let model = loadModelEntity(name: name) else { return nil }
        // clone it
        return model.clone(recursive: true)
    }

    private func loadModelEntity(name: String) -> ModelEntity? {
        var resultModelEntity: ModelEntity?
        if let cachedModelEntity = cachedModelEntities[name] {
            resultModelEntity = cachedModelEntity
            debugLog("AM: the loading model-entity, \(name), from the cache.")
        } else {
            if let model = try? ModelEntity.loadModel(named: name) {
                cachedModelEntities[name] = model
                resultModelEntity = model
                debugLog("AM: the model, \(name), has been loaded.")
            } else {
                assertionFailure("AM: failed to load the Model, \(name).")
                // Do nothing in the release mode because this won't happen.
                // Just return nil.
            }
        }
        return resultModelEntity
    }

    //    private func loadEntity(name: String) -> Entity? {
    //        var resultEntity: Entity?
    //        if let cachedEntity = cachedEntities[name] {
    //            resultEntity = cachedEntity
    //            debugLog("AM: the loading model, \(name), is in the cache.")
    //        } else {
    //            if let entity = try? Entity.load(named: name) {
    //                cachedEntities[name] = entity
    //                resultEntity = entity
    //                debugLog("AM: the loading model, \(name), has been loaded.")
    //            } else {
    //                assertionFailure("AM: failed to load the Model, \(name).")
    //                // Do nothing in the release mode because this won't happen.
    //                // Just return nil.
    //            }
    //        }
    //        return resultEntity
    //    }
}

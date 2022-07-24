//
//  SoundManager.swift
//  arweatherinformation
//
//  Created by Yasuhito Nagatomo on 2022/06/27.
//

import Foundation
import AVFoundation

final class SoundManager {
    static let share = SoundManager()
    var enable = true

    enum SoundKind: Int {
        case hourflip = 0
        case scaleup
        case hourflipend
    }

    private var players: [AVAudioPlayer?] = []

    private init() {
        // register default sounds

        // 0) Hourly Weather Flipping Sound
        let player0 = try? AVAudioPlayer(
            contentsOf: Bundle.main.url(forResource: "hourflip",
                                        withExtension: "m4a")!)
        player0?.prepareToPlay() // load the sound data into a buffer
        players.append(player0)

        // 1) Scale up Sound
        let player1 = try? AVAudioPlayer(
            contentsOf: Bundle.main.url(forResource: "scaleup",
                                        withExtension: "mp3")!)
        player1?.prepareToPlay() // load the sound data into a buffer
        players.append(player1)

        // 2) Hourly Weather Flipping End Sound
        let player2 = try? AVAudioPlayer(
            contentsOf: Bundle.main.url(forResource: "hourflipReset",
                                        withExtension: "m4a")!)
        player2?.prepareToPlay()
        players.append(player2)
    }

    func setup(_ enable: Bool) {
        self.enable = enable
    }

    func play(_ soundKind: SoundKind) {
        guard enable else { return }

        if let audioPlayer = players[soundKind.rawValue] {
            audioPlayer.pause()  // keep the buffer
            audioPlayer.currentTime = 0.0
            audioPlayer.play()
        }
    }

    func stop(_ soundKind: SoundKind) {
        if let audioPlayer = players[soundKind.rawValue] {
            audioPlayer.pause() // keep the buffer
        }
    }
}

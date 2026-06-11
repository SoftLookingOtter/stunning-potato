//
//  PlaybackService.swift
//  Echoes
//
//  Created by Ibrahim Jasim Alsalih on 2026-06-11.
//

import AVFoundation
import Observation


@Observable
final class PlaybackService {
    private var player: AVAudioPlayer?

    var isPlaying: Bool = false

    func play(path: String) {
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true
        } catch{
            print("Kunde inte spela upp: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        player = nil
    }
    
    func toggle(path: String) {
        if isPlaying {
            stop()
        } else {
            play(path: path)
        }
    }
    
}

//
//  RecordViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import Foundation
import Observation

@Observable

final class RecordViewModel {
    
    private let audioService = AudioService()
    
    var isRecording = false
    var recordedAudioURL: URL?
    
    func toggleRecording() {
        
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
        
    }
    
    private func startRecording() {
        
        audioService.startRecording()
        isRecording = true
    }
    
    private func stopRecording() {
        
        audioService.stopRecording()
        
        recordedAudioURL = audioService.getRecordedAudioURL()
        isRecording = false
    }
}


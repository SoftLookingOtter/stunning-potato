//
//  RecordViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import Foundation
import Observation
import SwiftData

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

    /// Persists the latest recording as an EchoMemory in the given context.
    /// No-op if there is no recorded URL yet.
    @discardableResult
    func saveEcho(
        in context: ModelContext,
        title: String,
        story: String,
        category: MemoryCategory,
        latitude: Double,
        longitude: Double
    ) -> EchoMemory? {
        guard let url = recordedAudioURL else { return nil }
        let echo = EchoMemory(
            recordingAt: url,
            title: title,
            story: story,
            category: category,
            latitude: latitude,
            longitude: longitude
        )
        context.insert(echo)
        try? context.save()
        return echo
    }
}

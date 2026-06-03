//
//  RecordViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

import Foundation
import Observation
import SwiftData

@Observable
final class RecordViewModel {

    private let audioService = AudioService()

    var isRecording = false
    var recordedAudioURL: URL?
    var errorMessage = ""

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        errorMessage = ""

        let didStartRecording = audioService.startRecording()

        if didStartRecording {
            isRecording = true
        } else {
            isRecording = false
            errorMessage = "Mikrofonbehörighet saknas. Ge behörighet i onboarding eller i iOS-inställningar."
        }
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
        guard let url = recordedAudioURL else {
            errorMessage = "Du behöver spela in ett ljud innan du kan spara minnet."
            return nil
        }

        let echo = EchoMemory(
            recordingAt: url,
            title: title,
            story: story,
            category: category,
            latitude: latitude,
            longitude: longitude
        )

        echo.discoveredAt = Date()

        context.insert(echo)
        try? context.save()

        errorMessage = ""
        return echo
    }
}

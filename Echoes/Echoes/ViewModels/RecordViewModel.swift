//
//  RecordViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-05.
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

    // Persists the latest recording as an EchoMemory in the given context.
    // Returns nil if required data is missing.
    @discardableResult
    func saveEcho(
        in context: ModelContext,
        title: String,
        story: String,
        category: MemoryCategory,
        latitude: Double,
        longitude: Double,
        imageName: String?
    ) -> EchoMemory? {
        errorMessage = ""

        guard let url = recordedAudioURL else {
            errorMessage = "Du behöver spela in ett ljud innan du kan spara minnet."
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStory = story.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Du behöver ge minnet en titel."
            return nil
        }

        guard !trimmedStory.isEmpty else {
            errorMessage = "Du behöver skriva en kort berättelse."
            return nil
        }

        guard let imageName else {
            errorMessage = "Du behöver lägga till en bild."
            return nil
        }

        let echo = EchoMemory(
            recordingAt: url,
            title: trimmedTitle,
            story: trimmedStory,
            category: category,
            latitude: latitude,
            longitude: longitude
        )

        echo.imageName = imageName
        echo.discoveredAt = Date()

        context.insert(echo)

        do {
            try context.save()
            errorMessage = ""
            return echo
        } catch {
            errorMessage = "Minnet kunde inte sparas. Försök igen."
            return nil
        }
    }

    // Discards an unsaved recording and deletes the temporary audio file.
    func discardRecording() {
        if let recordedAudioURL {
            try? FileManager.default.removeItem(at: recordedAudioURL)
        }

        recordedAudioURL = nil
        errorMessage = ""
    }

    // Clears the current recording reference after saving.
    // This does not delete the saved audio file.
    func clearRecordingAfterSave() {
        recordedAudioURL = nil
        errorMessage = ""
    }
}

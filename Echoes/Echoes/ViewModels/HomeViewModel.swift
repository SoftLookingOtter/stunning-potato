//
//  HomeViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-28.
//  Updated by Sara Lindén on 2026-06-03
//

import SwiftData
import Foundation
import Observation

@Observable
final class HomeViewModel {

    @ObservationIgnored private let audioService = AudioService()

    // MARK: - Filter state

    /// Persisted to UserDefaults so the chosen category survives app restarts.
    var selectedCategory: MemoryCategory? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: "selectedCategory") else { return nil }
            return MemoryCategory(rawValue: raw)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: "selectedCategory")
        }
    }

    var searchText: String = ""

    // MARK: - SwiftData: hämta alla echoes

    static func allEchoesDescriptor() -> FetchDescriptor<EchoMemory> {
        var descriptor = FetchDescriptor<EchoMemory>(
            sortBy: [SortDescriptor(\.discoveredAt, order: .reverse)]
        )
        descriptor.fetchLimit = 200
        return descriptor
    }

    // MARK: - SwiftData: filtrera echoes på kategori och söktext

    func filtered(_ echoes: [EchoMemory]) -> [EchoMemory] {
        echoes.filter { echo in
            let matchesCategory = selectedCategory == nil || echo.category == selectedCategory

            let matchesSearch = searchText.isEmpty
                || echo.title.localizedCaseInsensitiveContains(searchText)
                || echo.story.localizedCaseInsensitiveContains(searchText)

            return matchesCategory && matchesSearch
        }
    }

    // MARK: - SwiftData: skapa nya EchoMemory-objekt

    @discardableResult
    func createEcho(
        title: String,
        story: String,
        category: MemoryCategory,
        latitude: Double,
        longitude: Double,
        audioURL: URL? = nil,
        in context: ModelContext
    ) -> EchoMemory {
        let discoveredAt = Date()
        let echo: EchoMemory

        if let url = audioURL {
            echo = EchoMemory(
                recordingAt: url,
                title: title,
                story: story,
                category: category,
                latitude: latitude,
                longitude: longitude
            )
        } else {
            echo = EchoMemory(
                title: title,
                story: story,
                category: category,
                latitude: latitude,
                longitude: longitude
            )
        }

        echo.discoveredAt = discoveredAt

        context.insert(echo)
        try? context.save()

        return echo
    }
    
    // MARK: - SwiftData: uppdatera likes/plays lokalt

    func like(_ echo: EchoMemory, auth: AuthViewModel, in context: ModelContext) {
        echo.likes += 1
        auth.incrementLikes(context: context)
        try? context.save()
    }

    func play(_ echo: EchoMemory, auth: AuthViewModel, in context: ModelContext) {
        if let path = echo.audioFilePath {
            let url = URL(fileURLWithPath: path)
            audioService.playRecording(url: url)
            print("▶️ Spelar upp: \(path)")
        }else{
            print("❌ Ingen ljudfil hittades")
        }
        echo.plays += 1
        auth.incrementPlays(context: context)
        try? context.save()
    }
}

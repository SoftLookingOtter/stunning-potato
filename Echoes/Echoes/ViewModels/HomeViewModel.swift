//
//  HomeViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Implemented by Ibrahim on 2026-05-28.
//

import SwiftData
import Foundation
import Observation

@Observable
final class HomeViewModel {

    // MARK: - Filter state

    /// When nil, all categories are shown.
    var selectedCategory: MemoryCategory? = nil
    var searchText: String = ""

    // MARK: - SwiftData: hämta alla echoes
    //
    // Views use @Query to get the live array, then pass it here.
    // This keeps the ViewModel testable without a live ModelContext.

    static func allEchoesDescriptor() -> FetchDescriptor<EchoMemory> {
        var descriptor = FetchDescriptor<EchoMemory>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 200
        return descriptor
    }

    // MARK: - SwiftData: filtrera echoes på kategori

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
        context.insert(echo)
        try? context.save()
        return echo
    }

    // MARK: - SwiftData: uppdatera likes/plays lokalt

    func like(_ echo: EchoMemory, in context: ModelContext) {
        echo.likes += 1
        try? context.save()
    }

    func play(_ echo: EchoMemory, in context: ModelContext) {
        echo.plays += 1
        try? context.save()
    }
}

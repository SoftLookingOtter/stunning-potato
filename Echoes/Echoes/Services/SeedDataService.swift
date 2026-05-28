//
//  SeedDataService.swift
//  Echoes
//
//  
//  Implemented by Ibrahim on 2026-05-18.

import SwiftData
import Foundation

/// Fills the database with demo echoes the first time the app launches.
/// Safe to call on every launch – it checks the count first and exits early if data exists.
struct SeedDataService {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<EchoMemory>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let echoes: [EchoMemory] = [
            makeEcho(
                title: "Morfars cykelverkstad",
                story: "Min morfar hade en liten cykelverkstad just här på 1960-talet. Lukten av olja och metall lever kvar i minnet som om det vore igår.",
                category: .family,
                lat: 59.3293, lon: 18.0686
            ),
            makeEcho(
                title: "Den mystiska natten 1923",
                story: "Det sägs att en oktobernatt 1923 hände något oförklarligt på denna plats. Ingen vet vad, men ryktet lever fortfarande.",
                category: .mysterious,
                lat: 59.3310, lon: 18.0700
            ),
            makeEcho(
                title: "Torgets hundra år",
                story: "Det här torget har sett marknader, demonstrationer och otaliga möten. En plats där stadens historia utspelar sig varje dag.",
                category: .historical,
                lat: 59.3320, lon: 18.0650
            ),
            makeEcho(
                title: "Sommaren -89",
                story: "Den sommaren träffade jag min bästa vän precis här. Vi var tio år gamla och världen kändes oändlig.",
                category: .nostalgic,
                lat: 59.3280, lon: 18.0720
            ),
            makeEcho(
                title: "Gamla biografen",
                story: "Här låg stadens första biograf. Varje lördag stod folk i kö längs hela gatan för att se en film.",
                category: .historical,
                lat: 59.3300, lon: 18.0660
            ),
            makeEcho(
                title: "Farmors röst",
                story: "Min farmor brukade berätta sagor på den här bänken när jag var liten. Jag saknar hennes röst varje dag.",
                category: .family,
                lat: 59.3270, lon: 18.0710
            )
        ]

        echoes.forEach { context.insert($0) }
        try? context.save()
    }

    // MARK: - Private helper
    private static func makeEcho(
        title: String,
        story: String,
        category: MemoryCategory,
        lat: Double,
        lon: Double
    ) -> EchoMemory {
        EchoMemory(
            title: title,
            story: story,
            category: category,
            latitude: lat,
            longitude: lon
        )
    }
}

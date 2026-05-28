//
//  SeedDataService.swift
//  Echoes
//
//  Implemented by Ibrahim on 2026-05-28.

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
                lat: 59.3293, lon: 18.0686,
                daysAgo: 3, likes: 14, plays: 27
            ),
            makeEcho(
                title: "Den mystiska natten 1923",
                story: "Det sägs att en oktobernatt 1923 hände något oförklarligt på denna plats. Ingen vet vad, men ryktet lever fortfarande.",
                category: .mysterious,
                lat: 59.3310, lon: 18.0700,
                daysAgo: 7, likes: 31, plays: 58
            ),
            makeEcho(
                title: "Torgets hundra år",
                story: "Det här torget har sett marknader, demonstrationer och otaliga möten. En plats där stadens historia utspelar sig varje dag.",
                category: .historical,
                lat: 59.3320, lon: 18.0650,
                daysAgo: 12, likes: 42, plays: 81
            ),
            makeEcho(
                title: "Sommaren -89",
                story: "Den sommaren träffade jag min bästa vän precis här. Vi var tio år gamla och världen kändes oändlig.",
                category: .nostalgic,
                lat: 59.3280, lon: 18.0720,
                daysAgo: 1, likes: 8, plays: 16
            ),
            makeEcho(
                title: "Gamla biografen",
                story: "Här låg stadens första biograf. Varje lördag stod folk i kö längs hela gatan för att se en film.",
                category: .historical,
                lat: 59.3300, lon: 18.0660,
                daysAgo: 20, likes: 55, plays: 103
            ),
            makeEcho(
                title: "Farmors röst",
                story: "Min farmor brukade berätta sagor på den här bänken när jag var liten. Jag saknar hennes röst varje dag.",
                category: .family,
                lat: 59.3270, lon: 18.0710,
                daysAgo: 5, likes: 23, plays: 44
            ),
            makeEcho(
                title: "Stationens första tåg",
                story: "1871 rullade det första ångtåget in på denna perrong. Folk stod packade längs spåret och vinkade med hattar.",
                category: .historical,
                lat: 59.3303, lon: 18.0590,
                daysAgo: 30, likes: 67, plays: 120
            ),
            makeEcho(
                title: "Nattens hemlighet",
                story: "Varje midnatt, sägs det, hörs steg i korridoren ovan. Ingen har kunnat förklara det sedan huset byggdes.",
                category: .mysterious,
                lat: 59.3340, lon: 18.0730,
                daysAgo: 2, likes: 19, plays: 35
            ),
            makeEcho(
                title: "Midsommarminnen",
                story: "Vi dansade runt stången i timmar. Mamma fotade, pappa spelade dragspel. Lyktorna lyste hela natten.",
                category: .nostalgic,
                lat: 59.3260, lon: 18.0680,
                daysAgo: 9, likes: 12, plays: 22
            ),
            makeEcho(
                title: "Lillasysters födelsedag",
                story: "Det var här vi firade hennes treårsdag med tårta och ballonger. Hon trodde hela parken var för hennes skull.",
                category: .family,
                lat: 59.3285, lon: 18.0640,
                daysAgo: 14, likes: 9, plays: 18
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
        lon: Double,
        daysAgo: Int,
        likes: Int,
        plays: Int
    ) -> EchoMemory {
        let echo = EchoMemory(
            title: title,
            story: story,
            date: Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(),
            category: category,
            latitude: lat,
            longitude: lon
        )
        echo.likes = likes
        echo.plays = plays
        return echo
    }
}

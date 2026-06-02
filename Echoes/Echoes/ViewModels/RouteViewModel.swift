//
//  RouteViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-30.
//  Implemented by Ibrahim on 2026-06-02.
//

import SwiftData
import Foundation
import Observation

@Observable
final class RouteViewModel {

    // MARK: - FetchDescriptor used by @Query in views
    static func allRoutesDescriptor() -> FetchDescriptor<Route> {
        FetchDescriptor<Route>(sortBy: [SortDescriptor(\.date, order: .reverse)])
    }

    // MARK: - Create a new Route and save it
    @discardableResult
    func createRoute(title: String, description: String, context: ModelContext) -> Route {
        let route = Route(title: title, routeDescription: description)
        context.insert(route)
        try? context.save()
        return route
    }

    // MARK: - Link an EchoMemory to a Route and save
    func addEcho(_ echo: EchoMemory, to route: Route, context: ModelContext) {
        echo.route = route
        if !route.echoes.contains(where: { $0.id == echo.id }) {
            route.echoes.append(echo)
        }
        try? context.save()
    }

    // MARK: - Delete a Route
    func deleteRoute(_ route: Route, context: ModelContext) {
        context.delete(route)
        try? context.save()
    }
}

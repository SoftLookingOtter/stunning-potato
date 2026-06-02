//
//  RouteViewModel.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-30

import Foundation
import Observation

@Observable
final class RouteViewModel {
    
    let routes: [Route]
    
    init() {
        
        routes = [
            
            Route(
                title: "Linköpings gamla handel"
            ),
            
            Route(
                title: "Stadens spöken"
            ),
            
            Route(
                title: "Stadshistoria 1800-talet"
            )
        ]
    }
}


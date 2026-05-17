//
//  Item.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

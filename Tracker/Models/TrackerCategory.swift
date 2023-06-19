//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

struct TrackerCategory {
    let id: UUID
    let label: String
    
    init(id: UUID = UUID(), label: String) {
        self.id = id
        self.label = label
    }
}

//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

struct TrackerCategory {
    let label: String
    let trackers: [Tracker]
    
    init(label: String, trackers: [Tracker]) {
        self.label = label
        self.trackers = trackers
    }
}

extension TrackerCategory {
    static let sampleData: [TrackerCategory] = [
        TrackerCategory(
            label: "Домашний уют",
            trackers: []
        ),
        TrackerCategory(
            label: "Радостные мелочи",
            trackers: []
        )
    ]
}

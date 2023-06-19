//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import Foundation

struct TrackerRecord: Hashable {
    let id: UUID
    let trackerId: UUID
    let date: Date
    
    init(id: UUID = UUID(), trackerId: UUID, date: Date) {
        self.id = id
        self.trackerId = trackerId
        self.date = date
    }
}

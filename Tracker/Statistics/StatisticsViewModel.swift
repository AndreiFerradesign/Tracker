//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Andrei Kashin on 26.06.2023.
//

import Foundation

final class StatisticsViewModel {
    var onTrackersChange: (([TrackerRecord]) -> Void)?
    
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [TrackerRecord] = [] {
        didSet {
            onTrackersChange?(trackers)
        }
    }
    
    func viewWillAppear() {
        guard let trackers = try? trackerRecordStore.loadCompletedTrackers() else { return }
        self.trackers = trackers
    }
}

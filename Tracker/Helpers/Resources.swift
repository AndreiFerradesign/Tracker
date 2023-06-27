//
//  Resources.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

enum Resources {
    
    enum Strings {
        enum TabBar {
            static var statistic = NSLocalizedString("tabbar.statistics", tableName: "Localizable", comment: "tabbar.statistics")
            static var tracker = NSLocalizedString("tabbar.trackers", tableName: "Localizable", comment: "tabbar.trackers")
        }
    }
    
    enum Images {
        enum TabBar {
            static var statistic = UIImage(named: "statistic")
            static var tracker = UIImage(named: "tracker")
        }
        enum Error {
            static var errorTracker = UIImage(named: "errorTracker")
            static var errorStatistic = UIImage(named: "errorStatistic")
        }
        enum Empty {
            static var emptyTracker = UIImage(named: "Star")
        }
    }
}

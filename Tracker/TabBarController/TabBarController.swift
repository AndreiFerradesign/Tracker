//
//  TabBarController.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

enum Tabs: Int {
    case tracker
    case statistic
}

final class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        tabBar.tintColor = .yaBlue
        tabBar.barTintColor = .yaGray
        tabBar.backgroundColor = .yaWhite
        
//        tabBar.layer.borderColor = UIColor.yaWhite.cgColor
//        tabBar.layer.borderWidth = 1
//        tabBar.layer.masksToBounds = true
        
        let trackerViewController = TrackerController()
        let statisticViewController = StatisticController()
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.tracker,
            image: Resources.Images.TabBar.tracker,
            tag: Tabs.tracker.rawValue)
        statisticViewController.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.statistic,
            image: Resources.Images.TabBar.statistic,
            tag: Tabs.statistic.rawValue)
        
        let controllers = [trackerViewController,
                           statisticViewController]
        
        viewControllers = controllers
    }
    
}

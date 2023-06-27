//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Andrei Kashin on 26.06.2023.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "Your API Key here") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}

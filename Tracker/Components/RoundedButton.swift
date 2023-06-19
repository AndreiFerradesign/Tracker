//
//  Button.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

final class RoundedButton: UIButton {
    convenience init(color: UIColor = .yaBlack, titleColor: UIColor = .yaWhite, title: String) {
        self.init(type: .system)
        
        setTitle(title, for: .normal)
        backgroundColor = color
        
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
    }
}

// MARK: - Layout methods

extension RoundedButton {
    static func redButton(title: String) -> Self {
        let button = self.init(color: .clear, title: title)
        
        button.setTitleColor(.yaRed, for: .normal)
        button.layer.borderColor = UIColor.yaRed.cgColor
        button.layer.borderWidth = 1
        
        return button
    }
}

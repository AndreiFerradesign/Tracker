//
//  EmojiCell.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "EmojiCell"
    
    // MARK: - Layout elements
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(with label: String) {
        emojiLabel.text = label
    }
}

// MARK: - Layout methods

extension EmojiCell {
    func setupContent() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(emojiLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // emojiLabel
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

// MARK: - SelectionCellProtocol

extension EmojiCell: SelectionCellProtocol {
    
    func select() {
        contentView.backgroundColor = .yaLightGray
    }
    
    func deselect() {
        contentView.backgroundColor = .clear
    }
}


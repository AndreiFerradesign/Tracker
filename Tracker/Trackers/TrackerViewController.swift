//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

final class TrackerController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        )!,
            target: self, action: #selector(didTapPlusButton))
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
        
    }
    
    @objc
    private func didTapPlusButton() {
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
    }
    
}
private extension TrackerController {
    func setupContent() {
        view.backgroundColor = .white
        view.addSubview(addButton)
        view.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // completeButton
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            addButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 13),

        ])
    }
}
// MARK: - AddTrackerViewControllerDelegate
extension TrackerController: AddTrackerViewControllerDelegate {
    func didSelectTracker(with type: AddTrackerViewController.TrackerType) {
        dismiss(animated: true)
    }
}

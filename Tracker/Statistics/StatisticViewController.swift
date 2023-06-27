//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

final class StatisticController: UIViewController {
    
    // MARK: - Layout elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let notFoundStack = NotFoundStack(
        label: "Анализировать пока нечего",
        image: UIImage(named: "errorStatistic")
    )
    
    private let statisticsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    private let completedTrackersView = StatisticsView(name: "Трекеров завершено")
    
    // MARK: - Properties
    
    var statisticsViewModel: StatisticsViewModel?
    private let trackerRecordStore = TrackerRecordStore()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
        setupConstraints()
        
        statisticsViewModel?.onTrackersChange = { [weak self] trackers in
            guard let self else { return }
            self.checkContent(with: trackers)
            self.setupCompletedTrackersBlock(with: trackers.count)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsViewModel?.viewWillAppear()
    }
    
    // MARK: - Private
    
    private func checkContent(with trackers: [TrackerRecord]) {
        if trackers.isEmpty {
            notFoundStack.isHidden = false
            statisticsStack.isHidden = true
        } else {
            notFoundStack.isHidden = true
            statisticsStack.isHidden = false
        }
    }
    
    private func setupCompletedTrackersBlock(with count: Int) {
        completedTrackersView.setNumber(count)
    }

}

// MARK: - Layout methods

private extension StatisticController {
    
    func setupContent() {
        view.backgroundColor = .yaWhite
        view.addSubview(titleLabel)
        view.addSubview(notFoundStack)
        view.addSubview(statisticsStack)
        statisticsStack.addArrangedSubview(completedTrackersView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            // notFoundStack
            notFoundStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            notFoundStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            // statisticsStack
            statisticsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
}

//final class StatisticController: UIViewController {
//
//    // MARK: - Properties
//
//    var statisticsViewModel: StatisticsViewModel?
//    private let trackerRecordStore = TrackerRecordStore()
//
//    // MARK: - Layout elements
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Статистика"
//        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
//        return label
//    }()
//
//    private let emptyImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = Resources.Images.Error.errorStatistic
//        return imageView
//    }()
//
//    private let emptyLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        label.text = "Анализировать пока нечего"
//        label.textColor = .yaBlack
//        return label
//    }()
//
//    private let emptyStack: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.alignment = .center
//        stack.spacing = 8
//        return stack
//    }()
//
//    private let completedTrackersView = StatisticsView(name: "Трекеров завершено")
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupContent()
//        setupConstraints()
//
//        statisticsViewModel?.onTrackersChange = { [weak self] trackers in
//            guard let self else { return }
//            self.checkContent(with: trackers)
//            self.setupCompletedTrackersBlock(with: trackers.count)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        statisticsViewModel?.viewWillAppear()
//    }
//
//    private func checkContent(with trackers: [TrackerRecord]) {
//        if trackers.isEmpty {
//            notFoundStack.isHidden = false
//            statisticsStack.isHidden = true
//        } else {
//            notFoundStack.isHidden = true
//            statisticsStack.isHidden = false
//        }
//    }
//
//    private func setupCompletedTrackersBlock(with count: Int) {
//        completedTrackersView.setNumber(count)
//    }
//
//}
//
//// MARK: - Layout methods
//
//private extension StatisticController {
//    func setupContent() {
//        view.backgroundColor = .yaWhite
//        view.addSubview(titleLabel)
//        view.addSubview(emptyStack)
//
//        emptyStack.addArrangedSubview(emptyImageView)
//        emptyStack.addArrangedSubview(emptyLabel)
//    }
//
//    func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // titleLabel
//            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            //emptyStack
//            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}


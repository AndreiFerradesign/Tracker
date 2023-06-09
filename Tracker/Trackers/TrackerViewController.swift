//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Andrei Kashin on 08.05.2023.
//

import UIKit

final class TrackerController: UIViewController {
    
    // MARK: - Properties
    
    private let analyticsService = AnalyticsService()
    private var trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let params = UICollectionView.GeometricParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        topInset: 8,
        bottomInset: 16,
        height: 148,
        cellSpacing: 10
    )
    private var categories = [TrackerCategory]()
    private var searchText = "" {
        didSet {
            try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        }
    }
    private var currentDate = Date.from(date: Date())!
    private var completedTrackers: Set<TrackerRecord> = []
    private var editingTracker: Tracker?
    
    // MARK: - Layout elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("main.title", tableName: "Localizable", comment: "main.title")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        )!,
                                           target: self, action: #selector(didTapPlusButton))
        button.tintColor = .yaBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .yaDatePickerColor
        picker.tintColor = .yaBlue
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar = Calendar(identifier: .iso8601)
        picker.maximumDate = Date()
        picker.overrideUserInterfaceStyle = .light
        picker.addTarget(self, action: #selector(didChangedDatePicker), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Поиск"
        view.searchBarStyle = .minimal
        view.delegate = self
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yaWhite
        view.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        view.register(
            TrackerCategoryLabel.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        return view
    }()
    
    private let notFoundStack = NotFoundStack(
        label: NSLocalizedString("stubTitle", tableName: "Localizable", comment: "stubTitle"),
        image: UIImage(named: "star")
    )

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("filters", tableName: "Localizable", comment: "filters"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = .yaBlue
        button.layer.cornerRadius = 16
        button.backgroundColor = .yaBlue
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(trackerStore: TrackerStoreProtocol) {
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        setupContent()
        setupConstraints()
        
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        
        try? trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
        try? trackerRecordStore.loadCompletedTrackers(by: currentDate)
        
        checkNumberOfTrackers()
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapPlusButton() {
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "add_track"
        ])
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
    }
    
    @objc
    private func didChangedDatePicker(_ sender: UIDatePicker) {
        currentDate = Date.from(date: sender.date)!
        
        do {
            try trackerStore.loadFilteredTrackers(date: currentDate, searchString: searchText)
            try trackerRecordStore.loadCompletedTrackers(by: currentDate)
        } catch {}
        collectionView.reloadData()
    }
    
    @objc
    private func didTapFilterButton() {
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "filter"
        ])
    }
    
    // MARK: - Private methods
    
    private func checkNumberOfTrackers() {
        if trackerStore.numberOfTrackers == 0 {
            notFoundStack.isHidden = false
            filterButton.isHidden = true
        } else {
            notFoundStack.isHidden = true
            filterButton.isHidden = false // filter button turn off for sprint 15
        }
    }
    
    private func presentFormController(
        with data: Tracker.Data? = nil,
        of trackerType: AddTrackerViewController.TrackerType,
        formType: TrackerFormViewController.FormType
    ) {
        let trackerFormViewController = TrackerFormViewController(
            formType: formType,
            trackerType: trackerType,
            data: data
        )
        trackerFormViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerFormViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
    
    private func onEdit(_ tracker: Tracker) {
        analyticsService.report(event: "click", params: [
            "screen": "Main",
            "item": "edit"
        ])
        
        let type: AddTrackerViewController.TrackerType = tracker.schedule != nil ? .habit : .irregularEvent
        editingTracker = tracker
        presentFormController(with: tracker.data, of: type, formType: .edit)
    }
    
    private func onDelete(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.analyticsService.report(event: "click", params: [
                "screen": "Main",
                "item": "delete"
            ])
            try? self.trackerStore.deleteTracker(tracker)
            deleteRecordTracker(with: tracker)
           
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteRecordTracker(with tracker: Tracker) {
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
            try? trackerRecordStore.remove(recordToRemove)
        }
    }
    
    private func onTogglePin(_ tracker: Tracker) {
        try? trackerStore.togglePin(for: tracker)
    }
}

// MARK: - Layout methods

private extension TrackerController {
    func setupContent() {
        view.backgroundColor = .yaWhite
        view.addSubview(addButton)
        view.addSubview(titleLabel)
        view.addSubview(datePicker)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(notFoundStack)
        view.addSubview(filterButton)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // completeButton
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            addButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            // titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 13),
            // datePicker
            datePicker.widthAnchor.constraint(equalToConstant: 110),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            // searchBar
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            // collectionView
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // notFoundStack
            notFoundStack.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            notFoundStack.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            // filterButton
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

extension TrackerController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let location = interaction.view?.convert(location, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: location),
            let tracker = trackerStore.tracker(at: indexPath)
        else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { actions in
            UIMenu(children: [
                UIAction(title: tracker.isPinned ? "Открепить" : "Закрепить") { [weak self] _ in
                    self?.onTogglePin(tracker)
                },
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.onEdit(tracker)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.onDelete(tracker)
                }
            ])
        })
    }
    
}

// MARK: - AddTrackerViewControllerDelegate

extension TrackerController: AddTrackerViewControllerDelegate {
    func didSelectTracker(with type: AddTrackerViewController.TrackerType) {
        dismiss(animated: true)
        presentFormController(of: type, formType: .add)
    }
}

// MARK: - UISearchBarDelegate

extension TrackerController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchText = ""
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let trackerCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCell.identifier,
                for: indexPath
            ) as? TrackerCell,
            let tracker = trackerStore.tracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        let isCompleted = completedTrackers.contains { $0.date == currentDate && $0.trackerId == tracker.id }
        let interaction = UIContextMenuInteraction(delegate: self)
        trackerCell.configure(
            with: tracker,
            days: tracker.completedDaysCount,
            isCompleted: isCompleted,
            interaction: interaction
        )
        trackerCell.delegate = self
        
        return trackerCell
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableSpace = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableSpace / params.cellCount
        return CGSize(width: cellWidth, height: params.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView
    {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerCategoryLabel
        else { return UICollectionReusableView() }
        
        guard let label = trackerStore.headerLabelInSection(indexPath.section) else { return UICollectionReusableView() }
        view.configure(with: label)
        
        return view
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - TrackerCellDelegate

extension TrackerController: TrackerCellDelegate {
    func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker) {
        if let recordToRemove = completedTrackers.first(where: { $0.date == currentDate && $0.trackerId == tracker.id }) {
            try? trackerRecordStore.remove(recordToRemove)
            cell.toggleCompletedButton(to: false)
            cell.decreaseCount()
        } else {
            let trackerRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
            try? trackerRecordStore.add(trackerRecord)
            cell.toggleCompletedButton(to: true)
            cell.increaseCount()
        }
    }
}

// MARK: - TrackerFormViewControllerDelegate

extension TrackerController: TrackerFormViewControllerDelegate {
    func didAddTracker(category: TrackerCategory, trackerToAdd: Tracker) {
        dismiss(animated: true)
        try? trackerStore.addTracker(trackerToAdd, with: category)
    }
    
    func didUpdateTracker(with data: Tracker.Data) {
        guard let editingTracker else { return }
        dismiss(animated: true)
        try? trackerStore.updateTracker(editingTracker, with: data)
        self.editingTracker = nil
    }
    
    func didTapCancelButton() {
        collectionView.reloadData()
        editingTracker = nil
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackerController: TrackerStoreDelegate {
    func didUpdate() {
        checkNumberOfTrackers()
        collectionView.reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackerController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ records: Set<TrackerRecord>) {
        completedTrackers = records
    }
}

//
//  HomeFormScheduleViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI
import UIKit

final class HomeFormScheduleViewController: UIViewController {
    init(viewModel: HomeFormScheduleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        viewModel.onViewDidLoad()
        title = "Booking Detail"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        thisView.tableView.resizeAutoSizingFooterIfNeeded()
    }
    
    // MARK: - Properties
    private let viewModel: HomeFormScheduleViewModelProtocol
    private let thisView: HomeFormScheduleView = HomeFormScheduleView()
    private var sections: [BookingDetailSection] = []
    private var footerView: FormInputFooterView?
    
    // MARK: - Setup
    private func setupTableView() {
        thisView.tableView.delegate = self
        thisView.tableView.dataSource = self
        
        // Enable automatic height calculation
        thisView.tableView.rowHeight = UITableView.automaticDimension
        thisView.tableView.estimatedRowHeight = 100
        
        // Register cells
        thisView.tableView.register(PackageInfoCell.self, forCellReuseIdentifier: "PackageInfoCell")
        thisView.tableView.register(SectionContainerCell.self, forCellReuseIdentifier: "SectionContainerCell")
        thisView.tableView.register(FormInputCell.self, forCellReuseIdentifier: "FormInputCell")
        thisView.tableView.register(TravelerDetailsCell.self, forCellReuseIdentifier: "TravelerDetailsCell")
        thisView.tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
    }
    
    // MARK: - Helpers
    private func toggleSection(at index: Int) {
        guard sections[index].isExpandable else { return }
        
        sections[index].isExpanded.toggle()
        
        // Animate the collapse/expand
        thisView.tableView.reloadSections(IndexSet(integer: index), with: .automatic)
    }
    
    private func showTimeSelector() {
        showCalendarOption()
    }
    
    private func showPaxSelector() {
        let alert = UIAlertController(title: "Select Participants", message: nil, preferredStyle: .actionSheet)
        
        for i in 1...10 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default) { [weak self] _ in
                // Update pax count in form
                // You can update the form data here
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    @objc private func onCheckoutTapped() {
        viewModel.onCheckout()
    }
}

// MARK: - UITableViewDataSource
extension HomeFormScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = sections[section]
        
        // For package info, trip provider, form inputs, and traveler details sections, always show 1 row
        if sectionData.type == .packageInfo || sectionData.type == .tripProvider || 
           sectionData.type == .formInputs || sectionData.type == .travelerDetails {
            return 1
        }
        
        // For collapsible sections, return 0 if collapsed, otherwise return 1 (using SectionContainerCell)
        return sectionData.isExpanded ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sections[indexPath.section]
        
        switch sectionData.type {
        case .packageInfo:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "PackageInfoCell",
                for: indexPath
            ) as? PackageInfoCell else {
                return UITableViewCell()
            }
            
            if let packageData = sectionData.items.first as? PackageInfoDisplayData {
                cell.configure(with: packageData)
            }
            return cell
            
        case .tripProvider:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SectionContainerCell",
                for: indexPath
            ) as? SectionContainerCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: sectionData.items, sectionType: .tripProvider)
            return cell
            
        case .itinerary:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SectionContainerCell",
                for: indexPath
            ) as? SectionContainerCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: sectionData.items, sectionType: .itinerary)
            return cell
            
        case .formInputs:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FormInputCell",
                for: indexPath
            ) as? FormInputCell else {
                return UITableViewCell()
            }
            
            // Configure with current form data
            cell.configure(selectedTime: "7.30", participantCount: "1")
            cell.onSelectTime = { [weak self] in
                self?.showTimeSelector()
            }
            cell.onSelectPax = { [weak self] in
                self?.showPaxSelector()
            }
            return cell
            
        case .travelerDetails:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TravelerDetailsCell",
                for: indexPath
            ) as? TravelerDetailsCell else {
                return UITableViewCell()
            }
            
            // Configure with current traveler data
            cell.configure(name: "", phone: "", email: "")
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeFormScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = sections[section]
        
        // No header for package info and form inputs sections
        if sectionData.type == .packageInfo || sectionData.type == .formInputs {
            return nil
        }
        
        // Custom header for traveler details (non-collapsible)
        if sectionData.type == .travelerDetails {
            let headerView = UIView()
            headerView.backgroundColor = Token.grayscale10
            
            let titleLabel = UILabel()
            titleLabel.text = "Traveler details"
            titleLabel.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
            titleLabel.textColor = Token.grayscale90
            
            headerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 27),
                titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -27),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
        
        // Collapsible headers for trip provider and itinerary sections
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "SectionHeaderView"
        ) as? SectionHeaderView else {
            return nil
        }
        
        headerView.configure(title: sectionData.title ?? "", isExpanded: sectionData.isExpanded)
        headerView.tapHandler = { [weak self] in
            self?.toggleSection(at: section)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionData = sections[section]
        
        switch sectionData.type {
        case .packageInfo, .formInputs:
            return 0
        case .travelerDetails:
            return 60
        default:
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

// MARK: - HomeFormScheduleViewModelAction
extension HomeFormScheduleViewController: HomeFormScheduleViewModelAction {
    func setupView(
        calendarViewModel: HomeSearchBarViewModel,
        paxInputViewModel: HomeSearchBarViewModel
    ) {
        // Set up the checkout button
        let container = UIView()
        container.backgroundColor = Token.additionalColorsWhite
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: -2)
        container.layer.shadowRadius = 8
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        checkoutButton.backgroundColor = Token.mainColorPrimary
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 12
        checkoutButton.addTarget(self, action: #selector(onCheckoutTapped), for: .touchUpInside)
        container.addSubview(checkoutButton)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 27),
            checkoutButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -27),
            checkoutButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            checkoutButton.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            checkoutButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        // Adjust content insets for the pinned button
        let pinnedHeight = 12 + 52 + 12 + view.safeAreaInsets.bottom
        thisView.tableView.contentInset.bottom = pinnedHeight
        thisView.tableView.scrollIndicatorInsets.bottom = pinnedHeight
    }
    
    func configureView(data: HomeFormScheduleViewData) {
        // This method is no longer needed with the new table view approach
    }
    
    func updateTableSections(_ sections: [BookingDetailSection]) {
        self.sections = sections
        thisView.tableView.reloadData()
        thisView.tableView.resizeAutoSizingFooterIfNeeded()
    }
    
    func showCalendarOption() {
        let calendarVC = CocoCalendarViewController()
        calendarVC.delegate = self
        let popup = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
}

// MARK: - CocoCalendarViewControllerDelegate
extension HomeFormScheduleViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date = date else { return }
        viewModel.onCalendarDidChoose(date: date)
    }
}

// MARK: - UITableView Extension
extension UITableView {
    func setAutoSizingFooterView(_ footer: UIView) {
        footer.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView = footer
        NSLayoutConstraint.activate([
            footer.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func resizeAutoSizingFooterIfNeeded() {
        guard let footer = tableFooterView else { return }
        
        let size = footer.systemLayoutSizeFitting(
            CGSize(width: frame.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        if footer.frame.size.height != size.height {
            footer.frame.size.height = size.height
            tableFooterView = footer
        }
    }
}

//final class HomeFormScheduleViewController: UIViewController {
//    init(viewModel: HomeFormScheduleViewModelProtocol) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//        self.viewModel.actionDelegate = self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func loadView() {
//        view = thisView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewModel.onViewDidLoad()
//        title = "Booking Detail"
//    }
//
//    private let viewModel: HomeFormScheduleViewModelProtocol
//    private let thisView: HomeFormScheduleView = HomeFormScheduleView()
//}
//
//extension HomeFormScheduleViewController: HomeFormScheduleViewModelAction {
//    func setupView(
//        calendarViewModel: HomeSearchBarViewModel,
//        paxInputViewModel: HomeSearchBarViewModel
//    ) {
//        let inputVC: UIHostingController = UIHostingController(
//            rootView: HomeFormScheduleInputView(
//                calendarViewModel: calendarViewModel,
//                paxInputViewModel: paxInputViewModel,
//                actionButtonAction: { [weak self] in
//                    self?.viewModel.onCheckout()
//                }
//            )
//        )
//        addChild(inputVC)
//        thisView.addInputView(from: inputVC.view)
//        inputVC.didMove(toParent: self)
//    }
//
//    func configureView(data: HomeFormScheduleViewData) {
//        thisView.configureView(data: data)
//    }
//
//    func showCalendarOption() {
//        let calendarVC: CocoCalendarViewController = CocoCalendarViewController()
//        calendarVC.delegate = self
//        let popup: CocoPopupViewController = CocoPopupViewController(child: calendarVC)
//        present(popup, animated: true)
//    }
//}
//
//extension HomeFormScheduleViewController: CocoCalendarViewControllerDelegate {
//    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
//        guard let date: Date else { return }
//        viewModel.onCalendarDidChoose(date: date)
//    }
//}

//
//  HomeFormScheduleViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//


import Foundation
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
        // Keep the footer sized with the table width
        thisView.tableView.resizeAutoSizingFooterIfNeeded()
    }
    
    // MARK: - Properties
    private let viewModel: HomeFormScheduleViewModelProtocol
    private let thisView: HomeFormScheduleView = HomeFormScheduleView()
    private var sections: [BookingDetailSection] = []
    private var paxVM: HomeSearchBarViewModel?
    
    // MARK: - Setup
    private func setupTableView() {
        thisView.tableView.delegate = self
        thisView.tableView.dataSource = self
        
        // Register cells
        thisView.tableView.register(PackageInfoCell.self, forCellReuseIdentifier: "PackageInfoCell")
        thisView.tableView.register(ItineraryCell.self, forCellReuseIdentifier: "ItineraryCell")
        thisView.tableView.register(FacilityCell.self, forCellReuseIdentifier: "FacilityCell")
        thisView.tableView.register(TermsCell.self, forCellReuseIdentifier: "TermsCell")
        thisView.tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
    }
    
    // MARK: - Helpers
    private func toggleSection(at index: Int) {
        guard sections[index].isExpandable else { return }
        
        sections[index].isExpanded.toggle()
        
        // Animate the collapse/expand
        thisView.tableView.reloadSections(IndexSet(integer: index), with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension HomeFormScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = sections[section]
        
        // For package info section, always show 1 row
        if sectionData.type == .packageInfo {
            return 1
        }
        
        // For collapsible sections, return 0 if collapsed, otherwise return items count
        return sectionData.isExpanded ? sectionData.items.count : 0
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
            
        case .itinerary:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ItineraryCell",
                for: indexPath
            ) as? ItineraryCell else {
                return UITableViewCell()
            }
            
            if let itineraryItem = sectionData.items[indexPath.row] as? ItineraryDisplayItem {
                cell.configure(with: itineraryItem)
            }
            return cell
            
        case .facilities:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FacilityCell",
                for: indexPath
            ) as? FacilityCell else {
                return UITableViewCell()
            }
            
            if let facility = sectionData.items[indexPath.row] as? FacilityDisplayItem {
                cell.configure(with: facility)
            }
            return cell
            
        case .termsAndConditions:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TermsCell",
                for: indexPath
            ) as? TermsCell else {
                return UITableViewCell()
            }
            
            if let terms = sectionData.items[indexPath.row] as? TermsDisplayItem {
                cell.configure(with: terms)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeFormScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = sections[section]
        
        // No header for package info section
        if sectionData.type == .packageInfo {
            return nil
        }
        
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
        return sectionData.type == .packageInfo ? 0 : 56
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude // Remove footer spacing
    }
}

// MARK: - HomeFormScheduleViewModelAction
extension HomeFormScheduleViewController: HomeFormScheduleViewModelAction {
    func setupView(
        calendarViewModel: HomeSearchBarViewModel,
        paxInputViewModel: HomeSearchBarViewModel
    ) {
        // Keep references so we can pass data back to the view model on submit
        self.paxVM = paxInputViewModel
        // 1) Build UIKit footer stack (scrolls with cells)
        let footer = FormInputFooterView()
        footer.onSelectTime = { [weak self] in
            self?.presentTimePicker(footer: footer)
        }
        // Keep pax in sync with view model's text
        footer.paxField.textField.addTarget(self, action: #selector(paxEditingChanged(_:)), for: .editingChanged)
        thisView.tableView.setAutoSizingFooter(footer)

        // 2) Build pinned bottom Checkout button (does not scroll)
        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.titleLabel?.font = .jakartaSans(forTextStyle: .body, weight: .semibold)
        checkoutButton.backgroundColor = Token.mainColorPrimary
        checkoutButton.setTitleColor(Token.additionalColorsWhite, for: .normal)
        checkoutButton.layer.cornerRadius = 12
        checkoutButton.addTarget(self, action: #selector(didTapCheckout), for: .touchUpInside)

        let buttonContainer = UIView()
        buttonContainer.backgroundColor = Token.additionalColorsWhite
        buttonContainer.addSubview(checkoutButton)
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkoutButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 27),
            checkoutButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -27),
            checkoutButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 12),
            checkoutButton.bottomAnchor.constraint(equalTo: buttonContainer.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            checkoutButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        thisView.addBottomInputView(from: buttonContainer)
    }
    
    func configureView(data: HomeFormScheduleViewData) {
        // This method is no longer needed with the new table view approach
        // The data is now displayed through table sections
    }
    
    func updateTableSections(_ sections: [BookingDetailSection]) {
        self.sections = sections
        thisView.tableView.reloadData()
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

// MARK: - Private actions
private extension HomeFormScheduleViewController {
    @objc func didTapCheckout() {
        // Push pax value into the view model before submit
        if let footer = thisView.tableView.tableFooterView as? FormInputFooterView {
            paxVM?.currentTypedText = footer.paxField.textField.text ?? "1"
        }
        viewModel.onCheckout()
    }
    
    @objc func paxEditingChanged(_ sender: UITextField) {
        // Keep only digits; view model will also sanitize on submit
        let filtered = (sender.text ?? "").filter { "0123456789".contains($0) }
        if filtered != sender.text { sender.text = filtered }
        // Update the view model's observable text so business logic can read it
        // We cannot access the internal view model from here, so we rely on action to read when submitting.
        // If needed, we can expose a setter via action protocol in a follow-up.
    }
    
    func presentTimePicker(footer: FormInputFooterView) {
        let times = ["7.30", "8.00", "8.30", "9.00", "9.30", "10.00", "10.30", "11.00"]
        let sheet = UIAlertController(title: "Select Time", message: nil, preferredStyle: .actionSheet)
        times.forEach { time in
            sheet.addAction(UIAlertAction(title: time, style: .default) { _ in
                footer.timeButton.setTitle(time, for: .normal)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
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

//
//  HomeFormScheduleViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - HomeFormScheduleViewController

/// View Controller for the booking form schedule screen
/// Displays package information, trip details, itinerary, form inputs, and traveler details
/// Uses a table view with different cell types for each section
/// Implements participant validation and date selection functionality
final class HomeFormScheduleViewController: UIViewController {
    
    // MARK: - Initialization
    
    /// Initializes the view controller with a ViewModel
    /// - Parameter viewModel: The ViewModel that handles business logic
    init(viewModel: HomeFormScheduleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupKeyboardHandling()
        viewModel.onViewDidLoad()
        title = Localization.Screen.bookingDetail
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        thisView.tableView.resizeAutoSizingFooterIfNeeded()
    }
    
    // MARK: - Properties
    
    /// The ViewModel that handles business logic and data management
    private let viewModel: HomeFormScheduleViewModelProtocol
    
    /// The main view containing the table view
    private let thisView: HomeFormScheduleView = HomeFormScheduleView()
    
    /// Array of sections to display in the table view
    private var sections: [BookingDetailSection] = []
    
    /// Footer view for form inputs (legacy property, no longer used)
    private var footerView: FormInputFooterView?
    
    /// Price details view for the bottom sticky section
    private var priceDetailsView: PriceDetailsView?
    
    // MARK: - Setup
    
    /// Configures the table view with delegates, cell registration, and layout settings
    private func setupTableView() {
        thisView.tableView.delegate = self
        thisView.tableView.dataSource = self
        
        // Enable automatic height calculation
        thisView.tableView.rowHeight = UITableView.automaticDimension
        thisView.tableView.estimatedRowHeight = 100
        
        // Register cells
        thisView.tableView.register(UnifiedBookingDetailCell.self, forCellReuseIdentifier: "UnifiedBookingDetailCell")
        thisView.tableView.register(FormInputCell.self, forCellReuseIdentifier: "FormInputCell")
        thisView.tableView.register(TravelerDetailsCell.self, forCellReuseIdentifier: "TravelerDetailsCell")
        thisView.tableView.register(BookingSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "BookingSectionHeaderView")
    }
    
    // MARK: - Helper Methods
    
    /// Toggles the expanded/collapsed state of a collapsible section
    /// - Parameter index: The section index to toggle
    private func toggleSection(at index: Int) {
        guard sections[index].isExpandable else { return }
        
        sections[index].isExpanded.toggle()
        
        // Since we're now using a unified cell, reload the first section (index 0) which contains the unified booking detail cell
        thisView.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    /// Shows the time/date selector (delegates to calendar selection)
    private func showTimeSelector() {
        showCalendarOption()
    }
    
    /// Shows the participant count selector with validation constraints
    /// Displays an action sheet with valid participant counts based on package constraints
    private func showPaxSelector() {
        // Get min/max participants from selected package
        guard let selectedPackage = getSelectedPackage() else {
            print("Could not find selected package for validation")
            return
        }
        
        let alert: UIAlertController = UIAlertController(title: Localization.Form.selectParticipants, message: "Min: \(selectedPackage.minParticipants) - Max: \(selectedPackage.maxParticipants)", preferredStyle: .actionSheet)
        
        let range: ClosedRange<Int> = selectedPackage.minParticipants...selectedPackage.maxParticipants
        for i in range {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default) { [weak self] _ in
                // Update pax count in form
                self?.updateParticipantCount(i)
            })
        }
        
        alert.addAction(UIAlertAction(title: Localization.Common.cancel, style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(alert, animated: true)
    }
    
    /// Gets the currently selected package from the ViewModel
    /// - Returns: The selected package or nil if not found
    private func getSelectedPackage() -> ActivityDetailDataModel.Package? {
        let allPackages = viewModel.input.package.availablePackages.content.values.flatMap { $0 }
        return allPackages.first { $0.id == viewModel.input.selectedPackageId }
    }
    
    /// Updates the participant count through the ViewModel
    /// - Parameter count: The new participant count
    private func updateParticipantCount(_ count: Int) {
        viewModel.updateParticipantCount(count)
    }
    
    /// Handles checkout button tap by calling the ViewModel
    @objc private func onCheckoutTapped() {
        viewModel.onCheckout()
    }
    
    /// Updates table view content insets for the price details view
    private func updateTableViewInsets() {
        // Calculate the height of the price details view
        let baseHeight: CGFloat = 12 + 44 + 16 + 52 + 12 // padding + header + spacing + button + padding
        let safeAreaBottom = view.safeAreaInsets.bottom
        let totalHeight = baseHeight + safeAreaBottom
        
        thisView.tableView.contentInset.bottom = totalHeight
        thisView.tableView.scrollIndicatorInsets.bottom = totalHeight
    }
    
    // MARK: - Keyboard Handling
    
    /// Sets up keyboard notifications for handling keyboard show/hide events
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// Handles keyboard will show notification
    /// Adjusts table view content insets to avoid keyboard covering input fields
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Convert keyboard frame to view coordinates
        let keyboardHeight = keyboardFrame.height
        
        // Calculate new bottom inset (keyboard height + price details view height)
        let priceDetailsHeight = priceDetailsView?.frame.height ?? 0
        let newBottomInset = keyboardHeight + priceDetailsHeight
        
        // Animate the content inset change
        UIView.animate(withDuration: animationDuration) {
            self.thisView.tableView.contentInset.bottom = newBottomInset
            self.thisView.tableView.scrollIndicatorInsets.bottom = newBottomInset
            
            // Scroll to keep the active text field visible if needed
            if let firstResponder = self.findFirstResponder(in: self.thisView.tableView) {
                self.scrollToKeepVisible(textField: firstResponder)
            }
        }
    }
    
    /// Handles keyboard will hide notification  
    /// Restores original table view content insets and scroll position
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Restore original bottom inset and scroll to natural position
        UIView.animate(withDuration: animationDuration) {
            self.updateTableViewInsets()
            
            // Scroll to a natural position (slightly above the price details)
            let contentHeight = self.thisView.tableView.contentSize.height
            let tableHeight = self.thisView.tableView.frame.height
            let priceDetailsHeight = self.priceDetailsView?.frame.height ?? 0
            
            // Calculate ideal scroll position to show content above price details
            if contentHeight > tableHeight - priceDetailsHeight {
                let targetOffsetY = max(0, contentHeight - (tableHeight - priceDetailsHeight - 20))
                let targetOffset = CGPoint(x: 0, y: targetOffsetY)
                self.thisView.tableView.setContentOffset(targetOffset, animated: false)
            } else {
                // If content fits, scroll to top
                self.thisView.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    /// Finds the first responder text field in the table view
    private func findFirstResponder(in view: UIView) -> UITextField? {
        for subview in view.subviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            }
            if let found = findFirstResponder(in: subview) {
                return found
            }
        }
        return nil
    }
    
    /// Scrolls the table view to keep the active text field visible
    private func scrollToKeepVisible(textField: UITextField) {
        // Convert text field frame to table view coordinates
        guard let cell = textField.superview?.superview as? UITableViewCell,
              let indexPath = thisView.tableView.indexPath(for: cell) else {
            return
        }
        
        // Scroll to the cell containing the active text field
        thisView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension HomeFormScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // We now have: unified booking details, form inputs, traveler details = 3 sections
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Each section has exactly 1 row
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Unified booking detail cell (Package Info + Trip Provider + Itinerary)
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "UnifiedBookingDetailCell",
                for: indexPath
            ) as? UnifiedBookingDetailCell else {
                return UITableViewCell()
            }
            
            // Find the sections data
            let packageSection = sections.first { $0.type == .packageInfo }
            let providerSection = sections.first { $0.type == .tripProvider }
            let itinerarySection = sections.first { $0.type == .itinerary }
            
            let packageData = packageSection?.items.first as? PackageInfoDisplayData
            let providerData = providerSection?.items.first as? TripProviderDisplayItem
            let itineraryData = itinerarySection?.items as? [ItineraryDisplayItem] ?? []
            
            if let packageData = packageData {
                cell.configure(
                    packageData: packageData,
                    providerData: providerData,
                    itineraryData: itineraryData,
                    isProviderExpanded: providerSection?.isExpanded ?? false,
                    isItineraryExpanded: itinerarySection?.isExpanded ?? false
                )
            }
            
            // Set up callbacks for section toggles
            cell.onTripProviderTapped = { [weak self] in
                if let index = self?.sections.firstIndex(where: { $0.type == .tripProvider }) {
                    self?.toggleSection(at: index)
                }
            }
            
            cell.onItineraryTapped = { [weak self] in
                if let index = self?.sections.firstIndex(where: { $0.type == .itinerary }) {
                    self?.toggleSection(at: index)
                }
            }
            
            return cell
            
        case 1:
            // Form inputs cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FormInputCell",
                for: indexPath
            ) as? FormInputCell else {
                return UITableViewCell()
            }
            
            let formSection = sections.first { $0.type == .formInputs }
            
            // Configure with current form data from ViewModel
            if let formData = formSection?.items.first as? FormInputData {
                cell.configure(selectedTime: formData.selectedTime, participantCount: formData.participantCount, availableSlots: formData.availableSlots)
            } else {
                cell.configure(selectedTime: "7.30", participantCount: "1", availableSlots: nil)
            }
            cell.onSelectTime = { [weak self] in
                self?.showTimeSelector()
            }
            cell.onSelectPax = { [weak self] in
                self?.showPaxSelector()
            }
            return cell
            
        case 2:
            // Traveler details cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TravelerDetailsCell",
                for: indexPath
            ) as? TravelerDetailsCell else {
                return UITableViewCell()
            }
            
            // Set delegate to handle traveler data changes
            cell.delegate = self
            
            // Configure with current traveler data
            cell.configure(name: "", phone: "", email: "")
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension HomeFormScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            // No header for unified booking detail section
            return nil
        case 1:
            // No header for form inputs section  
            return nil
        case 2:
            // Custom header for traveler details section
            let headerView = UIView()
            headerView.backgroundColor = Token.additionalColorsWhite
            
            let titleLabel = UILabel()
            titleLabel.text = "Traveler details"
            titleLabel.font = .jakartaSans(forTextStyle: .headline, weight: .bold)
            titleLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
            
            headerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
                titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            // No header for unified booking detail and form inputs
            return 0
        case 2:
            // Header for traveler details
            return 60
        default:
            return 0
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
        // Set up the price details view
        let priceDetailsView = PriceDetailsView()
        priceDetailsView.onBookNow = { [weak self] in
            print("🚨 VIEWCONTROLLER: onBookNow callback received!")
            NSLog("🚨 VIEWCONTROLLER: onBookNow callback received!")
            self?.viewModel.onCheckout()
            print("🚨 VIEWCONTROLLER: viewModel.onCheckout() called!")
            NSLog("🚨 VIEWCONTROLLER: viewModel.onCheckout() called!")
        }
        
        view.addSubview(priceDetailsView)
        priceDetailsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            priceDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            priceDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.priceDetailsView = priceDetailsView
        
        // Adjust content insets for the pinned price details view
        updateTableViewInsets()
    }
    
    func configureView(data: HomeFormScheduleViewData) {
        // This method is no longer needed with the new table view approach
    }
    
    func updateTableSections(_ sections: [BookingDetailSection]) {
        self.sections = sections
        thisView.tableView.reloadData()
        thisView.tableView.resizeAutoSizingFooterIfNeeded()
    }
    
    func updatePriceDetails(_ data: PriceDetailsData) {
        priceDetailsView?.configure(with: data)
    }
    
    func showCalendarOption() {
        let calendarVC = CocoCalendarViewController(
            packageId: viewModel.input.selectedPackageId,
            availabilityFetcher: AvailabilityFetcher()
        )
        calendarVC.delegate = self
        let popup = CocoPopupViewController(child: calendarVC)
        present(popup, animated: true)
    }
    
    func showValidationError(message: String) {
        let alert = UIAlertController(title: Localization.Validation.Alert.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localization.Validation.Alert.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CocoCalendarViewControllerDelegate
extension HomeFormScheduleViewController: CocoCalendarViewControllerDelegate {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController) {
        guard let date = date else { return }
        viewModel.onCalendarDidChoose(date: date)
    }
}

// MARK: - TravelerDetailsCellDelegate
extension HomeFormScheduleViewController: TravelerDetailsCellDelegate {
    func travelerDetailsDidChange(_ data: TravelerData) {
        viewModel.onTravelerDataChanged(data)
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


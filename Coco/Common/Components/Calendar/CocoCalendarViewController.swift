//
//  CocoCalendarViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import UIKit

protocol CocoCalendarViewControllerDelegate: AnyObject {
    func notifyCalendarDidChooseDate(date: Date?, calendar: CocoCalendarViewController)
}

final class CocoCalendarViewController: UIViewController {
    weak var delegate: CocoCalendarViewControllerDelegate?
    
    // Availability data
    private let packageId: Int?
    private let availabilityFetcher: AvailabilityFetcherProtocol?
    private var availabilityCache: [String: Int] = [:]
    
    init(packageId: Int? = nil, availabilityFetcher: AvailabilityFetcherProtocol? = nil) {
        self.packageId = packageId
        self.availabilityFetcher = availabilityFetcher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.packageId = nil
        self.availabilityFetcher = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        
        // Prefetch availability data for current month if package ID is provided
        if let packageId = packageId, let availabilityFetcher = availabilityFetcher {
            prefetchAvailabilityData(packageId: packageId, fetcher: availabilityFetcher)
        }
        
        let cancelButtonVC: CocoButtonHostingController = CocoButtonHostingController(
            action: { [weak self] in
                self?.applyTapped()
            },
            text: "Cancel",
            style: .normal,
            type: .tertiary,
            isStretch: true
        )
        
        let applyButtonVC: CocoButtonHostingController = CocoButtonHostingController(
            action: { [weak self] in
                guard let self else { return }
                self.applyTapped(completion: {
                    self.delegate?.notifyCalendarDidChooseDate(date: self.currentSelectedDate, calendar: self)
                })
            },
            text: "Apply",
            style: .normal,
            type: .primary,
            isStretch: true
        )
        
        addChild(cancelButtonVC)
        addChild(applyButtonVC)
        
        let buttonStackView: UIStackView = UIStackView(
            arrangedSubviews: [
                cancelButtonVC.view,
                applyButtonVC.view
            ]
        )
        cancelButtonVC.didMove(toParent: self)
        applyButtonVC.didMove(toParent: self)
        
        buttonStackView.spacing = 16
        
        let stack: UIStackView = UIStackView(arrangedSubviews: [calendarView, buttonStackView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private lazy var calendarView: UICalendarView = createCalendarView()
    private lazy var currentSelectedDate: Date? = nil
}

extension CocoCalendarViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        currentSelectedDate = dateComponents?.date
    }
}

// MARK: - UICalendarViewDelegate
extension CocoCalendarViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = dateComponents.date else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        guard let availableSlots = availabilityCache[dateString] else {
            return nil
        }
        
        let color: UIColor
        switch availableSlots {
        case 0:
            color = .systemRed // Red for fully booked
        case 1, 2:
            color = .systemYellow // Yellow for almost full
        default:
            color = .systemBlue // Blue for available (>2 slots)
        }
        
        return UICalendarView.Decoration.default(color: color, size: .large)
    }
}

private extension CocoCalendarViewController {
    func createCalendarView() -> UICalendarView {
        let calendarView: UICalendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        
        let dateSelection: UICalendarSelectionSingleDate = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        // Set up decoration provider for availability indicators
        calendarView.delegate = self
        
        return calendarView
    }
    
    @objc func applyTapped(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
    
    func prefetchAvailabilityData(packageId: Int, fetcher: AvailabilityFetcherProtocol) {
        let calendar = Calendar.current
        let now = Date()
        
        // Get current month range
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Get all dates in current month and next month
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        // Add current month dates
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Add next month dates
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: now),
           let nextMonthInterval = calendar.dateInterval(of: .month, for: nextMonth) {
            currentDate = nextMonthInterval.start
            while currentDate < nextMonthInterval.end {
                dates.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        // Fetch availability for each date
        for date in dates {
            Task {
                do {
                    let spec = AvailabilitySpec(packageId: packageId, date: date)
                    let availability = try await fetcher.getAvailability(request: spec)
                    
                    await MainActor.run {
                        let dateString = dateFormatter.string(from: date)
                        self.availabilityCache[dateString] = availability.availableSlots
                        
                        // Reload decorations for this date
                        self.calendarView.reloadDecorations(forDateComponents: [calendar.dateComponents([.year, .month, .day], from: date)], animated: false)
                    }
                } catch {
                    print("Failed to fetch availability for \(dateFormatter.string(from: date)): \(error)")
                }
            }
        }
    }
}

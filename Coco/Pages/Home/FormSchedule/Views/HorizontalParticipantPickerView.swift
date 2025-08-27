//
//  HorizontalParticipantPickerView.swift
//  Coco
//
//  Created by Claude on 27/08/25.
//

import Foundation
import UIKit

protocol HorizontalParticipantPickerViewDelegate: AnyObject {
    func participantPickerDidSelect(_ picker: HorizontalParticipantPickerView, count: Int)
}

/// Modern horizontal scroll picker for selecting participant count
/// Features smooth scrolling with snap-to-center behavior and visual feedback
final class HorizontalParticipantPickerView: UIView {
    
    // MARK: - Properties
    weak var delegate: HorizontalParticipantPickerViewDelegate?
    
    private(set) var selectedCount: Int = 1 {
        didSet {
            updateSelection()
            delegate?.participantPickerDidSelect(self, count: selectedCount)
        }
    }
    
    private var minCount: Int = 1
    private var maxCount: Int = 10
    private var availableSlots: Int?
    private var participantRange: [Int] = []
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1).cgColor
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Number of participants"
        label.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
        label.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .footnote, weight: .medium)
        label.textColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ParticipantNumberCell.self, forCellWithReuseIdentifier: "ParticipantNumberCell")
        
        // Add content insets for better scrolling experience
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 80)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        return collectionView
    }()
    
    private lazy var availableSlotsLabel: UILabel = {
        let label = UILabel()
        label.font = .jakartaSans(forTextStyle: .caption1, weight: .medium)
        label.textColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
        label.textAlignment = .right
        return label
    }()
    
    // Selection indicator line
    private lazy var selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        view.layer.cornerRadius = 1
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(
        currentCount: Int,
        minCount: Int,
        maxCount: Int,
        availableSlots: Int?
    ) {
        self.minCount = minCount
        self.maxCount = maxCount
        self.availableSlots = availableSlots
        
        // Create range of valid participant counts
        let effectiveMaxCount = min(maxCount, availableSlots ?? maxCount)
        self.participantRange = Array(minCount...effectiveMaxCount)
        
        self.selectedCount = min(max(currentCount, minCount), effectiveMaxCount)
        
        updateUI()
        collectionView.reloadData()
        
        // Scroll to selected item after layout
        DispatchQueue.main.async {
            self.scrollToSelected(animated: false)
        }
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubviews([
            titleLabel,
            subtitleLabel,
            collectionView,
            selectionIndicator,
            availableSlotsLabel
        ])
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.layout {
            $0.edges(to: self)
        }
        
        titleLabel.layout {
            $0.top(to: containerView.topAnchor, constant: 20)
            $0.leading(to: containerView.leadingAnchor, constant: 20)
            $0.trailing(to: containerView.trailingAnchor, constant: -20)
        }
        
        subtitleLabel.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 4)
            $0.leading(to: containerView.leadingAnchor, constant: 20)
            $0.trailing(to: containerView.trailingAnchor, constant: -20)
        }
        
        collectionView.layout {
            $0.top(to: subtitleLabel.bottomAnchor, constant: 20)
            $0.leading(to: containerView.leadingAnchor)
            $0.trailing(to: containerView.trailingAnchor)
            $0.height(60)
        }
        
        selectionIndicator.layout {
            $0.centerX(to: containerView.centerXAnchor)
            $0.top(to: collectionView.bottomAnchor, constant: 8)
            $0.width(40)
            $0.height(2)
        }
        
        availableSlotsLabel.layout {
            $0.top(to: selectionIndicator.bottomAnchor, constant: 12)
            $0.trailing(to: containerView.trailingAnchor, constant: -20)
            $0.bottom(to: containerView.bottomAnchor, constant: -20)
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Update subtitle with constraints
        let effectiveMaxCount = min(maxCount, availableSlots ?? maxCount)
        subtitleLabel.text = "Min: \(minCount) - Max: \(effectiveMaxCount)"
        
        // Update available slots
        if let slots = availableSlots {
            let slotsText = "Available Slots: \(slots)"
            availableSlotsLabel.text = slotsText
            availableSlotsLabel.textColor = slots > 0 ? UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1) : Token.alertsError
        } else {
            availableSlotsLabel.text = ""
        }
    }
    
    private func updateSelection() {
        // Update cell appearances
        collectionView.reloadData()
        
        // Add haptic feedback
        if #available(iOS 10.0, *) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func scrollToSelected(animated: Bool) {
        guard let index = participantRange.firstIndex(of: selectedCount) else { return }
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - UICollectionViewDataSource

extension HorizontalParticipantPickerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participantRange.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantNumberCell", for: indexPath) as? ParticipantNumberCell else {
            return UICollectionViewCell()
        }
        
        let count = participantRange[indexPath.item]
        let isSelected = count == selectedCount
        cell.configure(number: count, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HorizontalParticipantPickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let count = participantRange[indexPath.item]
        selectedCount = count
        scrollToSelected(animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension HorizontalParticipantPickerView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestItem()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestItem()
        }
    }
    
    private func snapToNearestItem() {
        let centerX = collectionView.contentOffset.x + collectionView.frame.width / 2
        
        // Find the closest item to center
        var closestDistance: CGFloat = .greatestFiniteMagnitude
        var closestIndex = 0
        
        for i in 0..<participantRange.count {
            let indexPath = IndexPath(item: i, section: 0)
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let distance = abs(attributes.center.x - centerX)
                if distance < closestDistance {
                    closestDistance = distance
                    closestIndex = i
                }
            }
        }
        
        // Update selection
        let newCount = participantRange[closestIndex]
        if newCount != selectedCount {
            selectedCount = newCount
        }
        
        // Snap to center
        let indexPath = IndexPath(item: closestIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - ParticipantNumberCell

private class ParticipantNumberCell: UICollectionViewCell {
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .jakartaSans(forTextStyle: .title2, weight: .bold)
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 2
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(circleView)
        circleView.addSubview(numberLabel)
        
        circleView.layout {
            $0.edges(to: contentView)
        }
        
        numberLabel.layout {
            $0.centerX(to: circleView.centerXAnchor)
            $0.centerY(to: circleView.centerYAnchor)
        }
    }
    
    func configure(number: Int, isSelected: Bool) {
        numberLabel.text = "\(number)"
        
        if isSelected {
            circleView.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
            circleView.layer.borderColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1).cgColor
            numberLabel.textColor = .white
            
            // Add scale animation
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        } else {
            circleView.backgroundColor = .clear
            circleView.layer.borderColor = UIColor(red: 227/255, green: 231/255, blue: 236/255, alpha: 1).cgColor
            numberLabel.textColor = UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1)
            
            // Reset scale
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
}

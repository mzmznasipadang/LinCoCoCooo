//
//  HorizontalParticipantPickerViewController.swift
//  Coco
//
//  Created by Claude on 27/08/25.
//

import Foundation
import UIKit

protocol HorizontalParticipantPickerViewControllerDelegate: AnyObject {
    func horizontalParticipantPickerDidSelect(_ picker: HorizontalParticipantPickerViewController, count: Int)
    func horizontalParticipantPickerDidCancel(_ picker: HorizontalParticipantPickerViewController)
}

/// Modern modal with horizontal scroll participant picker
final class HorizontalParticipantPickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: HorizontalParticipantPickerViewControllerDelegate?
    
    private let initialCount: Int
    private let minCount: Int
    private let maxCount: Int
    private let availableSlots: Int?
    private var selectedCount: Int
    
    // MARK: - UI Components
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Token.additionalColorsWhite
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.transform = CGAffineTransform(translationX: 0, y: 400)
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 204/255, alpha: 1)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var pickerView: HorizontalParticipantPickerView = {
        let picker = HorizontalParticipantPickerView()
        picker.delegate = self
        return picker
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(red: 120/255, green: 130/255, blue: 138/255, alpha: 1), for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
        button.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .jakartaSans(forTextStyle: .headline, weight: .semibold)
        button.backgroundColor = UIColor(red: 26/255, green: 178/255, blue: 229/255, alpha: 1)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init(
        initialCount: Int,
        minCount: Int,
        maxCount: Int,
        availableSlots: Int?
    ) {
        self.initialCount = initialCount
        self.minCount = minCount
        self.maxCount = maxCount
        self.availableSlots = availableSlots
        self.selectedCount = initialCount
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configurePickerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .clear
        
        view.addSubview(overlayView)
        view.addSubview(containerView)
        
        containerView.addSubviews([
            handleView,
            pickerView,
            buttonStackView
        ])
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        overlayView.layout {
            $0.edges(to: view)
        }
        
        containerView.layout {
            $0.leading(to: view.leadingAnchor)
            $0.trailing(to: view.trailingAnchor)
            $0.bottom(to: view.bottomAnchor)
        }
        
        handleView.layout {
            $0.top(to: containerView.topAnchor, constant: 12)
            $0.centerX(to: containerView.centerXAnchor)
            $0.width(36)
            $0.height(5)
        }
        
        pickerView.layout {
            $0.top(to: handleView.bottomAnchor, constant: 20)
            $0.leading(to: containerView.leadingAnchor, constant: 20)
            $0.trailing(to: containerView.trailingAnchor, constant: -20)
        }
        
        buttonStackView.layout {
            $0.top(to: pickerView.bottomAnchor, constant: 24)
            $0.leading(to: containerView.leadingAnchor, constant: 20)
            $0.trailing(to: containerView.trailingAnchor, constant: -20)
            $0.height(50)
            $0.bottom(to: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        }
    }
    
    private func configurePickerView() {
        pickerView.configure(
            currentCount: initialCount,
            minCount: minCount,
            maxCount: maxCount,
            availableSlots: availableSlots
        )
    }
    
    // MARK: - Animations
    
    private func animateIn() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: .curveEaseOut
        ) {
            self.overlayView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.overlayView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 400)
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - Actions
    
    @objc private func overlayTapped() {
        cancelButtonTapped()
    }
    
    @objc private func cancelButtonTapped() {
        animateOut { [weak self] in
            guard let self = self else { return }
            self.delegate?.horizontalParticipantPickerDidCancel(self)
            self.dismiss(animated: false)
        }
    }
    
    @objc private func confirmButtonTapped() {
        animateOut { [weak self] in
            guard let self = self else { return }
            self.delegate?.horizontalParticipantPickerDidSelect(self, count: self.selectedCount)
            self.dismiss(animated: false)
        }
    }
}

// MARK: - HorizontalParticipantPickerViewDelegate

extension HorizontalParticipantPickerViewController: HorizontalParticipantPickerViewDelegate {
    func participantPickerDidSelect(_ picker: HorizontalParticipantPickerView, count: Int) {
        selectedCount = count
        
        // Update confirm button text with count
        confirmButton.setTitle("Confirm (\(count))", for: .normal)
    }
}
//
//  ItineraryViewController.swift
//  Coco
//
//  Created by Lin Dan Christiano on 22/08/25.
//

import Foundation
import UIKit

// MARK: - Data Model for Itinerary
struct ItineraryItem {
    let time: String
    let description: String
}

// MARK: - Itinerary View Controller
final class ItineraryViewController: UIViewController {

    private let itineraryData: [ItineraryItem] = [
        .init(time: "7:30", description: "Gather at Basecamp"),
        .init(time: "8:15", description: "Boat transfer to Menjangan Island"),
        .init(time: "9:00", description: "First snorkeling session–Coral Garden"),
        .init(time: "10:30", description: "Second snorkeling session–Eel Garden"),
        .init(time: "12:00", description: "Lunch Break"),
        .init(time: "13:00", description: "Return boat ride to base"),
        .init(time: "13:45", description: "Arrive at basecamp")
    ]
    
    // MARK: - UI Components
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Itinerary"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemGray
        return label
    }()
    
    private let itineraryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateItinerary()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(handleView)
        view.addSubview(mainTitleLabel)
        view.addSubview(itineraryStackView)
        
        handleView.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itineraryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            mainTitleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 24),
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            itineraryStackView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 24),
            itineraryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            itineraryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            itineraryStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 24)
        ])
    }
    
    private func populateItinerary() {
        for (index, item) in itineraryData.enumerated() {
            let isLastItem = index == itineraryData.count - 1
            let rowView = ItineraryRowView(item: item, isLast: isLastItem)
            itineraryStackView.addArrangedSubview(rowView)
        }
    }
}


// MARK: - Custom View for a Single Itinerary Row
private class ItineraryRowView: UIView {
    
    private let item: ItineraryItem
    private let isLast: Bool
    
    init(item: ItineraryItem, isLast: Bool) {
        self.item = item
        self.isLast = isLast
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        let dotView = UIView()
        dotView.backgroundColor = UIColor(red: 74/255, green: 186/255, blue: 229/255, alpha: 1.0)
        dotView.layer.cornerRadius = 10
        dotView.translatesAutoresizingMaskIntoConstraints = false
        
        let dottedLine = DottedLineView()
        dottedLine.isHidden = isLast
        
        let timeLabel = UILabel()
        timeLabel.text = item.time
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = UIColor(red: 74/255, green: 186/255, blue: 229/255, alpha: 1.0)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = item.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        
        let textStack = UIStackView(arrangedSubviews: [timeLabel, descriptionLabel])
        textStack.spacing = 16
        textStack.alignment = .firstBaseline
        
        addSubview(dotView)
        addSubview(dottedLine)
        addSubview(textStack)
        
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dottedLine.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Dot
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dotView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            dotView.widthAnchor.constraint(equalToConstant: 20),
            dotView.heightAnchor.constraint(equalToConstant: 20),
            
            // Line
            dottedLine.topAnchor.constraint(equalTo: dotView.bottomAnchor),
            dottedLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            dottedLine.centerXAnchor.constraint(equalTo: dotView.centerXAnchor),
            dottedLine.widthAnchor.constraint(equalToConstant: 2),

            // Text
            textStack.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 20),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            textStack.topAnchor.constraint(equalTo: topAnchor),
            textStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32) // Jarak antar item
        ])
    }
}

// MARK: - Custom View for Dotted Line
private class DottedLineView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Hapus layer lama jika ada untuk mencegah duplikasi saat re-layout
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 169/255, green: 224/255, blue: 247/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [4, 6]

        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: bounds.midX, y: 0), CGPoint(x: bounds.midX, y: bounds.height)])
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
}

//
//  ActivityDetailViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import UIKit

final class ActivityDetailViewController: UIViewController {
    private var tripTitle: String?
    
    init(viewModel: ActivityDetailViewModelProtocol) {
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
        thisView.delegate = self
        viewModel.onViewDidLoad()
    }
    
    private let viewModel: ActivityDetailViewModelProtocol
    private let thisView: ActivityDetailView = ActivityDetailView()
    private var activityData: ActivityDetailDataModel?
        
}

extension ActivityDetailViewController: ActivityDetailViewModelAction {
    func configureView(data: ActivityDetailDataModel) {
        self.activityData = data
        thisView.configureView(data)
        tripTitle = data.title
        
        self.title = nil

        if data.imageUrlsString.isEmpty {
            thisView.toggleImageSliderView(isShown: false)
        } else {
            thisView.toggleImageSliderView(isShown: true)
            let sliderVCs = ImageSliderHostingController(images: data.imageUrlsString)
            addChild(sliderVCs)
            thisView.addImageSliderView(with: sliderVCs.view)
            sliderVCs.didMove(toParent: self)
        }

        thisView.onStickyTabVisibilityChanged = { [weak self] visible in
            guard let self = self else { return }
            self.navigationItem.title = visible ? self.tripTitle : nil
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.navigationItem.title = nil
        }
    }

    func updatePackageData(data: [ActivityDetailDataModel.Package]) {
        thisView.updatePackageData(data)
    }
}

extension ActivityDetailViewController: ActivityDetailViewDelegate {

    func notifyPackagesDetailDidTap(with packageId: Int) {
        viewModel.onPackagesDetailDidTap(with: packageId)
    }
    
    func notifyHighlightsSeeMoreDidTap(fullText: String) {
        guard let data = activityData else { return }
        
        let highlightsVC = HighlightsViewController(content: fullText, tripFacilities: data.tripFacilities.content, tnc: data.tnc)
        
        if let sheet = highlightsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 24
        }
        
        present(highlightsVC, animated: true, completion: nil)
    }
}

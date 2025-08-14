//
//  CheckoutViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import SwiftUI
import UIKit

final class CheckoutViewController: UIViewController {
    init(viewModel: CheckoutViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    private var bookButtonVC: CocoButtonHostingController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = thisView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        title = "Checkout"
    }
    
    private let viewModel: CheckoutViewModelProtocol
    private let thisView: CheckoutView = CheckoutView()
}

extension CheckoutViewController: CheckoutViewModelAction {
    func configureView(bookingData: CheckoutDisplayData) {
        thisView.configureView(bookingData)
        
        let button = CocoButtonHostingController(
            action: viewModel.bookNowDidTap,
            text: "Book Now",
            style: .large,
            type: .primary,
            isStretch: true
        )
        addChild(button)
        thisView.addBooknowButton(from: button.view)
        button.didMove(toParent: self)
        self.bookButtonVC = button
    }
    
    func setLoading(_ isLoading: Bool) {
        bookButtonVC?.view.isUserInteractionEnabled = !isLoading
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Booking Gagal", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showPopUpSuccess(completion: @escaping () -> Void) {
        let view: CheckoutCompletedPopUpView = CheckoutCompletedPopUpView { [weak self] in
            self?.dismiss(animated: true, completion: completion)
        }
        let hostingVC: UIHostingController = UIHostingController(rootView: view)
        let popUpVC = CocoPopupViewController(child: hostingVC)
        present(popUpVC, animated: true)
    }
}

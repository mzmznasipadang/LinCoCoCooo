//
//  UITableView+AutoSizingFooter.swift
//  Coco
//
//  Created by AI on 20/08/25.
//

import Foundation
import UIKit

extension UITableView {
    /// Sets a UIView as tableFooterView and sizes it to fit the table width
    func setAutoSizingFooter(_ footer: UIView) {
        let width = bounds.width
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = footer.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        footer.frame = CGRect(x: 0, y: 0, width: width, height: ceil(height))
        tableFooterView = footer
    }

    /// Call from viewDidLayoutSubviews to keep the footer sized on rotation/size changes
    func resizeAutoSizingFooterIfNeeded() {
        guard let footer = tableFooterView else { return }
        let width = bounds.width
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = footer.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if footer.frame.size.width != width || footer.frame.size.height != ceil(height) {
            footer.frame.size = CGSize(width: width, height: ceil(height))
            tableFooterView = footer
        }
    }
}



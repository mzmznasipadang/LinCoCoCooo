//
//  CustomTabBarDelegate.swift
//  Coco
//
//  Created by Lin Dan Christiano on 20/08/25.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func customTabBar(_ tabBar: CustomTabBar, didSelect index: Int)
}

final class CustomTabBar: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    weak var delegate: CustomTabBarDelegate?

    private let titles: [String]
    private let collection: UICollectionView
    private let underline = UIView()
    private let topHairline = UIView()
    private let bottomHairline = UIView()

    private(set) var selectedIndex: Int = 0
    private let cellH: CGFloat = 48
    private let textFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
    private let horizPad: CGFloat = 16
    private let underlineH: CGFloat = 3

    private lazy var textWidths: [CGFloat] = {
        titles.map { s in ceil((s as NSString).size(withAttributes: [.font: textFont]).width) }
    }()

    init(titles: [String]) {
        self.titles = titles
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white  // sesuai desain ActivityDetailView

        [topHairline, bottomHairline].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .separator
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            topHairline.topAnchor.constraint(equalTo: topAnchor),
            topHairline.leadingAnchor.constraint(equalTo: leadingAnchor),
            topHairline.trailingAnchor.constraint(equalTo: trailingAnchor),
            topHairline.heightAnchor.constraint(equalToConstant: 0.5),

            bottomHairline.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomHairline.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomHairline.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomHairline.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        collection.contentInset = .zero
        collection.register(TabCell.self, forCellWithReuseIdentifier: TabCell.reuseId)
        addSubview(collection)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: cellH),
            collection.topAnchor.constraint(equalTo: topHairline.bottomAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomHairline.topAnchor),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        // Underline di dalam collectionView → ikut scroll
        underline.backgroundColor = .systemBlue
        underline.frame = .zero
        collection.addSubview(underline)

        // State awal
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.collection.reloadData()
            self.selectedIndex = 0
            self.setSelected(index: 0, animated: false, notify: false)
            self.updateUnderline(animated: false)
        }
    }

    // MARK: Public
    func setSelected(index: Int, animated: Bool, notify: Bool) {
        guard titles.indices.contains(index) else { return }
        let old = selectedIndex
        selectedIndex = index

        let oldPath = IndexPath(item: old, section: 0)
        let newPath = IndexPath(item: index, section: 0)

        collection.selectItem(at: newPath, animated: animated, scrollPosition: [])
        (collection.cellForItem(at: oldPath) as? TabCell)?.setActive(false, font: textFont)
        (collection.cellForItem(at: newPath) as? TabCell)?.setActive(true, font: textFont)

        collection.scrollToItem(at: newPath, at: .centeredHorizontally, animated: animated)
        updateUnderline(animated: animated)

        if notify { delegate?.customTabBar(self, didSelect: index) }
    }

    private func updateUnderline(animated: Bool) {
        collection.layoutIfNeeded()
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        guard let attrs = collection.layoutAttributesForItem(at: indexPath) else { return }
        let cellFrame = attrs.frame

        let textW = textWidths[selectedIndex]
        let underlineW = textW
        let x = cellFrame.minX + (cellFrame.width - underlineW) / 2.0
        let y = collection.bounds.height - underlineH
        let target = CGRect(x: x, y: y, width: underlineW, height: underlineH)

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                self.underline.frame = target
            }
        } else {
            underline.frame = target
        }
    }

    // Follow scrolling/relayout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderline(animated: false)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) { updateUnderline(animated: false) }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { updateUnderline(animated: true) }

    // MARK: DS/Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { titles.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TabCell.reuseId,
            for: indexPath
        ) as? TabCell else {
            return UICollectionViewCell()
        }
        cell.configure(title: titles[indexPath.item], font: textFont)
        cell.setActive(indexPath.item == selectedIndex, font: textFont)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setSelected(index: indexPath.item, animated: true, notify: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = ceil((titles[indexPath.item] as NSString).size(withAttributes: [.font: textFont]).width) + horizPad * 2
        return CGSize(width: w, height: cellH)
    }
}

private final class TabCell: UICollectionViewCell {
    static let reuseId = "TabCell"
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, font: UIFont) {
        label.text = title
        label.font = font
    }
    func setActive(_ active: Bool, font: UIFont) {
        label.textColor = active ? .systemBlue : .label
        label.font = active ? UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
                            : UIFont.systemFont(ofSize: font.pointSize, weight: .regular)
    }
}

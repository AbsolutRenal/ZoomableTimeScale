//
//  TimeScaleStepCell.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/28/21.
//

import Foundation
import UIKit

final class TimeScaleStepCell: UICollectionViewCell {

    // MARK: Enums

    private enum Constants {
        static let tintColor: UIColor = UIColor.darkGray
        static let dotSize: CGFloat = 2
        static let font: UIFont = UIFont.systemFont(ofSize: 9)
    }


    // MARK: Properties

    private let dotLayer = CALayer()
    private let dotReplicator = CAReplicatorLayer()
    private var isFirst: Bool = false
    private var nbDots: Int = 0

    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = Constants.tintColor
        return label
    }()


    // MARK: LifeCycle

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        if nbDots > 0 {
            let offsetForFirst = isFirst ? 0 : 1
            let dotOffset = contentView.bounds.width / CGFloat(nbDots)
            guard !dotOffset.isInfinite else {
                return
            }
            CATransaction.setAnimationDuration(0)
            dotReplicator.instanceCount = nbDots - offsetForFirst
            dotReplicator.instanceTransform = CATransform3DTranslate(CATransform3DIdentity,
                                                                     dotOffset,
                                                                     0,
                                                                     0)
            dotLayer.position = CGPoint(x: dotOffset * CGFloat(offsetForFirst),
                                        y: contentView.bounds.midY)
        } else if isFirst {
                dotReplicator.instanceCount = 1
                dotLayer.position = CGPoint(x: 0,
                                            y: contentView.bounds.midY)
        }
        CATransaction.commit()
    }


    // MARK: Public

    func configure(with timestamp: String,
                   nbDots: Int,
                   isFirst: Bool) {
        if timestampLabel.superview == nil {
            setupLayout()
            setupLayers()
        }
        self.nbDots = nbDots
        self.isFirst = isFirst

        dotLayer.isHidden = (nbDots == 0 && !isFirst)
        timestampLabel.text = timestamp
    }


    // MARK: Private

    private func setupLayout() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timestampLabel)

        NSLayoutConstraint.activate([
            timestampLabel.centerXAnchor.constraint(equalTo: contentView.trailingAnchor),
            timestampLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setupLayers() {
        dotLayer.backgroundColor = Constants.tintColor.cgColor
        dotLayer.bounds = CGRect(x: 0,
                                 y: 0,
                                 width: Constants.dotSize,
                                 height: Constants.dotSize)
        dotLayer.cornerRadius = Constants.dotSize * 0.5
        dotReplicator.addSublayer(dotLayer)
        contentView.layer.addSublayer(dotReplicator)
    }
}

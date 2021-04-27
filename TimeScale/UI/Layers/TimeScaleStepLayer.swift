//
//  TimeScaleStepLayer.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import Foundation
import UIKit

class TimeScaleStepLayer: CALayer {

    // MARK: Enums

    private enum Constants {
        static let tintColor: CGColor = UIColor.darkGray.cgColor
        static let dotSize: CGFloat = 2
        static let minSpaceBetweenDots: CGFloat = 15
        static let font: UIFont = UIFont.systemFont(ofSize: 9)
    }


    // MARK: Properties

    private let dotLayer = CALayer()
    private let dotReplicator = CAReplicatorLayer()
    private let timestampLayer = CATextLayer()
    private var isFirst: Bool = false


    // MARK: LifeCycle

    init(isFirst: Bool) {
        self.isFirst = isFirst
        super.init()
        setupLayers()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        let offsetForFirst = isFirst ? 0 : 1
        let nbDots = Int(frame.width / (Constants.minSpaceBetweenDots + Constants.dotSize))
        let dotOffset = frame.width / CGFloat(nbDots)
        dotReplicator.instanceCount = nbDots - offsetForFirst
        dotReplicator.instanceTransform = CATransform3DTranslate(CATransform3DIdentity,
                                                                 dotOffset,
                                                                 0,
                                                                 0)
        dotLayer.position = CGPoint(x: dotOffset * CGFloat(offsetForFirst),
                                    y: frame.midY)
        updateTimestampLayerPosition()
    }


    // MARK: Public

    func setTimestamp(to timestamp: String) {
        timestampLayer.string = timestamp
        guard let bounds = (timestampLayer.string as? NSString)?.boundingRect(with: CGSize(width: .greatestFiniteMagnitude,
                                                                                           height: (Constants.font.pointSize+1) * 0.5),
                                                                              options: .usesLineFragmentOrigin,
                                                                              attributes: [NSAttributedString.Key.font: Constants.font],
                                                                              context: nil) else {
            return
        }

        timestampLayer.bounds = bounds
    }


    // MARK: Private

    private func setupLayers() {
        dotLayer.backgroundColor = Constants.tintColor
        dotLayer.bounds = CGRect(x: 0,
                                 y: 0,
                                 width: Constants.dotSize,
                                 height: Constants.dotSize)
        dotLayer.cornerRadius = Constants.dotSize * 0.5
        dotReplicator.addSublayer(dotLayer)
        addSublayer(dotReplicator)

        let fontName = Constants.font.fontDescriptor.postscriptName as CFString
        timestampLayer.font = CGFont(fontName)
        timestampLayer.isWrapped = true
        timestampLayer.fontSize = 9
        timestampLayer.alignmentMode = .center
        timestampLayer.foregroundColor = Constants.tintColor
        addSublayer(timestampLayer)

        contentsScale = UIScreen.main.scale
        dotLayer.contentsScale = UIScreen.main.scale
        dotReplicator.contentsScale = UIScreen.main.scale
        timestampLayer.contentsScale = UIScreen.main.scale
    }

    private func updateTimestampLayerPosition() {
        CATransaction.setAnimationDuration(0)
        timestampLayer.position = CGPoint(x: bounds.maxX, y: bounds.midY)
    }
}

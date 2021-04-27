//
//  TimeScaleView.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import Foundation
import UIKit

class TimeScaleView: UIView {

    // MARK: Constants

    private enum Constants {
        static let minInstanceWidth: CGFloat = 50
        static let minDotSpacing: CGFloat = 25
    }

    // MARK: Properties

    private let timeScaleLayer: TimeScaleLayer = TimeScaleLayer()
    private var pixelsPerSecond: Int
    private var mediaDuration: TimeInterval

    private var nbInstances: Int {
        switch pixelsPerSecond {
        case let x where CGFloat(x) < Constants.minInstanceWidth:
            /// Several seconds per instance
            let occurenceDuration = (Constants.minInstanceWidth / CGFloat(x)).rounded(.up)
            return Int((mediaDuration / Double(occurenceDuration)).rounded(.up))
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 2):
            /// One second per instance
            return Int(mediaDuration.rounded(.up))
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 4):
            /// Half a second per instance
        return Int((mediaDuration * 2).rounded(.up))
        default:
            /// Quarter a second per instance
            return Int((mediaDuration * 4).rounded(.up))
        }
    }

//    private var nbDotsPerInstance: Int {
//        return 2
//    }


    // MARK: LifeCycle

    init(pixelsPerSecond: Int,
         timelineDuration: TimeInterval) {
        self.pixelsPerSecond = pixelsPerSecond
        self.mediaDuration = timelineDuration
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        timeScaleLayer.frame = bounds
    }


    // MARK: Public

    func updateScale(to pixelsPerSecond: Int) {
        print("updateScale(to: \(pixelsPerSecond))")
        self.pixelsPerSecond = pixelsPerSecond
        let instanceCount = nbInstances
        let timeScaleDuration = (mediaDuration / Double(instanceCount)).rounded(.up) * Double(instanceCount)
        timeScaleLayer.update(instanceCount: instanceCount,
                              timescaleDuration: timeScaleDuration)
    }


    // MARK: Private

    private func setupLayout() {
        timeScaleLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(timeScaleLayer)
    }
}

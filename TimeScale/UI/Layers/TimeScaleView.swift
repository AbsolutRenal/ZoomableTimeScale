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

    private var timeScaleLayer: TimeScaleLayer?
    private var pixelsPerSecond: Int
    private var timelineDuration: TimeInterval

    private var nbInstances: Int {
        switch pixelsPerSecond {
        case let x where CGFloat(x) < Constants.minInstanceWidth:
            /// Several seconds per instance
            let occurenceDuration = (Constants.minInstanceWidth / CGFloat(x)).rounded(.up)
            return Int((timelineDuration / Double(occurenceDuration)).rounded(.up))
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 2):
            /// One second per instance
            return Int(timelineDuration.rounded(.up))
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 4):
            /// Half a second per instance
        return Int((timelineDuration * 2).rounded(.up))
        default:
            /// Quarter a second per instance
            return Int((timelineDuration * 4).rounded(.up))
        }
    }

//    private var nbDotsPerInstance: Int {
//        return 2
//    }


    // MARK: LifeCycle

    init(pixelsPerSecond: Int,
         timelineDuration: TimeInterval) {
        self.pixelsPerSecond = pixelsPerSecond
        self.timelineDuration = timelineDuration
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        timeScaleLayer?.frame = bounds
    }


    // MARK: Public

    func updateScale(to pixelsPerSecond: Int) {
        self.pixelsPerSecond = pixelsPerSecond
        timeScaleLayer?.setInstancesCount(to: nbInstances)
    }


    // MARK: Private

    private func setupLayout() {
        let timeScale = TimeScaleLayer(withDuration: timelineDuration,
                                       nbInstances: nbInstances)
        layer.addSublayer(timeScale)

        timeScaleLayer = timeScale
    }
}

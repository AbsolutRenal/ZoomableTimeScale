//
//  TimeScaleLayer.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import Foundation
import UIKit

class TimeScaleLayer: CALayer {

    // MARK: Properties

    private let timelineDuration: TimeInterval
    private var instanceCount: Int


    // MARK: LifeCycle

    override init(layer: Any) {
        self.timelineDuration = 90
        self.instanceCount = 2
        super.init(layer: layer)
        setupLayers()
    }

    init(withDuration duration: TimeInterval,
         nbInstances: Int) {
        self.timelineDuration = duration
        self.instanceCount = nbInstances
        super.init()
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Public

    override func layoutSublayers() {
        super.layoutSublayers()

        guard let count = sublayers?.count,
              count > 0 else {
            return
        }
        let stepSize = frame.width / CGFloat(count)
        sublayers?.enumerated().forEach { idx, stepLayer in
            stepLayer.frame = CGRect(x: stepSize * CGFloat(idx),
                                     y: 0,
                                     width: stepSize,
                                     height: bounds.height)
        }
    }


    // MARK: Private

    private func setupLayers() {
        sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        let timeOffset = timelineDuration / Double(instanceCount)
        for i in 0..<instanceCount {
            let timeScaleStep = TimeScaleStepLayer()
            addSublayer(timeScaleStep)

            let time = timeOffset * Double(i+1)
            timeScaleStep.setTimestamp(to: time.getHumanReadableString(omitStartingZero: false))
        }
    }
}

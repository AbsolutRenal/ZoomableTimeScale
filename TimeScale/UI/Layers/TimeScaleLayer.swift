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

    private var timelineDuration: TimeInterval = -1
    private var instanceCount: Int = 0


    // MARK: LifeCycle

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


    // MARK: Public

    func update(instanceCount: Int,
                timescaleDuration: TimeInterval) {
        print("update(instanceCount:\(instanceCount), timescaleDuration:\(timescaleDuration)")
        self.instanceCount = instanceCount
        self.timelineDuration = timescaleDuration
        setupLayout()
    }


    // MARK: Private

    private func setupLayout() {
        instantiateRequestedLayers()
        updateLayersTimeStamps()
    }

    private func instantiateRequestedLayers() {
        let timeScaleSteps = sublayers?.compactMap({ $0 as? TimeScaleStepLayer })
        let currentCount = timeScaleSteps?.count ?? 0
        if currentCount < instanceCount {
            for i in currentCount..<instanceCount {
                let timeScaleStep = TimeScaleStepLayer(isFirst: i == 0)
                addSublayer(timeScaleStep)
            }
        } else {
            guard var steps = timeScaleSteps else {
                return
            }
            repeat {
                steps.removeLast().removeFromSuperlayer()
            } while steps.count > instanceCount
        }
    }

    private func updateLayersTimeStamps() {
        guard let timeScaleSteps = sublayers?.compactMap({ $0 as? TimeScaleStepLayer }) else {
            return
        }

        let timeOffset = timelineDuration / Double(instanceCount)

        for (idx, step) in timeScaleSteps.enumerated() {
            let time = timeOffset * Double(idx+1)
            print("idx:\(idx) -> time:\(time)")
            step.setTimestamp(to: time.getHumanReadableString(omitStartingZero: false))
        }
    }
}

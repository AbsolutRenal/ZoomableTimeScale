//
//  TimeScaleView.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import Foundation
import UIKit

class TimeScaleView: UIView {
    typealias TimeScaleConfiguration = (nbInstances: Int, nbDots: Int, scaleDuration: TimeInterval)

    // MARK: Constants

    private enum Constants {
        static let minInstanceWidth: CGFloat = 40
        static let minDotSpacing: CGFloat = 15
    }

    private enum TimeScaleMode {
        case multipleSeconds(Int)
        case second
        case halfSecond
        case quarterSecond
    }

    // MARK: Properties

    private let timeScaleLayer: TimeScaleLayer = TimeScaleLayer()
    private var pixelsPerSecond: Int = 0
    private var mediaDuration: TimeInterval

    private var scaleMode: TimeScaleMode {
        switch pixelsPerSecond {
        case let x where CGFloat(x) < Constants.minInstanceWidth:
            /// Several seconds per instance
            let occurenceDuration = (Constants.minInstanceWidth / CGFloat(x)).rounded(.up)
            return .multipleSeconds(Int(occurenceDuration))
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 2):
            /// One second per instance
            return .second
        case let x where CGFloat(x) < (Constants.minInstanceWidth * 4):
            /// Half a second per instance
            return .halfSecond
        default:
            /// Quarter a second per instance
            return .quarterSecond
        }
    }


    // MARK: LifeCycle

    init(mediaDuration: TimeInterval) {
        self.mediaDuration = mediaDuration
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
        guard pixelsPerSecond != self.pixelsPerSecond else {
            return
        }
        self.pixelsPerSecond = pixelsPerSecond
        let configuration = getScaleConfiguration()
        timeScaleLayer.update(instanceCount: configuration.nbInstances,
                              timescaleDuration: configuration.scaleDuration,
                              nbDots: configuration.nbDots)
    }


    // MARK: Private

    private func setupLayout() {
        timeScaleLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(timeScaleLayer)
    }

    private func getScaleConfiguration() -> TimeScaleConfiguration {
        switch scaleMode {
        case .multipleSeconds(let seconds):
            let nbInstances = Int((mediaDuration / Double(seconds)).rounded(.up))
            let scaleDuration = Double(nbInstances * seconds)
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [seconds])
            return (nbInstances: nbInstances,
                    nbDots: nbDots,
                    scaleDuration: scaleDuration)
        case .second:
            let nbInstances = Int(mediaDuration.rounded(.up))
            let scaleDuration = (mediaDuration / Double(nbInstances)).rounded(.up) * Double(nbInstances)
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [2, 4])
//                                            in: [2, 4, 5])
            return (nbInstances: nbInstances,
                    nbDots: nbDots,
                    scaleDuration: scaleDuration)
        case .halfSecond:
            let nbInstances = Int(mediaDuration.rounded(.up)) * 2
            let scaleDuration = (mediaDuration / Double(nbInstances) * 0.5).rounded(.up) * Double(nbInstances) * 0.5
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [2])
//                                            in: [2, 5])
            return (nbInstances: nbInstances,
                    nbDots: nbDots,
                    scaleDuration: scaleDuration)
        case .quarterSecond:
            let nbInstances = Int(mediaDuration.rounded(.up)) * 4
            let scaleDuration = (mediaDuration / Double(nbInstances) * 0.25).rounded(.up) * Double(nbInstances) * 0.25
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [5])
            return (nbInstances: nbInstances,
                    nbDots: nbDots,
                    scaleDuration: scaleDuration)
        }
    }

    private func greatestDotsNumber(forInstanceCount count: Int,
                                    in possibleValues: [Int]) -> Int {
        let instanceSize = frame.width / CGFloat(count)
        let possibleValuesSortedDecreaseOrder = possibleValues.sorted(by: >)
        return possibleValuesSortedDecreaseOrder.first {
            instanceSize / CGFloat($0) >= Constants.minDotSpacing
        } ?? possibleValuesSortedDecreaseOrder.last ?? 0
    }
}

//
//  TimeScaleView.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import Foundation
import UIKit

typealias TimeScaleConfiguration = (nbInstances: Int, nbDots: Int, scaleDuration: TimeInterval, secondFraction: Bool)
class TimeScaleView: UIView {

    // MARK: Constants

    private enum Constants {
        static let minInstanceWidth: CGFloat = 40
        static let minDotSpacing: CGFloat = 20
        static let minSingleSpacing: CGFloat = 10
    }

    private enum TimeScaleMode {
        case multipleSeconds(Int)
        case second
        case halfSecond
        case quarterSecond

        var displaySecondFraction: Bool {
            switch self {
            case .halfSecond,
                 .quarterSecond: return true
            default: return false
            }
        }
    }

    // MARK: Properties

    private var pixelsPerSecond: CGFloat = 0
    private var mediaDuration: TimeInterval

    private var scaleMode: TimeScaleMode = .second
    private var scaleConfiguration: TimeScaleConfiguration = (nbInstances: 0,
                                                              nbDots: 0,
                                                              scaleDuration: 0,
                                                              secondFraction: false)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collection = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collection.allowsSelection = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()


    // MARK: LifeCycle

    init(mediaDuration: TimeInterval) {
        self.mediaDuration = mediaDuration
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }


    // MARK: Public

    func updateScale(to pixelsPerSecond: CGFloat) {
        guard pixelsPerSecond != self.pixelsPerSecond else {
            return
        }
        updateScaleMode(with: pixelsPerSecond)
        updateScaleConfiguration()
        collectionView.reloadData()
    }


    // MARK: Private

    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor)
        ])

        collectionView.register(TimeScaleStepCell.self,
                                forCellWithReuseIdentifier: String(describing: TimeScaleStepCell.self))
    }

    private func updateScaleMode(with pixelsPerSecond: CGFloat) {
        self.pixelsPerSecond = pixelsPerSecond

        switch pixelsPerSecond {
        case let x where x < Constants.minInstanceWidth:
            /// Several seconds per instance
            let occurenceDuration = (Constants.minInstanceWidth / CGFloat(x)).rounded(.up)
            scaleMode = .multipleSeconds(Int(occurenceDuration))
        case let x where x < (Constants.minInstanceWidth * 3):
            /// One second per instance
            scaleMode =  .second
        case let x where x < (Constants.minInstanceWidth * 10):
            /// Half a second per instance
            scaleMode =  .halfSecond
        default:
            /// Quarter a second per instance
            scaleMode =  .quarterSecond
        }
    }

    private func intermediateDots(for seconds: Int, devidedBy devider: Int) -> Int? {
        if (CGFloat(seconds) / CGFloat(devider)).truncatingRemainder(dividingBy: 1) == 0 {
            return devider
        }
        return nil
    }

    private func updateScaleConfiguration() {
        switch scaleMode {
        case .multipleSeconds(let seconds):
            let nbInstances = Int((mediaDuration / Double(seconds)).rounded(.up))
            let scaleDuration = Double(nbInstances * seconds)
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [0, seconds,
                                                 intermediateDots(for: seconds, devidedBy: 2),
                                                 intermediateDots(for: seconds, devidedBy: 3),
                                                 intermediateDots(for: seconds, devidedBy: 5),
                                            ].compactMap { $0 })
            scaleConfiguration = (nbInstances: nbInstances,
                                  nbDots: nbDots,
                                  scaleDuration: scaleDuration,
                                  secondFraction: false)
        case .second:
            let nbInstances = Int(mediaDuration.rounded(.up))
            let scaleDuration = (mediaDuration / Double(nbInstances)).rounded(.up) * Double(nbInstances)
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [2, 4])
//                                            in: [2, 4, 5])
            scaleConfiguration = (nbInstances: nbInstances,
                                  nbDots: nbDots,
                                  scaleDuration: scaleDuration,
                                  secondFraction: false)
        case .halfSecond:
            let nbInstances = Int(mediaDuration.rounded(.up)) * 2
            let scaleDuration = (mediaDuration / Double(nbInstances) * 0.5).rounded(.up) * Double(nbInstances) * 0.5
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
//                                            in: [2])
                                            in: [2, 5])
            scaleConfiguration = (nbInstances: nbInstances,
                                  nbDots: nbDots,
                                  scaleDuration: scaleDuration,
                                  secondFraction: true)
        case .quarterSecond:
            let nbInstances = Int(mediaDuration.rounded(.up)) * 4
            let scaleDuration = (mediaDuration / Double(nbInstances) * 0.25).rounded(.up) * Double(nbInstances) * 0.25
            let nbDots = greatestDotsNumber(forInstanceCount: nbInstances,
                                            in: [5])
            scaleConfiguration = (nbInstances: nbInstances,
                                  nbDots: nbDots,
                                  scaleDuration: scaleDuration,
                                  secondFraction: true)
        }
    }

    private func greatestDotsNumber(forInstanceCount count: Int,
                                    in possibleValues: [Int]) -> Int {
        let instanceSize = collectionView(collectionView,
                                          layout: collectionView.collectionViewLayout,
                                          sizeForItemAt: IndexPath(item: 0, section: 0)).width
        let possibleValuesSortedDecreaseOrder = possibleValues.sorted(by: >)
        let best = possibleValuesSortedDecreaseOrder.first {
            let minSpacing = $0 == 2
                ? Constants.minSingleSpacing
                : Constants.minDotSpacing
            return instanceSize / CGFloat($0) >= minSpacing
        } ?? possibleValuesSortedDecreaseOrder.last ?? 0
        return best
    }
}

extension TimeScaleView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nb = CGFloat(Double(scaleConfiguration.nbInstances) * mediaDuration / scaleConfiguration.scaleDuration)
        let instanceSize = CGFloat(mediaDuration * Double(pixelsPerSecond)) / nb
        return CGSize(width: instanceSize,
                      height: bounds.height)
    }
}

extension TimeScaleView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return scaleConfiguration.nbInstances
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeScaleStepCell.self),
                                                            for: indexPath) as? TimeScaleStepCell else {
            return UICollectionViewCell()
        }
        let timestamp: TimeInterval = scaleConfiguration.scaleDuration / Double(scaleConfiguration.nbInstances) * Double(indexPath.row+1)
        cell.configure(with: timestamp.getTimeScaleString(displaySecondFraction: scaleConfiguration.secondFraction),
                       nbDots: scaleConfiguration.nbDots,
                       isFirst: indexPath.row == 0)
        return cell
    }
}

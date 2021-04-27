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
        static let minSublayerSize: CGFloat = 40
    }

    // MARK: Properties

    var timeScaleLayer: TimeScaleLayer?


    // MARK: LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        timeScaleLayer?.frame = bounds
    }


    // MARK: Private

    private func setupLayout() {
        let timeScale = TimeScaleLayer(withDuration: 15, nbInstances: 3)
        layer.addSublayer(timeScale)

        timeScaleLayer = timeScale
    }
}

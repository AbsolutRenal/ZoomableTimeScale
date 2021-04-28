//
//  ViewController.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import UIKit

class ViewController: UIViewController {
    private lazy var timeScale: TimeScaleView = {
        let scale = TimeScaleView(mediaDuration: timelineDuration)
        return scale
    }()
    private let slider = UISlider()
    private let timelineDuration: TimeInterval = 765.87

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
    }

    private func setup() {
        slider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        slider.minimumValue = 15
        slider.maximumValue = 800
        slider.value = 50

        view.addSubview(slider)
        view.addSubview(timeScale)

        slider.translatesAutoresizingMaskIntoConstraints = false
        timeScale.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeScale.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeScale.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeScale.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timeScale.heightAnchor.constraint(equalToConstant: 20),

            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.topAnchor.constraint(equalTo: timeScale.bottomAnchor, constant: 30)
        ])
    }

    @objc private func sliderDidChange() {
        let pxPerSeconds = Int(slider.value)
        timeScale.updateScale(to: pxPerSeconds)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sliderDidChange()
    }
}







public extension TimeInterval {

    func getTimeScaleString(displaySecondFraction: Bool) -> String {
        guard !self.isNaN && self.isFinite else {
            return "0:00"
        }

        let interval = Int(self)
        let secondFraction = Int((self.truncatingRemainder(dividingBy: 1) * 100).rounded(.toNearestOrEven))
        let seconds = interval % 60
        let minutes = (interval / 60) % 60

        if displaySecondFraction {
            return String(format: "%0.2d:%0.2d.%0.2d", minutes, seconds, secondFraction)
        } else {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        }
    }
}

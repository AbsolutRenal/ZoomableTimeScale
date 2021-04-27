//
//  ViewController.swift
//  TimeScale
//
//  Created by Renaud Cousin on 4/27/21.
//

import UIKit

class ViewController: UIViewController {
    let timeScale = TimeScaleView()
    let slider = UISlider()
    private var timeScaleWithConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
    }

    private func setup() {
        slider.addTarget(self, action: #selector(sliderDidChange), for: .valueChanged)
        slider.minimumValue = 0.1
        slider.maximumValue = 1
        slider.value = 1

        view.addSubview(slider)
        view.addSubview(timeScale)

        slider.translatesAutoresizingMaskIntoConstraints = false
        timeScale.translatesAutoresizingMaskIntoConstraints = false

        timeScaleWithConstraint = timeScale.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            timeScale.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timeScale.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeScale.heightAnchor.constraint(equalToConstant: 20),
            timeScaleWithConstraint,

            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slider.topAnchor.constraint(equalTo: timeScale.bottomAnchor, constant: 30)
        ].compactMap({ $0 }))
    }

    @objc private func sliderDidChange() {
        timeScaleWithConstraint?.constant = view.frame.width * CGFloat(slider.value)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sliderDidChange()
    }
}







public extension TimeInterval {

    /// Converts a time interval to a human readable string, eg. '1:03:02' for 1 hour, 3 minutes, 2 seconds
    /// - Parameters: omitStartingZero is false -> '01:03:02'
    /// - Returns: A human readable string in Hours:Days:Minutes

    func getHumanReadableString(omitStartingZero: Bool = true) -> String {
        guard !self.isNaN && self.isFinite else {
            return "0:00"
        }

        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)

        let firstComponentFormat: String = omitStartingZero
        ? "0.1d"
        : "0.2d"

        if hours >= 10 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        } else if hours > 0 {
            return String(format: "%\(firstComponentFormat):%0.2d:%0.2d", hours, minutes, seconds)
        } else if minutes >= 10 {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        } else {
            return String(format: "%\(firstComponentFormat):%0.2d", minutes, seconds)
        }
    }
}

public final class GPFDurationFormatter {

    public static func formattedDuration(from time: TimeInterval?) -> String? {
        guard let duration = time else {
            return nil
        }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .positional
        return formatter.string(from: duration)
    }
}

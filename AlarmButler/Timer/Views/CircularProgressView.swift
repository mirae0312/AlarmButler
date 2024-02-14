//
//  CircularProgressView.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import UIKit

class CircularProgressView: UIView, CAAnimationDelegate {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    var trackColor: UIColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    var trackLineWidth: CGFloat = 5.0 {
        didSet {
            trackLayer.lineWidth = trackLineWidth
        }
    }

    var progressColor: UIColor = .systemOrange {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    var progressLineWidth: CGFloat = 5.0 {
        didSet {
            progressLayer.lineWidth = progressLineWidth
        }
    }

    var progressValue: CGFloat = 1.0 {
        didSet {
            // progressValue가 변경될 때마다 애니메이션을 통해 진행률 업데이트
            setProgressWithAnimation(duration: 2.0, value: progressValue)
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
    }

    private func setupView() {
        backgroundColor = .clear
    }

    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1.0
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)

        createCircularPath()
    }

    private func createCircularPath() {
        let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radius = min(frame.size.width, frame.size.height) / 2 - progressLineWidth / 2
        let startAngle = CGFloat.pi * 1.5 // 12시 방향
        let endAngle = startAngle - (2 * CGFloat.pi) // 12시 방향에서 완전히 한 바퀴
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

        trackLayer.path = path.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = trackLineWidth
        trackLayer.lineCap = .round

        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = progressLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1 // 오렌지 색으로 전체를 채움
    }

    func setProgressWithAnimation(duration: TimeInterval, value: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = value
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "animateProgress")
    }

}

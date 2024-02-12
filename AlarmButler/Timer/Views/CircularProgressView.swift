//
//  CircularProgressView.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/12/24.
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
    
    var progressColor: UIColor = .blue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var progressLineWidth: CGFloat = 5.0 {
        didSet {
            progressLayer.lineWidth = progressLineWidth
        }
    }
    
    var progressValue: Double = 0.5 {
        didSet {
            setProgress(value: progressValue)
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
    
    private func setupView() {
        backgroundColor = .clear
        setupLayers()
    }
    
    private func setupLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.lineCap = .round
        progressLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(progressLayer)
        
        createCircularPath()
    }
    
    private func createCircularPath() {
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: min(frame.size.width, frame.size.height) / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = trackLineWidth
        
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = progressLineWidth
        progressLayer.strokeEnd = CGFloat(progressValue)
    }
    
    func setProgress(value: Double) {
        guard let _ = progressLayer.superlayer else {
            return
        }
        progressLayer.strokeEnd = CGFloat(value)
    }

    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Handle animation stop if needed
    }
}

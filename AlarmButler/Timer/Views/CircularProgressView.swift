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
    
    var trackColor: UIColor = .systemOrange {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var trackLineWidth: CGFloat = 5.0 {
        didSet {
            trackLayer.lineWidth = trackLineWidth
        }
    }
    
    var progressColor: UIColor = .lightGray {
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
            setProgress(progressValue, animated: true)
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
        // 원의 중심을 계산
        let centerPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        // 원의 반지름을 계산
        let radius = min(frame.size.width, frame.size.height) / 2
        // 시작 각도와 끝 각도를 설정하여 UIBezierPath 생성
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        
        // 트랙 레이어 설정
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = trackLineWidth
        
        // 진행률 레이어 설정
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = progressLineWidth
        // strokeEnd를 사용하여 진행률을 설정 (값은 변경하지 않음)
        progressLayer.strokeEnd = CGFloat(progressValue)
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = progress
            animation.duration = 0.2 // Example duration
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: "progress")
        } else {
            progressLayer.strokeEnd = progress
        }
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.presentation()?.strokeEnd
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        progressLayer.add(animation, forKey: "animateProgress")
    }

    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            progressLayer.strokeEnd = CGFloat(progressValue)
        }
    }

}


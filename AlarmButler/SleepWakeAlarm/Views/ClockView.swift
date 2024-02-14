
//
//  Created by 김우경 on 2/13/24.
//

//import UIKit
//
//class ClockView: UIView {
//    
//    private var handleView: UIView!
//    private var handleCenter: CGPoint = .zero
//    private var startAngle: CGFloat = 0
//    
//    // 초기화 및 레이아웃 설정
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    private var radius: CGFloat {
//           return min(bounds.width / 2, bounds.height / 2) - 5
//       }
//    
//    // 드로잉 로직
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        backgroundColor = .clear
//        drawClockShape()
//    }
//    
//    // 시계 모양을 그리는 메서드
//    private func drawClockShape() {
//        guard let context = UIGraphicsGetCurrentContext() else {
//            return
//        }
//
//        let centerX = bounds.width / 2
//        let centerY = bounds.height / 2
//        let radius = min(centerX, centerY) - 5 // 시계의 반지름, 여유 공간을 주기 위해 5를 뺍니다.
//
//        // 시계 바깥쪽 원 그리기
//        context.setFillColor(UIColor.clear.cgColor) // 투명 배경
//        context.fillEllipse(in: CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2))
//
//        // 시계 표시를 위한 눈금 그리기
//        context.setLineWidth(1)
//        context.setStrokeColor(UIColor.black.cgColor)
//
//        for hour in 0..<24 {
//            let angle = CGFloat(hour) * (CGFloat.pi / 12)
//            let lineStart = CGPoint(x: centerX + radius * cos(angle), y: centerY + radius * sin(angle))
//            var lineEnd: CGPoint
//
//            // 큰 눈금일 때
//            lineEnd = CGPoint(x: centerX + (radius - 7) * cos(angle), y: centerY + (radius - 7) * sin(angle))
//            context.move(to: lineStart)
//            context.addLine(to: lineEnd)
//            context.strokePath()
//
//            // 시계의 동, 서, 남, 북 지점에 텍스트 추가
//            if hour % 6 == 0 {
//                let text: String
//                switch hour {
//                case 0:
//                    text = "오전6시"
//                case 6:
//                    text = "오후6시"
//                case 12:
//                    text = "오후12시"
//                case 18:
//                    text = "오전12시"
//                default:
//                    if [2, 4, 8, 10].contains(hour % 12) {
//                        text = "\(hour % 12)시"
//                    } else {
//                        text = ""
//                    }
//                }
//                if !text.isEmpty {
//                    let textSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
//                    
//                    // 위치 조절
//                    var textPoint = CGPoint(x: centerX + (radius - 35) * cos(angle) - textSize.width / 2, y: centerY + (radius - 25) * sin(angle) - textSize.height / 2)
//                    
//                    // 개별적으로 위치 조절
//                    if hour == 12 || hour == 18 {
//                        textPoint = CGPoint(x: centerX + (radius - 35) * cos(angle) - textSize.width / 2, y: centerY + (radius - 25) * sin(angle) - textSize.height / 2 )
//                    }
//                    
//                    (text as NSString).draw(at: textPoint, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black])
//                }
//            }
//
//            // 큰 눈금 사이에 작은 눈금 그리기
//            for smallHour in 1...3 { // 작은 눈금을 3개씩 추가
//                let smallAngle = angle + CGFloat(smallHour) * (CGFloat.pi / 36) // 1/36 각도
//                let smallLineStart = CGPoint(x: centerX + (radius - 7) * cos(smallAngle), y: centerY + (radius - 7) * sin(smallAngle))
//                let smallLineEnd = CGPoint(x: centerX + (radius - 3) * cos(smallAngle), y: centerY + (radius - 3) * sin(smallAngle))
//                context.move(to: smallLineStart)
//                context.addLine(to: smallLineEnd)
//                context.strokePath()
//            }
//        }
//    }
//
//    // 터치 이벤트 처리
//        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            guard let touch = touches.first else { return }
//            startAngle = angle(for: touch.location(in: self))
//            handleCenter = CGPoint(x: bounds.width / 2 + radius * cos(startAngle),
//                                   y: bounds.height / 2 + radius * sin(startAngle))
//            addHandle()
//        }
//
//        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//            guard let touch = touches.first else { return }
//            let currentAngle = angle(for: touch.location(in: self))
//            let angleDiff = currentAngle - startAngle
//
//            // 사용자의 손가락 이동에 따라 핸들을 회전시킵니다.
//            handleView.transform = handleView.transform.rotated(by: angleDiff)
//
//            // 각도를 시간으로 변환하여 사용할 수 있습니다.
//            let time = angleToTime(angle: angleDiff)
//            print("Selected Time: \(time)")
//
//            startAngle = currentAngle
//        }
//
//        // 핸들의 중심으로부터 터치 위치의 각도를 계산합니다.
//        private func angle(for touchLocation: CGPoint) -> CGFloat {
//            let deltaX = touchLocation.x - handleCenter.x
//            let deltaY = touchLocation.y - handleCenter.y
//            return atan2(deltaY, deltaX)
//        }
//
//        // 초기화 및 레이아웃 설정 메서드
//        private func setupUI() {
//            backgroundColor = .clear
//
//            // 시계 모양을 그립니다.
//            drawClockShape()
//
//            // 핸들을 추가합니다.
//            addHandle()
//        }
//
//
////    // 시계 모양을 그리는 메서드
////    private func drawClockShape() {
////        let clockPath = UIBezierPath(ovalIn: bounds.insetBy(dx: 10, dy: 10))
////        UIColor.systemBlue.setFill()
////        clockPath.fill()
////    }
//
//    // 추가: 핸들 추가 메서드
//      private func addHandle() {
//          handleView?.removeFromSuperview() // 기존 핸들 삭제
//
//          let handleRadius: CGFloat = 10.0
//          let handleCenterX = bounds.width / 2 + radius * cos(startAngle)
//          let handleCenterY = bounds.height / 2 + radius * sin(startAngle)
//
//          handleView = UIView(frame: CGRect(x: 0, y: 0, width: 2 * handleRadius, height: 2 * handleRadius))
//          handleView?.center = CGPoint(x: handleCenterX, y: handleCenterY)
//          handleView?.backgroundColor = .orange
//          handleView?.layer.cornerRadius = handleRadius
//          addSubview(handleView!)
//      }
//
//
//    // 각도를 시간으로 변환하는 메서드
//    private func angleToTime(angle: CGFloat) -> String {
//        // 각도를 시간으로 변환하는 로직을 여기에 추가
//        // 예: 360도를 12시간으로 나타내고 있으므로, 각도에 따라 시간을 계산합니다.
//        return "\(Int(angle * 12 / (2 * CGFloat.pi)))"
//    }
//}

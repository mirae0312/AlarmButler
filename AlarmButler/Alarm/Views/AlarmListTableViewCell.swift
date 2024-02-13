//
//  AlarmListTableViewCell.swift
//  AlarmButler
//
//  Created by mirae on 2/12/24.
//

import UIKit
import SnapKit

class AlarmListTableViewCell: UITableViewCell {
    let amPmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20) // 오전/오후 폰트 크기를 16으로 조정
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 50) // 폰트 크기를 36으로 조정
        label.adjustsFontSizeToFitWidth = true // 레이블 너비에 맞게 폰트 크기 조정
        label.minimumScaleFactor = 0.5 // 최소 스케일 인자 설정
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18) // 폰트 크기를 16으로 조정
        label.textColor = .lightGray
        return label
    }()
    
    let alarmSwitch: UISwitch = {
        let switchControl = UISwitch()
        // 추가적인 스위치 설정이 필요한 경우 여기서...
        return switchControl
    }()

    
    // 알람 객체와 함께 셀을 구성하는 메소드
    // configureWith 메서드 업데이트
    func configureWith(_ alarm: AlarmEntity) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let amPmFormatter = DateFormatter()
        amPmFormatter.dateFormat = "a" // 오전/오후만 표시
        amPmFormatter.locale = Locale(identifier: "ko_KR")
        
        timeLabel.text = dateFormatter.string(from: alarm.time ?? Date())
        amPmLabel.text = amPmFormatter.string(from: alarm.time ?? Date()).uppercased() // 오전/오후를 대문자로 표시
        descriptionLabel.text = alarm.title?.isEmpty ?? true ? "알람" : alarm.title // 타이틀이 비어있으면 "알람" 표시
        alarmSwitch.isOn = alarm.isEnabled
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellView() {
        // 셀에 컴포넌트들을 추가하고 SnapKit을 사용해 레이아웃 설정
        contentView.addSubview(amPmLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(alarmSwitch)
        
        // SnapKit을 사용한 레이아웃 설정
        amPmLabel.snp.makeConstraints { make in
            make.right.equalTo(timeLabel.snp.left).offset(-4)
            make.bottom.equalTo(timeLabel.snp.bottom).offset(-8)
        }
        
        // timeLabel 레이아웃 설정
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(self.contentView.snp.left).offset(55)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
        }
        
        alarmSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

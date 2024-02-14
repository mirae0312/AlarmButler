//
//  AlarmListTableViewCell.swift
//  AlarmButler
//
//  Created by mirae on 2/12/24.
//

import UIKit
import SnapKit
import CoreData

// 활성화 스위치 프로토콜
protocol AlarmListTableViewCellDelegate: AnyObject {
    func alarmSwitchDidChange(_ cell: AlarmListTableViewCell, isOn: Bool)
    func reloadTableView()
}

class AlarmListTableViewCell: UITableViewCell {
    weak var delegate: AlarmListTableViewCellDelegate?
    // 알람의 고유 ID를 저장하기 위한 프로퍼티
    var alarmId: NSManagedObjectID?
    
    let amPmLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 50)
        label.adjustsFontSizeToFitWidth = true // 레이블 너비에 맞게 폰트 크기 조정
        label.minimumScaleFactor = 0.5 // 최소 스케일 인자 설정
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .lightGray
        return label
    }()
    
    let alarmSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    let repeatDaysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18) // 반복 요일 폰트 크기 설정
        label.textColor = .lightGray
        return label
    }()
    
    // 알람 객체와 함께 셀을 구성하는 메소드
    // configureWith 메서드 업데이트
    func configureWith(_ viewModel: AlarmViewModel, alarmId: NSManagedObjectID) {
        timeLabel.text = viewModel.customTime
        amPmLabel.text = viewModel.amPm
        descriptionLabel.text = viewModel.title
        alarmSwitch.isOn = viewModel.isEnabled
        // 알람의 고유 ID 저장
        self.alarmId = alarmId
        
        // 스위치의 액션 설정
        alarmSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        // isEnabled 상태에 따라 텍스트 색상 조정
        if viewModel.isEnabled {
            amPmLabel.textColor = .black
            timeLabel.textColor = .black
        } else {
            amPmLabel.textColor = .lightGray
            timeLabel.textColor = .lightGray
        }

    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        // isEnabled 속성 변경
        let isEnabled = sender.isOn
        
        // 텍스트 색상 조정
        if isEnabled {
            amPmLabel.textColor = .black
            timeLabel.textColor = .black
        } else {
            amPmLabel.textColor = .lightGray
            timeLabel.textColor = .lightGray
        }
        
        // delegate에게 알람 스위치 상태 변경 알림
        delegate?.alarmSwitchDidChange(self, isOn: isEnabled)
        delegate?.reloadTableView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
        alarmSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
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

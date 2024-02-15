//
//  SleepWakeAlarmCell.swift
//  AlarmButler
//
//  Created by 김우경 on 2/9/24.
// SleepWakeAlarmCell.swift

import UIKit

class SleepWakeAlarmCell: UITableViewCell {
    
    // 셀 식별자
    static let identifier = "SleepWakeAlarmCell"
    
    // UI 요소들 정의
    
    // 취침 시간 라벨
    let bedtimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // 기상 시간 라벨
    let wakeUpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // 요일 라벨
    let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // 알람 스위치
    let alarmSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    // 편집 버튼
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("편집", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI 요소들을 서브뷰로 추가
        contentView.addSubview(bedtimeLabel)
        contentView.addSubview(wakeUpLabel)
        contentView.addSubview(dayLabel)
        contentView.addSubview(alarmSwitch)
        contentView.addSubview(editButton)
        
        // AutoLayout 설정 (예시)
        bedtimeLabel.snp.makeConstraints { make in
            // 취침 시간 라벨의 제약조건 설정
            // ...
        }
        
        // 나머지 UI 요소들에 대한 AutoLayout 설정 추가
        
        // 편집 버튼에 액션 추가
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    // configure 메서드: 뷰 모델을 기반으로 셀 구성
    func configure(with viewModel: SleepWakeAlarmCellViewModel) {
        // 취침 시간, 기상 시간, 요일 정보 설정
        bedtimeLabel.text = viewModel.bedtime
        wakeUpLabel.text = viewModel.wakeUpTime
        dayLabel.text = viewModel.days
        
        // 알람 스위치 상태 설정
        alarmSwitch.isOn = viewModel.isSwitchOn
    }
    
    // 편집 버튼 액션 처리
    @objc private func editButtonTapped() {
        // 편집 버튼이 탭되었을 때의 동작 구현
        // ...
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

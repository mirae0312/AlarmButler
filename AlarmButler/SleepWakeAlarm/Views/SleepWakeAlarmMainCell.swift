import UIKit
import SnapKit

class SleepWakeAlarmMainCell: UITableViewCell {
    
    // 요일 라벨
    let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    // 취침 시간 제목 라벨
    let bedtimeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "🛌취침 시간"
        return label
    }()
    
    // 취침 시간 라벨
    let bedtimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // 기상 시간 제목 라벨
    let wakeUpTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "⏰기상 시간"
        return label
    }()
    
    // 기상 시간 라벨
    let wakeUpLabel: UILabel = {
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
    // Box View
    let boxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2) // 투명도 조절
        view.layer.cornerRadius = 8 // 테두리를 둥글게 만듦
        return view
    }()
    
    // 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI 요소들을 서브뷰로 추가
        contentView.addSubview(boxView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(bedtimeTitleLabel)
        contentView.addSubview(bedtimeLabel)
        contentView.addSubview(wakeUpTitleLabel)
        contentView.addSubview(wakeUpLabel)
        contentView.addSubview(alarmSwitch)
        contentView.addSubview(editButton)
        
        // 상자 뷰에 대한 제약 조건
        boxView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8) // 상단 여백
            make.leading.equalToSuperview().offset(22) // 좌측 여백
            make.trailing.equalToSuperview().offset(-22) // 우측 여백
        }
        
        // 요일 라벨
        daysLabel.snp.makeConstraints { make in
            make.top.equalTo(boxView.snp.top).offset(16) // 박스 뷰의 상단에 위치하고 상단으로부터 16만큼 떨어져 있음
            make.leading.equalTo(boxView.snp.leading).offset(16) // 박스 뷰의 좌측에 위치하고 좌측으로부터 16만큼 떨어져 있음
        }
        
        // 취침 시간 제목 라벨
        bedtimeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(daysLabel.snp.bottom).offset(16) // 요일 라벨 아래에 위치하고 위쪽으로부터 16만큼 떨어져 있음
            make.leading.equalTo(daysLabel.snp.leading) // 요일 라벨과 같은 위치에 있음
        }
        
        // 취침 시간 라벨
        bedtimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(bedtimeTitleLabel.snp.centerY) // 취침 시간 제목 라벨과 세로 중앙 정렬
            make.leading.equalTo(bedtimeTitleLabel.snp.trailing).offset(8) // 취침 시간 제목 라벨의 오른쪽에 위치하고 좌측으로부터 8만큼 떨어져 있음
        }
        
        // 알람 스위치
        alarmSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(bedtimeTitleLabel.snp.centerY) // 취침 시간 제목 라벨과 세로 중앙 정렬
            make.trailing.equalTo(boxView.snp.trailing).offset(-10) // 박스 뷰의 우측에 위치하고 우측으로부터 20만큼 떨어져 있음
        }
        
        // 기상 시간 제목 라벨
        wakeUpTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bedtimeTitleLabel.snp.bottom).offset(20) // 취침 시간 라벨 아래에 위치하고 위쪽으로부터 16만큼 떨어져 있음
            make.leading.equalTo(daysLabel.snp.leading) // 요일 라벨과 같은 위치에 있음
        }
        
        // 기상 시간 라벨
        wakeUpLabel.snp.makeConstraints { make in
            make.centerY.equalTo(wakeUpTitleLabel.snp.centerY) // 기상 시간 제목 라벨과 세로 중앙 정렬
            make.leading.equalTo(wakeUpTitleLabel.snp.trailing).offset(8) // 기상 시간 제목 라벨의 오른쪽에 위치하고 좌측으로부터 8만큼 떨어져 있음
        }
        
        // 편집 버튼
        editButton.snp.makeConstraints { make in
            make.top.equalTo(alarmSwitch.snp.bottom).offset(5) // 알람 스위치 아래에 위치하고 위쪽으로부터 16만큼 떨어져 있음
            make.trailing.equalTo(boxView.snp.trailing).offset(-16) // 박스 뷰의 우측에 위치하고 우측으로부터 16만큼 떨어져 있음
            make.bottom.equalTo(boxView.snp.bottom).offset(-25) // 박스 뷰의 하단에 위치하고 아래쪽으로부터 16만큼 떨어져 있음
        }
        // 나머지 UI 요소들의 레이어 순서를 조정합니다.
        contentView.bringSubviewToFront(daysLabel)
        contentView.bringSubviewToFront(bedtimeTitleLabel)
        contentView.bringSubviewToFront(bedtimeLabel)
        contentView.bringSubviewToFront(wakeUpTitleLabel)
        contentView.bringSubviewToFront(wakeUpLabel)
        contentView.bringSubviewToFront(alarmSwitch)
        contentView.bringSubviewToFront(editButton)
        
    }
    // configure 메서드: 뷰 모델을 기반으로 셀 구성
    func configure(with viewModel: SleepWakeAlarmCellViewModel) {
        // 요일, 🛌취침 시간, ⏰기상 시간 정보 설정
        daysLabel.text = viewModel.days
        bedtimeLabel.text = viewModel.bedtime
        wakeUpLabel.text = viewModel.wakeUpTime
        
        // 알람 스위치 상태 설정
        alarmSwitch.isOn = viewModel.isSwitchOn
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  AlarmListTableViewCell.swift
//  AlarmButler
//
//  Created by mirae on 2/12/24.
//

import UIKit
import SnapKit

class AlarmListTableViewCell: UITableViewCell {
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    let alarmSwitch: UISwitch = {
        let switchControl = UISwitch()
        // 추가적인 스위치 설정은 여기서...
        return switchControl
    }()
    
    // ViewModel을 사용하여 셀을 구성하는 메서드
    func configureWith(_ viewModel: AlarmListViewModel) {

        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellView() {
        // 셀에 컴포넌트들을 추가하고 SnapKit을 사용해 레이아웃 설정
        contentView.addSubview(timeLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(alarmSwitch)
        
        // SnapKit을 사용한 레이아웃 설정 예시
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(timeLabel.snp.right).offset(8)
        }
        
        alarmSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

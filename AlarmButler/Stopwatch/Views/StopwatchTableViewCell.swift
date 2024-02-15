//
//  StopwatchTableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0039 on 2/7/24.
//

import SnapKit

class StopwatchTableViewCell: UITableViewCell {
    
    let lapCount = {
        var label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    let lapLabel = {
        var label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    let lapTimer = {
        var label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellView() {
        // 셀에 컴포넌트들을 추가하고 SnapKit을 사용해 레이아웃 설정
        contentView.addSubview(lapCount)
        contentView.addSubview(lapLabel)
        contentView.addSubview(lapTimer)
        
        // SnapKit을 사용한 레이아웃 설정 예시
        lapCount.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        lapLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        lapTimer.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func setUplapLabel(lapTime: String, mainTime: String) {
        lapLabel.text = lapTime
        lapTimer.text = mainTime
    }
    

    
    
}

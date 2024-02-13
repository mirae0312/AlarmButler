//
//  StopwatchTableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0039 on 2/7/24.
//

import UIKit

class StopwatchTableViewCell: UITableViewCell {
    
    let lapLabel = UILabel()
    let lapTimer = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        [lapLabel, lapTimer].forEach {
            contentView.addSubview($0)
        }
        
        lapLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(10)
            $0.width.height.equalTo(50)
        }
        
        lapTimer.snp.makeConstraints {
            $0.centerY.equalTo(lapLabel)
            $0.leading.equalTo(lapLabel.snp.trailing).offset(10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

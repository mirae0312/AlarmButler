//
//  TimerLabelTableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import UIKit
import SnapKit

class TimerLabelTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TimerRecordCell"
    
    var recordLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: TimerLabelTableViewCell.reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        if selected {
//            self.backgroundColor = UIColor.systemOrange
//        } else {
//            self.backgroundColor = UIColor.systemYellow
//        }
    }
    
    func setupUI() {
        self.backgroundColor = UIColor.systemGray6
        recordLabel.textColor = UIColor.label
        contentView.addSubview(recordLabel)
    }
    
    func setupLayout() {
        
        recordLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            
        }
    }
}

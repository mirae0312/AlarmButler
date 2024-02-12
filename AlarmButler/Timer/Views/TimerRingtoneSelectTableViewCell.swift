//
//  TimerRingtoneSelectTableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/12/24.
//

import UIKit
import SnapKit

class TimerRingtoneSelectTableViewCell: UITableViewCell {
    
    var soundLabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "RingCell")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupUI(){
        self.backgroundColor = UIColor.systemGray2
        
        soundLabel.textColor = UIColor.label
        
        contentView.addSubview(soundLabel)
        
        soundLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            
        }
    }
}

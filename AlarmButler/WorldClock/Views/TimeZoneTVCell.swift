//
//  TimeZoneTVCell.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import UIKit
import SwiftUI

class TimeZoneTableViewCell: UITableViewCell {
    
    static let identi = "AddTableViewCell"
    
    var data: String? {
        didSet {
            mainLabel.text = data
        }
    }
    
    var mainLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview()
        autolayout()
    }
    
    private func addSubview() {
        contentView.addSubview(mainLabel)
    }
    
    private func autolayout() {
        mainLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


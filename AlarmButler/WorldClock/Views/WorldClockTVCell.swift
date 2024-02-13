//
//  TableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import UIKit

class WorldClockViewCell: UITableViewCell {
    static let identi = "WorldClockViewCell"
    
        private lazy var worldLabel = {
            let worldLabel = UILabel()
            worldLabel.text = "세계 시계"
            worldLabel.textColor = .black
            worldLabel.font = UIFont.boldSystemFont(ofSize: 30)
    
            return worldLabel
        }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubView()
        autoLayout()
        
    }
    
    private func addSubView() {
        contentView.addSubview(worldLabel)
    }
    
    private func autoLayout() {
        worldLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
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

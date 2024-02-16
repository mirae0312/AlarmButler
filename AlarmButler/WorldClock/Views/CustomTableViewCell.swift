//
//  CustomTableViewCell.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/14/24.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    static let identi = "CustomCell"
    let worldClockManager = WorldClockManager.shared
    
    var clockData: WorldClockEntity? {
        didSet {
            setLabel()
        }
    }
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 45)
        return timeLabel
    }()
    
    private lazy var regionLabel: UILabel = {
        let regionLabel = UILabel()
        regionLabel.font = UIFont.systemFont(ofSize: 25)
        return regionLabel
    }()
    
    private lazy var offsetLabel: UILabel = {
        let offsetLabel = UILabel()
        return offsetLabel
    }()
    
    func setLabel() {
        guard let clock = clockData else {
            return
        }
        
        guard let tz = clock.timeZone else {
            return
        }
        
        timeLabel.text = worldClockManager.timeFromTimeZone(timeZone: tz, isNoon: false)
        regionLabel.text = clock.region
        offsetLabel.text = worldClockManager.getOffSetTimeZone(timeZone: tz)

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView() {
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(regionLabel)
        contentView.addSubview(offsetLabel)
    }
    
    private func autoLayout() {
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        regionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(8)
        }
        offsetLabel.snp.makeConstraints { make in
            make.bottom.equalTo(regionLabel.snp.top)
            make.leading.equalToSuperview().offset(8)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

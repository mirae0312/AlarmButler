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
    
    private lazy var noonLabel: UILabel = {
        let noonLabel = UILabel()
        
        return noonLabel
    }()
    
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        
        return timeLabel
    }()
    
    private lazy var regionLabel: UILabel = {
        let regionLabel = UILabel()
        
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
        noonLabel.text = worldClockManager.timeFromTimeZone(timeZone: tz, isNoon: true)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubView()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addSubView() {
        contentView.addSubview(noonLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(regionLabel)
        contentView.addSubview(offsetLabel)
        
        noonLabel.frame = CGRect(x: 10, y: 10, width: 100, height: 20)
        timeLabel.frame = CGRect(x: 10, y: 40, width: 100, height: 20)
        regionLabel.frame = CGRect(x: 10, y: 70, width: 100, height: 20)
        offsetLabel.frame = CGRect(x: 10, y: 100, width: 100, height: 20)
    }
    
    private func autoLayout() {
//        timeLabel.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-8)
//        }
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

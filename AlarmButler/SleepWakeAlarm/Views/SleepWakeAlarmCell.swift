//
//  SleepWakeAlarmCell.swift
//  AlarmButler
//
//  Created by 김우경 on 2/9/24.
//

import Foundation
import UIKit

class SleepWakeAlarmCell: UITableViewCell {

    // 추가: 셀에 표시될 라벨 등의 UI 요소들 정의
    let sleepGoalLabel = UILabel()
    let wakeUpTimeLabel = UILabel()

    // 추가: configure 메서드 정의
    func configure(with viewModel: SleepWakeAlarmCellViewModel) {
        // 뷰 모델에 따라 셀을 구성하는 로직 작성
        sleepGoalLabel.text = viewModel.sleepGoalText
        wakeUpTimeLabel.text = viewModel.wakeUpTimeText

        // 셀의 레이아웃 설정 등 추가 작업 수행
        // ...
    }

    // 다른 필요한 메서드들...
}

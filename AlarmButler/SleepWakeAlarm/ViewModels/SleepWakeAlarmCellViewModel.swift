//
//  SleepWakeAlarmCellViewModel.swift
//  AlarmButler
//
//  Created by 김우경 on 2/9/24.

//SleepWakeAlarmCellViewModelType.swift

import Foundation

protocol SleepWakeAlarmCellViewModelType {
    var sleepGoalText: String { get }
    var wakeUpTimeText: String { get }
}

class SleepWakeAlarmCellViewModel: SleepWakeAlarmCellViewModelType {
    var sleepGoalText: String
    var wakeUpTimeText: String

    init(sleepGoalText: String, wakeUpTimeText: String) {
        self.sleepGoalText = sleepGoalText
        self.wakeUpTimeText = wakeUpTimeText
    }
}

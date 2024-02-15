//
//  SleepWakeAlarmCellViewModel.swift
//  AlarmButler
//
//  Created by 김우경 on 2/9/24.

// SleepWakeAlarmCellViewModel.swift


import Foundation

protocol SleepWakeAlarmCellViewModelType {
    var sleepGoalText: String { get }
    var wakeUpTimeText: String { get }
}


class SleepWakeAlarmCellViewModel: SleepWakeAlarmCellViewModelType {
    var sleepGoalText: String
    var wakeUpTimeText: String
    
    // 추가: 예시 속성들
    var bedtime: String
    var wakeUpTime: String
    var days: String
    var isSwitchOn: Bool

    init(sleepGoalText: String, wakeUpTimeText: String, bedtime: String, wakeUpTime: String, days: String, isSwitchOn: Bool) {
        self.sleepGoalText = sleepGoalText
        self.wakeUpTimeText = wakeUpTimeText
        self.bedtime = bedtime
        self.wakeUpTime = wakeUpTime
        self.days = days
        self.isSwitchOn = isSwitchOn
    }

    // 예시: 취침 시간에 대한 문자열 반환
    func getBedtimeText() -> String {
        // 여기에 취침 시간에 대한 로직을 추가
        return "예시: 취침 시간"
    }

    // 예시: 기상 시간에 대한 문자열 반환
    func getWakeUpTimeText() -> String {
        // 여기에 기상 시간에 대한 로직을 추가
        return "예시: 기상 시간"
    }
}

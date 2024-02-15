//
//  SleepWakeAlarmViewModel.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//


// SleepWakeAlarmViewModel.swift

import Foundation

class SleepWakeAlarmViewModel {
    var sleepGoals: [Int] = []  // 예시 데이터
    var wakeUpTimes: [Date] = []  // 예시 데이터
    var selectedDay: String? // 선택된 요일을 저장하는 변수
    var isAlarmEnabled: Bool = true // 알람 활성/비활성 여부를 저장하는 변수

    // 초기화 메서드에서 데이터를 설정할 수 있도록 변경
    init(sleepGoals: [Int], wakeUpTimes: [Date]) {
        self.sleepGoals = sleepGoals
        self.wakeUpTimes = wakeUpTimes
    }

    func toggleAlarm() {
         isAlarmEnabled.toggle()
    }

    // cellViewModel(at:) 수정
    func cellViewModel(at indexPath: IndexPath) -> SleepWakeAlarmCellViewModel {
        let sleepGoal = sleepGoals[indexPath.row]
        let wakeUpTime = wakeUpTimes[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let wakeUpTimeString = dateFormatter.string(from: wakeUpTime) // Date를 String으로 변환

        // 예시 데이터, 실제 데이터와 맞게 수정해야 함
        let bedtime = "오후 10:00"
        let days = "월, 수, 금"
        let isSwitchOn = true

        return SleepWakeAlarmCellViewModel(sleepGoalText: "\(sleepGoal) 분", wakeUpTimeText: wakeUpTimeString, bedtime: bedtime, wakeUpTime: wakeUpTimeString, days: days, isSwitchOn: isSwitchOn)
    }
}

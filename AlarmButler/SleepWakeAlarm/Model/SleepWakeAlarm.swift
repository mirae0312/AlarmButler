//
//  SleepWakeAlarm.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

// SleepWakeAlarm.swift

import Foundation

struct SleepWakeAlarm {
    var sleepGoal: Int
    var wakeTime: Date
    var daysOfWeek: Set<String>
    var isAlarmOn: Bool
    // 다른 속성들도 추가 가능
}

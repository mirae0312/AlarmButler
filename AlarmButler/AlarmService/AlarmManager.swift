//
//  AlarmManager.swift
//  AlarmButler
//
//  Created by mirae on 2/14/24.
//

import Foundation
import UIKit
import CoreData

class AlarmManager {
    // 로컬 알림 스케줄링 로직
    func scheduleLocalNotification(for alarm: AlarmEntity, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.title = "Alarm Butler"
        content.body = alarm.title ?? "Alarm"
        
        if let soundFileName = alarm.sound {
            var soundFileNameWithExtension = soundFileName
            if !soundFileName.lowercased().hasSuffix(".mp3") && !soundFileName.lowercased().hasSuffix(".wav") {
                soundFileNameWithExtension += ".mp3"
            }
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileNameWithExtension))
        } else {
            content.sound = UNNotificationSound.default
        }
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: alarm.time ?? Date())
        
        var daysToSchedule = alarm.repeatDays as? [String] ?? []
        
        // 반복값이 없는 경우 일주일 내내 알람을 설정
        if daysToSchedule.isEmpty {
            daysToSchedule = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        }
        
        for day in daysToSchedule {
            var matchingComponents = DateComponents()
            matchingComponents.hour = triggerDate.hour
            matchingComponents.minute = triggerDate.minute
            let dayIdentifier: String
            
            switch day {
            case "일요일마다", "Sun":
                matchingComponents.weekday = 1
                dayIdentifier = "Sun"
            case "월요일마다", "Mon":
                matchingComponents.weekday = 2
                dayIdentifier = "Mon"
            case "화요일마다", "Tue":
                matchingComponents.weekday = 3
                dayIdentifier = "Tue"
            case "수요일마다", "Wed":
                matchingComponents.weekday = 4
                dayIdentifier = "Wed"
            case "목요일마다", "Thu":
                matchingComponents.weekday = 5
                dayIdentifier = "Thu"
            case "금요일마다", "Fri":
                matchingComponents.weekday = 6
                dayIdentifier = "Fri"
            case "토요일마다", "Sat":
                matchingComponents.weekday = 7
                dayIdentifier = "Sat"
            default:
                continue
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: matchingComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "\(alarm.alarmId?.uuidString ?? UUID().uuidString)-\(dayIdentifier)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    completion(error == nil)
                }
            }
        }
    }
    
    // 로컬 알림 제거
    func removeLocalNotification(for alarm: AlarmEntity) {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] // 영어 약어 사용
        let identifiers = days.map { "\(alarm.alarmId?.uuidString ?? UUID().uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Removed notifications for alarm ID: \(alarm.alarmId?.uuidString ?? "Unknown ID")")
    }

    // 알림 업데이트
    func updateLocalNotifications(for alarms: [AlarmEntity]) {
        for alarm in alarms {
            if alarm.isEnabled {
                // 활성화된 알람은 스케줄링
                scheduleLocalNotification(for: alarm) { _ in }
            } else {
                // 비활성화된 알람은 삭제
                removeLocalNotification(for: alarm)
            }
        }
    }
}

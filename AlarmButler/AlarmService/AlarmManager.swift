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
    // 로컬 알림을 스케줄링하는 메서드
    // AlarmEntity 객체를 받아 해당 알람 설정에 따라 로컬 알림을 생성
    func scheduleLocalNotification(for alarm: AlarmEntity, completion: @escaping (Bool) -> Void) {
        // 알림의 내용을 설정
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "ALARM_CATEGORY" // 알림의 카테고리를 설정,  알림의 유형을 구분
        content.title = "Alarm Butler" // 알림의 제목을 설정
        content.body = alarm.title ?? "Alarm" // 알림의 본문을 설정, 알람 객체에 제목이 없는 경우 "Alarm"을 기본값으로 사용
        
        // 알림의 소리를 설정, 사용자가 알람에 소리를 지정한 경우 해당 소리 파일을 사용하고, 그렇지 않은 경우 기본 소리를 사용
        if let soundFileName = alarm.sound {
            var soundFileNameWithExtension = soundFileName
            if !soundFileName.lowercased().hasSuffix(".mp3") && !soundFileName.lowercased().hasSuffix(".wav") {
                soundFileNameWithExtension += ".mp3" // 소리 파일에 확장자가 없는 경우 ".mp3"를 추가
            }
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileNameWithExtension))
        } else {
            content.sound = UNNotificationSound.default // 사용자가 소리를 지정하지 않은 경우 기본 소리를 사용
        }
        
        // 알림이 발생할 시간을 설정
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: alarm.time ?? Date())
        
        // 알림이 반복될 요일을 설정 사용자가 요일을 지정하지 않은 경우 매일 알림이 울리도록 설정
        var daysToSchedule = alarm.repeatDays as? [String] ?? []
        if daysToSchedule.isEmpty {
            daysToSchedule = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] // 사용자가 요일을 지정하지 않은 경우 일주일 내내 알람을 설정
        }
        
        // 설정된 요일마다 알림을 스케줄링
        for day in daysToSchedule {
            var matchingComponents = DateComponents()
            matchingComponents.hour = triggerDate.hour
            matchingComponents.minute = triggerDate.minute
            let dayIdentifier: String // 요일별 고유 식별자를 설정
            
            // 요일을 나타내는 DateComponents의 weekday를 설정하고, 알림 식별자에 사용될 요일별 문자열을 설정
            switch day {
            case "일요일마다", "Sun": matchingComponents.weekday = 1; dayIdentifier = "Sun"
            case "월요일마다", "Mon": matchingComponents.weekday = 2; dayIdentifier = "Mon"
            case "화요일마다", "Tue": matchingComponents.weekday = 3; dayIdentifier = "Tue"
            case "수요일마다", "Wed": matchingComponents.weekday = 4; dayIdentifier = "Wed"
            case "목요일마다", "Thu": matchingComponents.weekday = 5; dayIdentifier = "Thu"
            case "금요일마다", "Fri": matchingComponents.weekday = 6; dayIdentifier = "Fri"
            case "토요일마다", "Sat": matchingComponents.weekday = 7; dayIdentifier = "Sat"
            default: continue // 일치하는 요일이 없는 경우 다음 요일로 넘어감
            }
            
            // 알림 트리거를 설정하고 알림 요청을 추가
            let trigger = UNCalendarNotificationTrigger(dateMatching: matchingComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "\(alarm.alarmId?.uuidString ?? UUID().uuidString)-\(dayIdentifier)", content: content, trigger: trigger)
            
            // 설정된 알림을 사용자 알림 센터에 추가
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    completion(error == nil) // 알림 추가 성공 여부를 completion 핸들러를 통해 반환
                }
            }
        }
    }
    
    // 특정 알람에 대한 모든 로컬 알림을 제거하는 메서드
    func removeLocalNotification(for alarm: AlarmEntity) {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] // 요일별 식별자에 사용될 요일 문자열
        // 각 요일에 해당하는 알림 식별자를 생성
        let identifiers = days.map { "\(alarm.alarmId?.uuidString ?? UUID().uuidString)-\($0)" }
        // 생성된 식별자에 해당하는 모든 알림을 사용자 알림 센터에서 제거
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Removed notifications for alarm ID: \(alarm.alarmId?.uuidString ?? "Unknown ID")") // 제거 작업이 완료되면 콘솔에 메시지를 출력
    }

    // 모든 활성화된 알람에 대해 로컬 알림을 업데이트하는 메서드
    func updateLocalNotifications(for alarms: [AlarmEntity]) {
        for alarm in alarms {
            if alarm.isEnabled {
                // 활성화된 알람에 대해 알림을 다시 스케줄링
                scheduleLocalNotification(for: alarm) { _ in }
            } else {
                // 비활성화된 알람에 대한 알림을 제거
                removeLocalNotification(for: alarm)
            }
        }
    }
}

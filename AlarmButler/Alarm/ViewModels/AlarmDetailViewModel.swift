//
//  AlarmDetailViewModel.swift
//  AlarmButler
//
//  Created by mirae on 2/7/24.
//

import Foundation
import CoreData

class AlarmDetailViewModel {
    var title: String = ""
    var time: Date = Date()
    var sound: String = "거울"
    var isEnabled: Bool = true
    var repeatDays: Set<String> = []
    let alarmManager = AlarmManager()

    private var context: NSManagedObjectContext
    var alarm: AlarmEntity?

    init(context: NSManagedObjectContext, alarmId: NSManagedObjectID? = nil) {
        self.context = context
        if let alarmId = alarmId {
            self.alarm = context.object(with: alarmId) as? AlarmEntity
        }
    }

    func saveAlarm() {
        let alarmEntity: AlarmEntity
        if let existingAlarm = self.alarm {
            // 편집 모드
            alarmEntity = existingAlarm
            alarmEntity.title = self.title
            alarmEntity.time = self.time
            alarmEntity.sound = self.sound
            alarmEntity.isEnabled = self.isEnabled
            alarmEntity.repeatDays = Array(self.repeatDays) as NSObject

            // 기존에 스케줄링된 로컬 알림 취소
            alarmManager.removeLocalNotification(for: alarmEntity)
            print("알람 스케줄링이 성공적으로 삭제되었습니다.")
        } else {
            // 추가 모드
            alarmEntity = AlarmEntity(context: context)
            alarmEntity.title = self.title
            alarmEntity.time = self.time
            alarmEntity.sound = self.sound
            alarmEntity.isEnabled = self.isEnabled
            alarmEntity.alarmId = UUID()  // 새 알람에 대한 새 UUID 생성
            alarmEntity.repeatDays = Array(self.repeatDays) as NSObject
        }

        // Core Data에 알람 정보 저장
        do {
            try context.save()
            print("Alarm saved successfully")

            // 로컬 알림 스케줄링
            if alarmEntity.isEnabled {
                alarmManager.scheduleLocalNotification(for: alarmEntity) { success in
                    if success {
                        print("알람이 성공적으로 스케줄링되었습니다.")
                    } else {
                        print("알람이 스케줄링 중 일부에서 실패했습니다.")
                    }
                }
            }

        } catch let error as NSError {
            print("Could not save alarm. \(error), \(error.userInfo)")
        }
    }
    
    // 알람 상세 정보 불러오기 및 ViewModel 업데이트 메서드
    func loadAlarmData() {
        guard let alarm = self.alarm else {
            print("Failed to load alarm data.")
            return
        }
        
        // 알람 모델 업데이트, title이 없을 경우 "알람"으로 설정
        self.title = alarm.title ?? ""
        self.time = alarm.time ?? Date()
        self.sound = alarm.sound ?? "거울"
        self.isEnabled = alarm.isEnabled
        
        // repeatDays가 비어있는 경우 "안 함"을 포함한 셋으로 초기화
        let repeatDaysArray = alarm.repeatDays as? [String] ?? []
        if repeatDaysArray.isEmpty {
            self.repeatDays = Set(["안 함"])
        } else {
            // formatRepeatDays 함수를 사용하여 repeatDays 포맷팅
            let formattedRepeatDays = AlarmDetailViewModel.formatRepeatDays(repeatDaysArray)
            self.repeatDays = Set([formattedRepeatDays]) // 포맷된 결과를 Set으로 저장
        }
    }
    
    // 알람을 Core Data에서 삭제하는 함수
    func deleteAlarm(alarmId: NSManagedObjectID) {
        guard let alarmToDelete = context.object(with: alarmId) as? AlarmEntity else { return }
        // 로컬 알림 제거
        alarmManager.removeLocalNotification(for: alarmToDelete)
        context.delete(alarmToDelete)
        do {
            try context.save()
        } catch {
            print("삭제 실패: \(error)")
        }
    }

    static func formatRepeatDays(_ repeatDays: [String]) -> String {
        let dayOrder = ["일", "월", "화", "수", "목", "금", "토"]
        let weekDays = ["월", "화", "수", "목", "금"]
        let weekendDays = ["일", "토"]

        // '마다'를 제거하고 요일 이름만 추출
        let days = repeatDays.map { $0.replacingOccurrences(of: "요일마다", with: "") }
        
        // 요일을 순서대로 정렬
        let sortedDays = days.sorted { dayOrder.firstIndex(of: $0)! < dayOrder.firstIndex(of: $1)! }

        // 주중, 주말, 매일 판별
        if sortedDays.count == 7 {
            return "매일"
        } else if Set(sortedDays).isSuperset(of: Set(weekDays)) && sortedDays.count == 5 {
            return "주중"
        } else if Set(sortedDays).isSuperset(of: Set(weekendDays)) && sortedDays.count == 2 {
            return "주말"
        } else {
            // 요일이 하나인 경우
            if sortedDays.count == 1 {
                return "\(sortedDays.first!)요일마다"
            }
            // 요일이 두 개 이상인 경우
            else {
                let joinedDays = sortedDays.joined(separator: ", ")
                // '및'을 마지막 쉼표 대신에 넣기
                if let lastCommaRange = joinedDays.range(of: ",", options: .backwards) {
                    var formattedString = joinedDays
                    formattedString.replaceSubrange(lastCommaRange, with: " 및")
                    return formattedString
                } else {
                    return joinedDays // '및'이 필요 없는 경우
                }
            }
        }
    }
    
    
}

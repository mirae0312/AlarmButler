//
//  AlarmListViewModel.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation
import CoreData
import UIKit

class AlarmListViewModel {
    // Core Data 컨텍스트
    private var context: NSManagedObjectContext
    // 뷰에 표시될 알람 엔티티 배열
    var alarms: [AlarmEntity] = []
    // 뷰모델 리스트
    var alarmViewModels: [AlarmViewModel] = []
    // AppDelegate에서 설정한 기본 컨텍스트 사용
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }
    let alarmManager = AlarmManager()
    
    // Core Data에서 알람 목록을 불러오는 함수
    func fetchAlarmsAndUpdateViewModels() {
        let request: NSFetchRequest<AlarmEntity> = AlarmEntity.fetchRequest()
        do {
            alarms = try context.fetch(request)
            alarmViewModels = alarms.map { AlarmViewModel(alarm: $0) }
            
            // 오전과 오후를 구분하고, 같은 구분 내에서 시간 순으로 정렬
            alarmViewModels.sort { lhs, rhs in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "a hh:mm"
                dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 설정
                dateFormatter.timeZone = TimeZone.current
                
                // '오전' 또는 '오후' 문자열로 변환합니다.
                let lhsDate = dateFormatter.string(from: lhs.time)
                let rhsDate = dateFormatter.string(from: rhs.time)
                
                // 오후/오전을 먼저 비교합니다.
                if lhsDate.hasPrefix("오전") && rhsDate.hasPrefix("오후") {
                    return true
                } else if lhsDate.hasPrefix("오후") && rhsDate.hasPrefix("오전") {
                    return false
                }
                
                // 오후/오전이 같다면, 시간을 비교
                return lhsDate < rhsDate
            }
            
        } catch {
            print("알람 불러오기 실패: \(error.localizedDescription)")
        }
    }
    
    func updateAlarmEnabledState(alarmId: NSManagedObjectID, isEnabled: Bool) {
        do {
            // 해당 ID로 Core Data에서 알람 엔티티를 찾음
            guard let alarmToUpdate = try context.existingObject(with: alarmId) as? AlarmEntity else { return }
            
            // isEnabled 속성을 업데이트
            alarmToUpdate.isEnabled = isEnabled
            
            // 변경 사항을 저장
            try context.save()
            
            // 로컬 알림 업데이트
            if isEnabled {
                alarmManager.scheduleLocalNotification(for: alarmToUpdate) { success in
                    if success {
                        print("로컬 알림이 성공적으로 업데이트되었습니다.")
                    } else {
                        print("로컬 알림 업데이트 중 일부에서 실패했습니다.")
                    }
                }
            } else {
                alarmManager.removeLocalNotification(for: alarmToUpdate)
            }
        } catch {
            print("알람 상태 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // 새 알람을 Core Data에 추가하는 함수
    func addAlarm(time: Date, title: String, isEnabled: Bool, sound: String) {
        let alarmEntity = AlarmEntity(context: context) // 새 AlarmEntity 인스턴스 생성
        alarmEntity.time = time
        alarmEntity.title = title
        alarmEntity.isEnabled = isEnabled
        alarmEntity.sound = sound
        if let repeatDays = alarmEntity.repeatDays as? [String] {
            print("반복 요일: \(repeatDays.joined(separator: ", "))")
        }
        saveContext() // 컨텍스트 저장
        // 로컬 알림 설정
        alarmManager.scheduleLocalNotification(for: alarmEntity) { success in
            if success {
                print("로컬 알림이 성공적으로 스케줄링되었습니다.")
            } else {
                print("로컬 알림 스케줄링 중 일부에서 실패했습니다.")
            }
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
    
    // Core Data 컨텍스트의 변경사항을 저장하는 내부 함수
    private func saveContext() {
        do {
            try context.save() // 변경사항 저장
        } catch {
            print("변경사항 저장 실패: \(error.localizedDescription)")
        }
    }
    
}


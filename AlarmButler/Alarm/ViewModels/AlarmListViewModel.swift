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

    // AppDelegate에서 설정한 기본 컨텍스트 사용
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }

    // Core Data에서 알람 목록을 불러오는 함수
    func fetchAlarms() {
        let request: NSFetchRequest<AlarmEntity> = AlarmEntity.fetchRequest()
        do {
            alarms = try context.fetch(request) // 요청 실행해서 알람 목록 가져오기
        } catch {
            print("알람 불러오기 실패: \(error.localizedDescription)")
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
    }

    // 알람을 Core Data에서 삭제하는 함수
    func deleteAlarm(alarm: AlarmEntity) {
        context.delete(alarm) // 알람 삭제
        saveContext() // 컨텍스트 저장
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

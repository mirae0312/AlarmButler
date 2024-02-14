//
//  AlarmViewModel.swift
//  AlarmButler
//
//  Created by mirae on 2/13/24.
//

import Foundation
import CoreData

// AlarmEntity 인스턴스를 뷰에 표시될 정보를 포맷
class AlarmViewModel {
    let objectID: NSManagedObjectID
    let alarmId: NSManagedObjectID
    let time: Date
    var title: String // title을 변경 가능하도록 var로 선언
    let isEnabled: Bool
    var sound: String
    let repeatDays: String
    let amPm: String
    let customTime: String
    let defaultTitle: String
    var localTimeString: String

    init(alarm: AlarmEntity) {
        self.objectID = alarm.objectID
        self.alarmId = alarm.objectID
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let amPmFormatter = DateFormatter()
        amPmFormatter.dateFormat = "a"
        amPmFormatter.locale = Locale(identifier: "ko_KR")

        self.customTime = dateFormatter.string(from: alarm.time ?? Date())
        self.amPm = amPmFormatter.string(from: alarm.time ?? Date())
        self.isEnabled = alarm.isEnabled
        self.sound = alarm.sound ?? "거울"
        self.time = alarm.time ?? Date()
        self.defaultTitle = alarm.title ?? "알람"
        
        // title 설정
        if let title = alarm.title, !title.isEmpty {
            self.title = title
        } else {
            self.title = "알람"  // title이 비어 있거나 nil인 경우 "알람"으로 설정
        }

        // 중복을 제거하기 위해 Set을 사용하여 repeatDays를 처리
        let uniqueRepeatDays = Set(alarm.repeatDays as? [String] ?? [])
        self.repeatDays = AlarmViewModel.formatRepeatDays(Array(uniqueRepeatDays))
        
        // repeatDays 문자열이 비어 있지 않고, "알람"이 아닌 경우에만 title에 추가
        if !self.repeatDays.isEmpty && self.repeatDays != "알람" {
            self.title += ", \(self.repeatDays)"  // title과 repeatDays 사이에 ', ' 추가
        }
        // 시간 정렬을 위한 로컬시간
        self.localTimeString = dateFormatter.string(from: alarm.time ?? Date())
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



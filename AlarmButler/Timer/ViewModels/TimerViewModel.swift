//
//  TimerViewModel.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import Foundation
import UIKit

class TimerViewModel {
    
    // MARK: - Properties
    private let manager = TimerRecordManager.shared
    
    var timerRecords: [TimerRecord] = []
    var currentTimerId: UUID?
    
    var selectedRingtone: String?
    
    var time: [[Int]] {
        let hours = Array(0...23)
        let minutesAndSeconds = Array(0...59)
        return [hours, minutesAndSeconds, minutesAndSeconds]
    }
    
    // MARK: - Initialization
    init() {
        loadTimerRecords()
    }
    
    // MARK: - Functions
    
    func isActiveTimerExists() -> Bool {
        return timerRecords.contains { $0.isActive }
    }

    func loadTimerRecords() {
        timerRecords = manager.fetchTimerRecords()
    }
    
    func saveTimerRecord(duration: Int, label: String, ringTone: String, isActive: Bool) {
        guard let newRecord = manager.createTimerRecord(duration: duration, label: label, ringTone: ringTone, isActive: isActive) else { return }
        timerRecords.append(newRecord)
        currentTimerId = newRecord.id
    }
    
    func deleteTimerRecord(at index: Int) {
        let record = timerRecords[index]
        manager.deleteTimerRecord(id: record.id)
        timerRecords.remove(at: index)
    }

    // 타이머 기록의 상태를 업데이트하는 함수
    func updateTimerRecord(id: UUID, newIsActive: Bool? = nil) {
        manager.updateTimerRecord(id: id, newIsActive: newIsActive)
        loadTimerRecords() // 업데이트 후 타이머 기록을 다시 로드
    }
    
    private func formatTimeLabel(hour: Int, minute: Int, second: Int) -> String {
        let hourStr = hour == 0 ? "" : "\(hour)시 "
        let minuteStr = minute == 0 ? "" : "\(minute)분 "
        let secondStr = "\(second)초"
        return "\(hourStr)\(minuteStr)\(secondStr)"
    }
    
    func formatTimeForDisplay(duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func notifyTimerCompletion() {
        playSound(fileName: selectedRingtone ?? "toaster")
    }
}

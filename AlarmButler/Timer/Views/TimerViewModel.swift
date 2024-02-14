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
    var timer: Timer?
    var isOn: Bool = false
    var paused: Bool = false
    // 추가
    var remainingSeconds: Int = 0 {
        didSet {
            // remainingSeconds를 String으로 변환하여 클로저에 전달
            let formattedTime = formatTimeForDisplay(duration: remainingSeconds)
            onTimerUpdate?(formattedTime)
        }
    }
    var selectedRingtone: String?
    // MARK: - Closures for UI Update , 리액티브 프로그래밍 패턴
    var onTimerUpdate: ((String) -> Void)?

    var onTimerStateChange: ((Bool, Bool) -> Void)?

    // UI 업데이트를 위한 클로저
    var updateTimeLabelClosure: ((String) -> Void)?

    var updateUIStateClosure: ((Bool, UIColor) -> Void)?
    
    var durationInSeconds: Int = 0
    
    var duration: TimeInterval = 0
    
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
    
    // MARK: - Timer Management
    func startTimer(hour: Int, minute: Int, second: Int) {
//        let totalSeconds = hour * 3600 + minute * 60 + second
//        if totalSeconds == 0 { return }
//
//        durationInSeconds = totalSeconds
//        isOn = true
//        paused = false
//
//        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        // 타이머 시작 시 UI 업데이트 클로저 호출
        formatAndUpdateTimeLabel(hour: hour, minute: minute, second: second)
        
        timer?.fire()
        
        onTimerStateChange?(isOn, paused)
    }
    
    private func formatAndUpdateTimeLabel(hour: Int, minute: Int, second: Int) {
        let hourStr = hour == 0 ? "" : "\(hour)시 "
        let minuteStr = minute == 0 ? "" : "\(minute)분 "
        let secondStr = "\(second)초"
        let timeStr = "\(hourStr)\(minuteStr)\(secondStr)"

        updateTimeLabelClosure?(timeStr)
    }

    
    func pauseOrResumeTimer() {
        paused.toggle()
        if paused {
            timer?.invalidate()
        } else {
            startTimer(hour: 0, minute: 0, second: remainingSeconds)
        }
        onTimerStateChange?(isOn, paused)
    }
    
    // Record 타이머 새로시작 및 업데이트 로직
    func startRecordTimer(withDuration duration: Int) {
        remainingSeconds = duration
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.remainingSeconds > 0 {
                strongSelf.remainingSeconds -= 1
            } else {
                strongSelf.stopTimer()
            }
        }
    }
    
    // 타이머 업데이트 함수
    @objc func updateTimer() {
        // 타이머 뷰 업데이트 로직
        
        if remainingSeconds > 0 {
            // 남은 시간을 계산하여 표시
            remainingSeconds -= 1
            // 여기서 타이머 뷰에 남은 시간을 표시하는 로직을 추가
        } else {
            // 타이머 종료
            timer?.invalidate()
            timer = nil
            // 타이머가 종료되었음을 사용자에게 알리는 로직을 추가
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isOn = false
        paused = true
        remainingSeconds = 0
        if let id = currentTimerId {
            manager.updateTimerRecordIsActiveState(id: id, isActive: false)
        }
        onTimerStateChange?(isOn, paused)
        
        // 타이머 종료 시 알람음 재생
        if let ringtone = selectedRingtone, !ringtone.isEmpty {
            playSound(fileName: ringtone)
        }
        
        currentTimerId = nil
    }
    
    // 남은 시간을 계산 및 업데이트하는 로직
    func updateRemainingTime() {
        // 남은 시간 업데이트
    }
    
    private func updateRemainingSeconds() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            // 남은 시간을 포맷팅하여 전달
            let formattedTime = formatTimeForDisplay(duration: remainingSeconds)
            onTimerUpdate?(formattedTime)
        } else {
            stopTimer()
        }
    }
    
    func formatTimeForDisplay(duration: Int) -> String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isOn = false
        paused = true
        durationInSeconds = 0
        updateUI()
    }
    
    private func updateTime() {
        durationInSeconds -= 1
        if durationInSeconds <= 0 {
            resetTimer()
            return
        }
        // 여기서 타이머 레이블을 업데이트하기 위한 포맷팅 로직을 추가
        let timeString = formatTimeForDisplay(duration: durationInSeconds)
        updateTimeLabelClosure?(timeString)
    }
    
    private func updateUI() {
        // UI 업데이트 로직 (예: 색상 변경, 라벨 업데이트 등)
        let labelColor: UIColor = paused ? .tertiaryLabel : .label
        updateUIStateClosure?(paused, labelColor)
    }
    
    
}

//
//  StopwatchViewModel.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit



class StopwatchViewModel {
    var isRnunnig: State = .stop
    var laps: [StopwatchTimeModel] = []
    var mainTimer: Stopwatch = Stopwatch(.main)
    var lapTimer: Stopwatch = Stopwatch(.lap)
    
    weak var delegate: UpdateTimerLabelDelegate?
    
    var lapCount = 1
    
    // 시작과 멈춤 역할 메소드
    @objc func runAndStop(completion: () -> Void) {
        switch self.isRnunnig {
        case .stop:
            self.mainTimer.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(self.updateMainTimer), userInfo: nil, repeats: true)
            self.lapTimer.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(self.updateLapTimer), userInfo: nil, repeats: true)
            
            RunLoop.current.add(self.mainTimer.timer, forMode: RunLoop.Mode.common)
            RunLoop.current.add(self.lapTimer.timer, forMode: RunLoop.Mode.common)
            
            completion()
            self.isRnunnig = .runnig
            
        case .runnig:
            self.mainTimer.timer.invalidate()
            self.lapTimer.timer.invalidate()
            
            completion()
            self.isRnunnig = .stop
            
        }
    }

    
    // lap과 리셋 버튼 역할 메소드
    @objc func lapReset(mainTime: String?, lapTime: String?, completion: () -> Void) {
        switch self.isRnunnig {
        case .runnig:
            if let mainTime = mainTime, let lapTime = lapTime {
                laps.insert(StopwatchTimeModel(mainTime: mainTime, lapTime: lapTime), at: 0)
            }
            
            completion()
            resetLapTimer()
            lapTimer.timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(updateLapTimer), userInfo: nil, repeats: true)
            
            RunLoop.current.add(self.lapTimer.timer, forMode: .common)
            
        case .stop:
            resetMainTimer()
            resetLapTimer()
            completion()
        }
    }
    
    
    
    
    // Timer 리셋
    func resetMainTimer() {
        resetTimer(self.mainTimer)
        laps.removeAll()
        
    }
    
    func resetLapTimer() {
        resetTimer(self.lapTimer)
    }
    
    func resetTimer(_ stopwatch: Stopwatch) {
        stopwatch.timer.invalidate()
        stopwatch.counter = 0
    }
    
    
    // Timer 업데이트
    @objc func updateMainTimer() {
        self.updateTimer(self.mainTimer)
    }
    
    @objc func updateLapTimer() {
        self.updateTimer(self.lapTimer)
    }
    
    func updateTimer(_ stopwatch: Stopwatch) {
        stopwatch.counter += 0.035
        
        var minutes: String = "\((Int)(stopwatch.counter / 60))"
        var seconde: String = String(format: "%.2f", stopwatch.counter.truncatingRemainder(dividingBy: 60))
        
        if Int(stopwatch.counter / 60) < 10 {
          minutes = "0\(Int(stopwatch.counter / 60))"
        }
        
        if stopwatch.counter.truncatingRemainder(dividingBy: 60) < 10 {
          seconde = "0" + seconde
        }
        
        self.delegate?.updateTimer(stopwatch: stopwatch, minutes + ":" + seconde)
      }
}

extension Selector {
  static let updateMainTimer = #selector(StopwatchViewModel.updateMainTimer)
  static let updateLapTimer = #selector(StopwatchViewModel.updateLapTimer)
}

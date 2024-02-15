//
//  Stopwatch.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation

enum StopwatchType {
    case main
    case lap
}

enum State {
    case runnig
    case stop
}

protocol UpdateTimerLabelDelegate: class {
    func updateTimer(stopwatch: Stopwatch,_ text: String)
}

class Stopwatch {
    var counter: Double
    var timer: Timer
    var watchType: StopwatchType
    
    init(_ type: StopwatchType) {
        self.counter = 0.0
        self.timer = Timer()
        self.watchType = type
    }
}

class StopwatchTimeModel {
    var mainTime: String
    var lapTime: String

    init(mainTime: String, lapTime: String) {
        self.mainTime = mainTime
        self.lapTime = lapTime
    }
}

//
//  TimerManager.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/8/24.
//

import Foundation
import CoreData
import UIKit

class TimerManager {
    static let shared = TimerManager()
    
    private init() {}
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // TimerData를 CoreData에서 모두 가져옵니다.
    func fetchTimers(completion: @escaping ([TimerData]?, Error?) -> Void) {
        let request: NSFetchRequest<TimerData> = TimerData.fetchRequest()
        
        do {
            let timers = try context.fetch(request)
            completion(timers, nil)
        } catch let error as NSError {
            completion(nil, error)
        }
    }
    
    // 새 타이머(알람)을 CoreData에 저장합니다.
    func saveTimer(isOn: Bool, time: Date, label: String, isAgain: Bool, repeatDays: [String], sound: String, completion: @escaping (Bool, Error?) -> Void) {
        let newTimer = TimerData(context: context)
        newTimer.isOn = isOn
        newTimer.time = time
        newTimer.label = label
        newTimer.isAgain = isAgain
        newTimer.repeatDays = repeatDays.joined(separator: ",")
        newTimer.sound = sound
        
        do {
            try context.save()
            completion(true, nil)
        } catch let error as NSError {
            completion(false, error)
        }
    }
    
    // 특정 타이머(알람) 데이터를 업데이트합니다.
    func updateTimer(timer: TimerData, isOn: Bool, time: Date, label: String, isAgain: Bool, repeatDays: [String], sound: String, completion: @escaping (Bool, Error?) -> Void) {
        timer.isOn = isOn
        timer.time = time
        timer.label = label
        timer.isAgain = isAgain
        timer.repeatDays = repeatDays.joined(separator: ",")
        timer.sound = sound
        
        do {
            try context.save()
            completion(true, nil)
        } catch let error as NSError {
            completion(false, error)
        }
    }
    
    // 특정 타이머(알람) 데이터를 삭제합니다.
    func deleteTimer(timer: TimerData, completion: @escaping (Bool, Error?) -> Void) {
        context.delete(timer)
        
        do {
            try context.save()
            completion(true, nil)
        } catch let error as NSError {
            completion(false, error)
        }
    }
}

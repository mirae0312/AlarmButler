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

    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveAlarm() {
        let alarmIdValue = UUID()
        let alarmEntity = NSEntityDescription.insertNewObject(forEntityName: "AlarmEntity", into: context) as! AlarmEntity
        alarmEntity.title = self.title
        alarmEntity.time = self.time
        alarmEntity.sound = self.sound
        alarmEntity.isEnabled = self.isEnabled
        alarmEntity.alarmId = alarmIdValue
        alarmEntity.repeatDays = Array(self.repeatDays) as NSObject

        do {
            try context.save()
            print("Alarm saved successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}

//
//  TimerRecordManager.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import Foundation
import CoreData

class TimerRecordManager {
    
    static let shared = TimerRecordManager()
    private init() {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AlarmButler")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    func createTimerRecord(duration: Int, label: String, ringtone: String) -> AlarmButler.TimerRecord? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TimerRecord", in: context) else { return nil }
        let timerRecord = TimerRecord(entity: entity, insertInto: context)

        timerRecord.id = UUID()
        timerRecord.duration = Int32(duration)
        timerRecord.label = label
        timerRecord.ringTone = ringtone
        timerRecord.isActive = false

        saveContext()
        
        return timerRecord
    }

    func fetchTimerRecords() -> [TimerRecord] {
        let fetchRequest: NSFetchRequest<TimerRecord> = NSFetchRequest<TimerRecord>(entityName: "TimerRecord")
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
    
    func updateTimerRecord(id: UUID, newDuration: Int?, newLabel: String?, newRingtone: String?, newIsActive: Bool?) {
        if let timerRecord = fetchTimerRecords().first(where: { $0.id == id }) {
            if let duration = newDuration {
                timerRecord.duration = Int32(Int(duration))
            }
            if let label = newLabel {
                timerRecord.label = label
            }
            if let ringtone = newRingtone {
                timerRecord.ringTone = ringtone
            }
            if let isActive = newIsActive {
                timerRecord.isActive = isActive
            }
            saveContext()
        }
    }
    
    func deleteTimerRecord(id: UUID) {
        if let timerRecord = fetchTimerRecords().first(where: { $0.id == id }) {
            context.delete(timerRecord)
            saveContext()
        }
    }
}

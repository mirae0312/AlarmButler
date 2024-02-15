//
//  Timer.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation
import CoreData

@objc(TimerRecord)
public class TimerRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var duration: Int32
    @NSManaged public var label: String
    @NSManaged public var isActive: Bool
    @NSManaged public var ringTone: String
}

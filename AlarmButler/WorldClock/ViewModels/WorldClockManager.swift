//
//  worldClockManager.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/8/24.
//

import Foundation
import CoreData
import UIKit

class WorldClockManager {
    static let shared = WorldClockManager()
    
    //한국 표준시를 받아오자
    private var KST: String {
        get{
            // DateFormatter 메서드의 인스턴스. 날짜와 시간을 문자열로 형식화하는 데 사용.
            let dateFormatter = DateFormatter()
            //Locale을 한국 로케일로 설정(날짜와 시간을 한국어로 표시함)
            dateFormatter.locale = Locale(identifier: "ko_KR")
            //DateFormatter의 시간대를 현재 시스템의 시간대로 설정합니다.
            dateFormatter.timeZone = TimeZone.current
            // 날짜 형식을 "연도/월/일 시:분"으로 설정
            dateFormatter.dateFormat = "yyyy/MM/d HH:mm"
            //Date()로 현재 날짜와 시간을 가져와 dateFormatter를 사용하여 지정된 형식으로 문자열로 변환한 다음, 해당 문자열을 반환
            return dateFormatter.string(from: Date())
        }
    }
    
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    let modelName = "WorldClockEntity"
    
    //저장한 전체 세계 시간 목록 가져오기
    func getSavedWorldClock() -> [WorldClockEntity] {
        var result: [WorldClockEntity] = []
        
        if let context = context {
            let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
            
            let indexOrder = NSSortDescriptor(key: "index", ascending: true)
            request.sortDescriptors = [indexOrder]
            
            do {
                if let fetchedClock = try context.fetch(request) as? [WorldClockEntity] {
                    result = fetchedClock
                }
            } catch {
                print("시계 로직 오류")
            }
        }
        
        return result
    }
    
    //세계 시간 새로 저장
    func saveWorldClockData(newRegion:String, newTimeZone: TimeZone, completion: @escaping () -> Void) {
        //context가 nil인지 아닌지 확인
        guard let context = context else {
            print ("context 오류")
            completion()
            return
        }
        guard let entity = NSEntityDescription.entity(forEntityName: self.modelName, in: context) else {
            print("엔터티 오류")
            completion()
            return
        }
        guard let newWorldClock = NSManagedObject(entity: entity, insertInto: context) as? WorldClockEntity else {
            print("새로운 엔터티 오류")
            completion()
            return
        }
        
        newWorldClock.timeZone = newTimeZone.identifier
        newWorldClock.region = newRegion
        newWorldClock.date = Date()
        newWorldClock.index = Int64(getSavedWorldClock().count - 1)
        
        if(context.hasChanges) {
            do {
                try context.save()
                completion()
            } catch {
                print("context 저장 오류")
                completion()
            }
        }
    }
    
    //iOS 자체 타임존 목록 불러오기
    func getWorldClockData() -> [(String, TimeZone)] {
        var worldClickArray:[(String, TimeZone)] = []
        
        for timeZoneIdentifier in TimeZone.knownTimeZoneIdentifiers {
            guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else { continue }
            guard var regionName = timeZone.localizedName(for: .shortGeneric, locale: Locale(identifier: "ko-KR")) else {
                continue
            }
            
            var splitRegionName = regionName.split(separator: " ")
            let _ = splitRegionName.popLast()
            regionName = splitRegionName.joined()
            
            var selectsdWorld = Date.FormatStyle.dateTime
            selectsdWorld.timeZone = timeZone
            
            worldClickArray.append((regionName, timeZone))
        }
        //배열에 포함된 튜플들을 첫 번째 요소에 따라 알파벳순으로 정렬
        //lhs는 left-hand side / rhs는 right-hand side
        //lhs.0은 각 튜플의 첫 번째 요소이며, 지역 이름을 의미
        // 지역 이름을 기준으로 튜플을 오름차순
        worldClickArray.sort { lhs, rhs in
            lhs.0 < rhs.0
        }
        return worldClickArray
    }
}

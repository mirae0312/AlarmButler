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
    
    //한국 표준시를 나타내는 문자열,현재 시간을 제공
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
    
    //타임존을 불러오는 함수
    func getWorldClockData() -> [(String, TimeZone)] {
        //timezone에서 가져온 세계 시간 배열
        var worldClickArray:[(String, TimeZone)] = []
        
        //TimeZone.knownTimeZoneIdentifiers = 특정 지역의 표준 시간대를 나타내는 문자열 배열. 대륙/도시 형식
        for timeZoneIdentifier in TimeZone.knownTimeZoneIdentifiers {
            //타임존 타입의 생성자 함수에 전달하여 인스턴스를 생성
            guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else { continue }
            //Locale(identifier: "ko-KR") 한국어 설정, 한국 지역 설정
            guard var regionName = timeZone.localizedName(for: .shortGeneric, locale: Locale(identifier: "ko-KR")) else {
                continue
            }
            
            //마지막 요소 = '시간' 문자열. 시간 제거
            var splitRegionName = regionName.split(separator: " ")
            let _ = splitRegionName.popLast()
            regionName = splitRegionName.joined()
            
            worldClickArray.append((regionName, timeZone))
        }
        // 배열에 포함된 튜플들을 첫 번째 요소에 따라 알파벳순으로 정렬
        // lhs는 left-hand side / rhs는 right-hand side
        // lhs.0은 각 튜플의 첫 번째 요소(지역 이름)
        // 타임존 리스트를 가나다 순으로 정렬
        // 튜플이기 때문에 .sort()사용 불가 클로저 필요
        worldClickArray.sort { lhs, rhs in
            return lhs.0 < rhs.0
        }
        return worldClickArray
    }
    
    //타임존 기준 현재 시간 알아내는 함수, 현재 시간을 표시
    func timeFromTimeZone(timeZone: String, isNoon: Bool) -> String {
        guard let timeZone = TimeZone(identifier: timeZone) else {
            return ""
        }
        //현재시간 가져오기
        let worldDate = Date()
        //날짜, 시간 형식 정하기
        var selectedWorld = Date.FormatStyle.dateTime
        selectedWorld.timeZone = timeZone
        //현재 시간을 selectedWorld의 형식에 맞춰 포맷, selectedWorld.timeZone에 설정된 특정 시간대로 변환한 값을 반환
        var time = worldDate.formatted(selectedWorld).split(separator: " ")
        time.removeFirst()
        
        if(time.last! == "AM" || time.last! == "PM") {
            return isNoon ? "\(time.last! == "AM" ? "오전" : "오후")" : "\(time.first!)"
        }
        return isNoon ? "\(time.first!)" : "\(time.last!)"
    }
    
    //코어데이터에 세계 시간 저장
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
        //새로운 WorldClockEntity 객체를 생성하여 Core Data context에 추가
        guard let newWorldClock = NSManagedObject(entity: entity, insertInto: context) as? WorldClockEntity else {
            print("새로운 엔터티 오류")
            completion()
            return
        }
        
        // 새로운 WorldClockEntity 객체에 데이터를 설정
        newWorldClock.timeZone = newTimeZone.identifier // 시간대
        newWorldClock.region = newRegion // 지역
        newWorldClock.date = Date() // 현재 날짜, 시간
        newWorldClock.index = Int64(getSavedWorldClock().count - 1) // 인덱스 설정, 새로운 데이터 저장 공간 남겨두기 (-1)
        
        //context 변경사항 확인
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
    
    //코어데이터에 저장한 전체 세계 시간 목록 가져와서 인덱스 순으로 담기
    func getSavedWorldClock() -> [WorldClockEntity] {
        //반환할 배열 초기화
        var result: [WorldClockEntity] = []
        
        if let context = context {
            let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
            //ascending: true -> 오름차순으로 인덱스 기준 정렬
            let indexOrder = NSSortDescriptor(key: "index", ascending: true)
            request.sortDescriptors = [indexOrder]
            
            do {
                //코어데이터에서 데이터 검색
                if let fetchedClock = try context.fetch(request) as? [WorldClockEntity] {
                    //검색 결과 배열에 담기
                    result = fetchedClock
                }
            } catch {
                print("시계 로직 오류")
            }
        }
        return result
    }
    
    //현재 시간대에 해당하는 날짜가 어제일까 오늘일까 내일일까
    private func checkIsToday(timeZone: TimeZone) -> String {
        //현재 시간, 날짜 가져오기
        let worldDate = Date()
        //Date.FormatStyle.dateTime로 초기화. 날짜와 시간을 형식화할 방법을 나타내는 스타일
        var selectedWorld = Date.FormatStyle.dateTime
        //selectedWorld.timeZone에 원하는 시간대(timeZone)를 설정 (한국)
        selectedWorld.timeZone = timeZone
        //worldDate라는 변수에 현재 날짜와 시간을 저장한 후, formatted() 메서드를 사용하여 이 날짜를 selectedWorld 형식으로 포맷
        //현재 날짜 및 시간을 selectedWorld 형식에 맞게 문자열로 반환
        let formattedString = worldDate.formatted(selectedWorld)
        
        //포맷된 문자열에서 날짜 부분을 추출
        let date = formattedString.split(separator: " ").first!
        //날짜 부분 / 기준 분리
        let dateArray = date.split(separator: "/")
        
        // 연도와 월 정보를 제거
//        dateArray.removeFirst()
//        let _ = dateArray.popLast()
        
        //한국 표준시 날짜 가져오기
        let KSTArray = self.KST.split(separator: " ")
        let KSTDateArray = KSTArray.first?.split(separator: "/")
        
        //KST와 timezome에서 가져온 데이터 날짜 비교
        if let KSTLast = KSTDateArray?.last, let dateFirst = dateArray.first {
            if(Int(KSTLast)! < Int(dateFirst)!) {
                return "내일"
            } else if (Int(KSTLast)! == Int(dateFirst)!) {
                return "오늘"
            } else {
                return "어제"
            }
        }
        return "날짜를 확인할 수 없습니다."
    }
    
    //시차 반영하기
    func getOffSetTimeZone(timeZone: String) -> String {
        guard let timeZone = TimeZone(identifier: timeZone) else {
            return ""
        }
        //한국 표준시 가져오기
        guard let abbreviationName = timeZone.localizedName(for: Foundation.NSTimeZone.NameStyle.shortStandard, locale: Locale(identifier: "ko-KR")) else {
            return ""
        }
        //어제, 오늘, 내일 가져오기
        let todayString = checkIsToday(timeZone: timeZone)
        
        //T 기준으로 분리 (ex: KST+0900 -> KST 와 + 0900)
        let splitArray = abbreviationName.split(separator: "T")
        
        //KST만 있는 경우 오늘
        if(splitArray.count == 1) {
            return "오늘, +9시간"
        }
        
        let result = Int(splitArray.last!)!
        //9 - result가 0보다 크면 빠른 시간대를 의미, 그렇지 않은 경우에는 늦은 시간대를 의미하므로 "+(result - 9)시간"을 반환
        return 9 - result > 0 ? "\(todayString), -\(9 - result)시간" : "\(todayString), +\(result - 9)시간"
    }
    
    func removeClock(deleteTarget: WorldClockEntity, completion: @escaping () -> Void) {
        //context 가져오기
        guard let context = context else {
            print("Context가 nil입니다.")
            completion()
            return
        }
        //삭제할 데이터의 식별자를 가져오기
        let targetID = deleteTarget.date
        
        // NSFetchRequest를 생성
        let request = NSFetchRequest<WorldClockEntity>(entityName: self.modelName)
        //date 속성이 targetID와 일치하는 데이터를 찾도록 NSFetchRequest에 조건을 설정
        //%@는 나중에 대체될 값을 의미
        //as any CVarArg as CVarArg는 targetID를 CVarArg 타입으로 변환하는 과정(Objective-C와 Swift 타입 간의 호환성을 유지하기 위한 것)
        //targetID가 옵셔널이 아닌 경우 NSPredicate(format: "date == %@", targetID!)로 가능
        //삭제할 데이터를 식별하기 위한 조건을 설정
        request.predicate = NSPredicate(format: "date = %@", targetID! as CVarArg)
        
        do {
            //데이터 조회
            let fetchData = try context.fetch(request)
            //조회된 데이터 중 첫 번째 데이터
            if let data = fetchData.first {
                //데이터 삭제
                context.delete(data)
                
                do {
                    //변경 사항을 저장
                    try context.save()
                    print("데이터 삭제 성공")
                    completion()
                } catch {
                    print("데이터 삭제 저장 오류:", error.localizedDescription)
                    completion()
                }
            } else {
                print("인덱싱 오류: 데이터를 찾을 수 없습니다.")
                completion()
            }
        } catch {
            print("데이터 조회 오류:", error.localizedDescription)
            completion()
        }
    }
}

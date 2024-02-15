//
//  ClockDataManager.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/8/24.
//

import Foundation

class ClockDataManager {
    static let shared = ClockDataManager()
    
    //외부 인스턴스 생성 방지
    private init() {}
    
    //세계시계 데이터 반환하는 함수
    func getWorldData() -> [(String, String)] {
        var worldClickArray:[(String, String)] = []
        
        //세계 시계 데이터 수집
        //TimeZone.knownTimeZoneIdentifiers는 Swift에서 사용 가능한 모든 세계 각 지역의 표준 시간대의 문자열 배열
        //모든 지역 시간대를 반복해서 각 지역 시간대를 가져옴
        for timeZoneIdentifier in TimeZone.knownTimeZoneIdentifiers {
            // 시간대 식별자를 통해 TimeZone 인스턴스 생성
            guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else { continue }
            // GMT(그리니치 표준시) 정보
            guard let GMT = timeZone.abbreviation() else { continue }
            //각 시간대의 지역 이름 가져오기
            guard var regionName = timeZone.localizedName(for: .shortGeneric, locale: Locale(identifier: "ko-KR")) else { continue }
            
            //지역 이름에서 '시'를 제거
            //빈 문자열을 기준으로 분리
            var splitRegionName = regionName.split(separator: " ")
            //배열 마지막 요소 제거 ('시' 삭제)
            let _ = splitRegionName.popLast()
            //분리된 문자열 합치기
            regionName = splitRegionName.joined()
            
            //현재 시간을 해당 시간대로 변환
            //코드가 실행된 시점의 현재 시간이 저장
            let worldDate = Date()
            //Date.FormatStyle.dateTime는 날짜와 시간을 모두 포함하는 형식
            var selectedWorldDate = Date.FormatStyle.dateTime
            //timeZone에 해당하는 시간대로 selectedWorldDate를 설정
            selectedWorldDate.timeZone = timeZone
            
            worldClickArray.append((regionName, worldDate.formatted(selectedWorldDate)))
        }
        
        return worldClickArray
    }
}

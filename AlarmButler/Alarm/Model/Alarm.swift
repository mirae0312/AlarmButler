//
//  Alarm.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation

struct Alarm {
    var alarmId: String // 알람의 고유 ID
    var time: Date // 알람 시간
    var title: String // 알람 제목
    var isEnabled: Bool // 알람 활성화 상태
    var sound: String // 알람 소리 이름 또는 파일 경로
}

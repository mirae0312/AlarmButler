// SleepWakeAlarmViewModel.swift

import Foundation

class SleepWakeAlarmViewModel {
    var sleepGoals: [Int] = []  // 수면 목표
    var wakeUpTimes: [Date] = []  // 기상 시간
    var selectedDay: String? // 선택된 요일을 저장하는 변수
    var isAlarmEnabled: Bool = true // 알람 활성/비활성 여부를 저장하는 변수
    
    // 초기화 메서드에서 데이터를 설정할 수 있도록 변경
    init(sleepGoals: [Int], wakeUpTimes: [Date], selectedDay: String?) {
        self.sleepGoals = sleepGoals
        self.wakeUpTimes = wakeUpTimes
        self.selectedDay = selectedDay
    }
    
    func toggleAlarm() {
        isAlarmEnabled.toggle()
    }
    
    // cellViewModel(at:) 수정
    func cellViewModel(at indexPath: IndexPath) -> SleepWakeAlarmCellViewModel {
        let sleepGoal = sleepGoals[indexPath.row]
        let wakeUpTime = wakeUpTimes[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let wakeUpTimeString = dateFormatter.string(from: wakeUpTime) // Date를 String으로 변환

        // 선택된 요일과 기상 시간을 가져와서 셀 뷰 모델을 생성합니다.
        guard let selectedDay = selectedDay else {
            fatalError("선택된 요일이 없습니다.")
        }
        
        let viewModel = toCellViewModel(selectedDay: selectedDay, wakeUpTime: wakeUpTime, sleepGoal: sleepGoal)
        return viewModel
    }
    
    // toCellViewModel() 메서드 추가
    func toCellViewModel(selectedDay: String, wakeUpTime: Date, sleepGoal: Int) -> SleepWakeAlarmCellViewModel {
        // 기상 시간에서 수면 목표를 빼서 취침 시간을 계산합니다.
        let calendar = Calendar.current
        var components = DateComponents()
        components.minute = -sleepGoal // 수면 목표를 분 단위로 설정합니다.
        guard let bedtime = calendar.date(byAdding: components, to: wakeUpTime) else {
            fatalError("취침 시간을 계산할 수 없습니다.")
        }
        
        // DateFormatter를 사용하여 취침 시간을 문자열로 변환합니다.
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let bedtimeString = dateFormatter.string(from: bedtime)
        
        // 기타 데이터를 설정합니다.
        let wakeUpTimeString = dateFormatter.string(from: wakeUpTime)
        let days = selectedDay
        let isSwitchOn = true

        return SleepWakeAlarmCellViewModel(sleepGoalText: "\(sleepGoal) 분", wakeUpTimeText: wakeUpTimeString, bedtime: bedtimeString, wakeUpTime: wakeUpTimeString, days: days, isSwitchOn: isSwitchOn)
    }
}

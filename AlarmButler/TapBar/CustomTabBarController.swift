//
//  CustomTabBarController.swift
//  AlarmButler
//
//  Created by mirae on 2/6/24.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground() // 기본 배경 구성 사용
            // 배경색 직접 설정을 원할 경우 다음과 같이 설정
            // appearance.backgroundColor = .systemBackground
            
            // 탭 바 아이템과 관련된 속성도 설정할 수 있음
            // 예: 선택된 아이템과 선택되지 않은 아이템의 색상
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance // 스크롤 시 탭 바의 모습도 동일하게 유지
        } else {
            // iOS 15 이전에 대한 대체 설정
            tabBar.barTintColor = .systemBackground
        }
        setupTabBar()
    }
    
    func setupTabBar() {
        // 각 탭에 대한 뷰 컨트롤러 생성
        // TODO: (추후 각자 View명 보고 수정 필!)
        let worldClockVC = AlarmListView()
        worldClockVC.tabBarItem = UITabBarItem(title: "세계시간", image: UIImage(named: "worldClockIcon"), tag: 0)
        
        let alarmVC = AlarmListView() // 알람 뷰 컨트롤러
        alarmVC.tabBarItem = UITabBarItem(title: "알람", image: UIImage(named: "alarmIcon"), tag: 1)
        
        let stopwatchVC = AlarmListView()
        stopwatchVC.tabBarItem = UITabBarItem(title: "스톱워치", image: UIImage(named: "stopwatchIcon"), tag: 2)
        
        let timerVC = TimerViewController()
        timerVC.tabBarItem = UITabBarItem(title: "타이머", image: UIImage(named: "timerIcon"), tag: 3)
        
        let patternModeVC = AlarmListView()
        patternModeVC.tabBarItem = UITabBarItem(title: "패턴모드", image: UIImage(named: "patternModeIcon"), tag: 4)
        
        // 탭 바 컨트롤러에 뷰 컨트롤러들 추가
        // 세계시간, 알람, 스톱워치, 타이머, 패턴모드 순서로 배치
        viewControllers = [worldClockVC, alarmVC, stopwatchVC, timerVC, patternModeVC]
        
        // 초기 탭 설정 (알람 화면)
        selectedIndex = 1 // 첫 번째 탭(알람)을 초기 화면으로 설정
    }
}

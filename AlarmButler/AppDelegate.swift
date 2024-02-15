//
//  AppDelegate.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // UIWindow 생성 및 초기 ViewController 설정
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CustomTabBarController() // 탭바 CustomTabBarController
        window?.makeKeyAndVisible()
        
        // 알림 센터 설정
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        
        // '끄기' 액션 생성
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION",
                                                 title: "Dismiss",
                                                 options: [.destructive])
        
        // 알림 카테고리 생성
        let alarmCategory = UNNotificationCategory(identifier: "ALARM_CATEGORY",
                                                   actions: [dismissAction],
                                                   intentIdentifiers: [],
                                                   hiddenPreviewsBodyPlaceholder: "",
                                                   options: .customDismissAction)
        
        // 알림 센터에 카테고리 등록
        center.setNotificationCategories([alarmCategory])
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AlarmButler") // 모델 파일 이름 사용
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    // 앱이 포그라운드에 있을 때 알림이 도착했을 때 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // 알림과 소리로 사용자에게 알림을 표시
    }
    
    // 사용자가 알림을 탭했을 때 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알람 끄기 액션에 대한 처리
        if response.actionIdentifier == "DISMISS_ACTION" {
            // 알람 끄기 코드 (AlarmManager 클래스의 메서드를 호출)
        } else {
            // 사용자가 알람을 탭했을 때의 기존 처리
            let content = response.notification.request.content
            let alert = UIAlertController(title: content.title, message: content.body, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            var topController = UIApplication.shared.keyWindow?.rootViewController
            while let presentedViewController = topController?.presentedViewController {
                topController = presentedViewController
            }
            
            topController?.present(alert, animated: true, completion: nil)
            
            // 사용자가 알림을 무시했다고 가정하고, 1분 후에 다시 알림을 스케줄링
            scheduleLocalNotificationAfterMinute()
        }
        
        completionHandler()
    }
    
    // 1분 후에 알림을 다시 스케줄링하는 메서드
    func scheduleLocalNotificationAfterMinute() {
        let content = UNMutableNotificationContent()
        content.title = "2분 후에 알람이 다시 울립니다."
        content.body = "Don't forget to check your alarm!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false) // 60초 후에 트리거
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func showAlertForAlarm(_ title: String) {
        // 현재 활성화된 뷰 컨트롤러를 찾아 얼럿을 표시하는 로직
    }

}

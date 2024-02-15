//
//  AlarmListViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit
import SnapKit
import CoreData

class AlarmListViewController: UIViewController {
    var customNavigationBar: UIView!
    var titleLabel: UILabel!
    var editButton: UIButton!
    var addButton: UIButton!
    var tableView: UITableView!
    var viewModel = AlarmListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavigationBar()
        viewModel.fetchAlarmsAndUpdateViewModels() // 알람 데이터 불러오기
        setupTableView()
        // 로컬알림 목록 테스트용
        printPendingNotificationRequests()
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // 로컬알림 목록 테스트용
    func printPendingNotificationRequests() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            for request in requests {
                print("Pending Notification Request:")
                print("Identifier: \(request.identifier)")
                //print("Content: \(request.content)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let dateComponents = trigger.dateComponents
                    let hour = dateComponents.hour ?? 0
                    let minute = dateComponents.minute ?? 0
                    let weekday = dateComponents.weekday ?? 0
                    print("Date Components: \(hour):\(minute), Weekday: \(weekday)")
                }
                print("Repeats: \(request.trigger?.repeats ?? false)")
                print("-------------------------------------------------")
            }
        }
    }

    // 네비게이션 바 설정
    func setupCustomNavigationBar() {
        customNavigationBar = UIView()
        customNavigationBar.backgroundColor = .systemGray6
        view.addSubview(customNavigationBar)
        
        // Auto Layout 설정
        customNavigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44) // 네비게이션 바 표준 높이
        }
        
        // 타이틀 레이블 설정
        titleLabel = UILabel()
        titleLabel.text = "알람"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        customNavigationBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 편집 버튼 설정
        editButton = UIButton(type: .system)
        editButton.setTitle("편집", for: .normal)
        editButton.setTitleColor(.orange, for: .normal) // 텍스트 색상을 오렌지로 설정
        editButton.addTarget(self, action: #selector(toggleEditing), for: .touchUpInside)
        customNavigationBar.addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        // 추가 버튼 설정
        addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.orange, for: .normal)
        addButton.addTarget(self, action: #selector(addAlarm), for: .touchUpInside)
        customNavigationBar.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }

    // 새 알람 추가 액션
    @objc private func addAlarm() {
        let detailVC = AlarmDetailViewController()
        
        // onSave Closure 구현
        detailVC.onSave = { [weak self] in
            // 알람 저장 후 해야 할 작업
            self?.dismiss(animated: true, completion: nil) // 모달 닫기
            self?.viewModel.fetchAlarmsAndUpdateViewModels() // 알람 데이터 다시 불러오기
            self?.tableView.reloadData() // 테이블 뷰 리로드
        }
        
        present(detailVC, animated: true, completion: nil)
    }

    // 편집 모드 전환 액션
    @objc private func toggleEditing() {
        let isEditing = tableView.isEditing
        tableView.setEditing(!isEditing, animated: true)
        editButton.setTitle(isEditing ? "편집" : "완료", for: .normal)
    }

    // MARK: - 테이블뷰 설정
    // 테이블뷰 설정과 SnapKit을 사용한 레이아웃 정의
    private func setupTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlarmListTableViewCell.self, forCellReuseIdentifier: "AlarmListTableViewCell") // AlarmListTableViewCell 등록
        tableView.backgroundColor = UIColor.white //  설정

        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom) // 커스텀 네비게이션 바의 하단에 맞춤
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide) // 뷰의 하단 안전 영역에 맞춤
        }
    }
}

// UITableViewDataSource 및 UITableViewDelegate 구현
// UITableViewDataSource 구현
extension AlarmListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.alarms.count // 뷰 모델의 알람 개수 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmListTableViewCell", for: indexPath) as! AlarmListTableViewCell
        let alarmViewModel = viewModel.alarmViewModels[indexPath.row] // 이 부분 확인
        cell.configureWith(alarmViewModel, alarmId: alarmViewModel.alarmId)
        // 스위치의 값 변경 알림을 받기 위한 타겟 설정
        cell.alarmSwitch.addTarget(self, action: #selector(alarmSwitchDidChange(_:)), for: .valueChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0 // 셀의 높이를 100포인트로 설정
    }
    
    // 스위치 값 변경 처리
    @objc func alarmSwitchDidChange(_ sender: UISwitch) {
        guard let cell = sender.superview?.superview as? AlarmListTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let alarm = viewModel.alarms[indexPath.row]
        viewModel.updateAlarmEnabledState(alarmId: alarm.objectID, isEnabled: sender.isOn)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 알람의 IndexPath에서 알람 객체를 가져옴
        let alarmViewModel = viewModel.alarmViewModels[indexPath.row]
        
        // 상세 페이지로 전환
        let detailVC = AlarmDetailViewController()
        // onSave Closure 구현
        detailVC.onSave = { [weak self] in
            // 알람 저장 후 해야 할 작업
            self?.dismiss(animated: true, completion: nil) // 모달 닫기
            self?.viewModel.fetchAlarmsAndUpdateViewModels() // 알람 데이터 다시 불러오기
            self?.tableView.reloadData() // 테이블 뷰 리로드
        }
        detailVC.alarmId = alarmViewModel.objectID
        present(detailVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 데이터 모델에서 해당 데이터 삭제
            let alarmToDelete = viewModel.alarms[indexPath.row]
            viewModel.deleteAlarm(alarmId: alarmToDelete.objectID)
            
            // 뷰 모델에서 해당 알람 뷰 모델 삭제
            viewModel.alarms.remove(at: indexPath.row)
            
            // 테이블 뷰 새로고침
            tableView.reloadData()
        }
    }
    
    // 셀이 편집 가능한지 여부를 반환하는 메서드
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 모든 셀을 편집 가능하도록 설정
    }
    
    // 편집 스타일을 지정하는 메서드
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete // 삭제 가능하도록 설정
    }
    
    // 셀을 스와이프했을 때 삭제 버튼 텍스트를 설정하는 메서드
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제" // 삭제 버튼의 텍스트
    }
    
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
//struct ViewControllerPreview: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> AlarmListViewController {
//        return AlarmListViewController()
//    }
//    
//    func updateUIViewController(_ uiViewController: AlarmListViewController, context: Context) {
//        // 뷰 컨트롤러 업데이트가 필요할 때 사용
//    }
//}
//
//// SwiftUI Preview
//@available(iOS 13.0, *)
//struct ViewControllerPreview_Preview: PreviewProvider {
//    static var previews: some View {
//        ViewControllerPreview()
//            .edgesIgnoringSafeArea(.all) // Safe Area를 무시하고 전체 화면으로 표시하고 싶은 경우
//    }
//}
//#endif

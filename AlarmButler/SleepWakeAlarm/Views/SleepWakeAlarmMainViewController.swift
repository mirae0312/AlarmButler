// SleepWakeAlarmMainViewController.swift

import UIKit
import SnapKit

class SleepWakeAlarmMainViewController: UIViewController {
    
    static let identifier = "SleepWakeAlarmCell"
    
    // MARK: - Properties
    
    // 타이틀 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "알람"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    // 🛌 수면 | 기상 레이블 추가
    let sleepWakeLabel: UILabel = {
        let label = UILabel()
        label.text = "🛌 수면 | 기상"
        // 원하는 스타일과 설정을 추가할 수 있습니다.
        return label
    }()
    
    // 알람 리스트를 표시하는 UITableView
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(SleepWakeAlarmCell.self, forCellReuseIdentifier: SleepWakeAlarmCell.identifier)
        return tableView
    }()
    
    // 알람 추가 버튼
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 알람 데이터를 저장할 배열
    private var alarms: [SleepWakeAlarmViewModel] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        
        // 샘플 데이터 추가
        let sampleAlarm1 = SleepWakeAlarmViewModel(sleepGoals: [480], wakeUpTimes: [Date()])
        let sampleAlarm2 = SleepWakeAlarmViewModel(sleepGoals: [360], wakeUpTimes: [Date().addingTimeInterval(60*60)])  // 1시간 뒤
        alarms = [sampleAlarm1, sampleAlarm2]
        
        // 테이블 뷰 리로드
        tableView.reloadData()
        // 기타 UI 설정...
    }
    
    // MARK: - UI Setup
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 추가 버튼 설정
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-25)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16) // 추가 버튼을 화면 상단에 정렬
        }
        // addTarget 코드 추가
           addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        // 타이틀 레이블 설정
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(20) // 타이틀 레이블을 추가 버튼 아래에 정렬
            make.leading.equalToSuperview().offset(30) // 타이틀 레이블을 좌측에 정렬
        }
        
        // 🛌 수면 | 기상 레이블 추가
        view.addSubview(sleepWakeLabel)
        sleepWakeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20) // 🛌 수면 | 기상 레이블을 타이틀 레이블 아래로 내림
            make.leading.trailing.equalToSuperview().inset(30) // 좌우 여백 추가
        }
        // 실선 추가
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray // 실선 색상
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(sleepWakeLabel.snp.bottom).offset(8) // 레이블 아래에 위치
            make.leading.equalToSuperview().offset(25) // 좌측 여백 추가
            make.trailing.equalToSuperview().offset(-25) // 우측 여백 추가
            make.height.equalTo(0.2) // 실선 높이
        }
        // 테이블 뷰 설정
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(sleepWakeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16) // 테이블 뷰를 화면 하단까지 채우도록 수정
        }
    }
    // MARK: - Button Actions
    private func setupTableView() {
        // UITableView 설정 및 dataSource, delegate 등록
        // ...
    }
    @objc private func addButtonTapped() {
        let sleepWakeAlarmSetViewController = SleepWakeAlarmSetViewController()
        
        // 편집화면으로 이동할 때 메인화면을 델리게이트로 지정
        sleepWakeAlarmSetViewController.delegate = self
        
        // 새로운 편집 화면을 모달로 표시
        present(sleepWakeAlarmSetViewController, animated: true, completion: nil)
    }
}

extension SleepWakeAlarmMainViewController: SleepWakeAlarmSetViewControllerDelegate {
    func didFinishEditingAlarm(with alarm: SleepWakeAlarmViewModel) {
        // 편집이 완료되면 알람을 리스트에 추가
        alarms.append(alarm)
        
        // 테이블 뷰를 리로드하여 변경된 데이터를 반영
        tableView.reloadData()
    }
}
// MARK: - UITableViewDataSource

extension SleepWakeAlarmMainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SleepWakeAlarmCell.identifier, for: indexPath) as! SleepWakeAlarmCell
        let alarm = alarms[indexPath.row]
        let cellViewModel = alarm.cellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
//struct ViewControllerPreview: UIViewControllerRepresentable {
//  func makeUIViewController(context: Context) -> AlarmListViewController {
//    return AlarmListViewController()
//  }
//
//  func updateUIViewController(_ uiViewController: AlarmListViewController, context: Context) {
//    // 뷰 컨트롤러 업데이트가 필요할 때 사용
//  }
//}
//
//// SwiftUI Preview
//@available(iOS 13.0, *)
//struct ViewControllerPreview_Preview: PreviewProvider {
//  static var previews: some View {
//    ViewControllerPreview()
//      .edgesIgnoringSafeArea(.all) // Safe Area를 무시하고 전체 화면으로 표시하고 싶은 경우
//  }
//}
//#endif

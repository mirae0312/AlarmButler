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
        // "추가" 버튼이 눌렸을 때의 동작 구현
        // SleepWakeAlarmSetViewController 로 이동하는 코드 추가
        let setViewController = SleepWakeAlarmSetViewController()
        navigationController?.pushViewController(setViewController, animated: true)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct SleepWakeAlarmMainViewController_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UIViewControllerPreview {
                SleepWakeAlarmMainViewController()
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
#endif

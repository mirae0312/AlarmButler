//
//  SleepWakeAlarmViewController.swift
//  AlarmButler
//
//  Created by 김우경 on 2/9/24.
//

import Foundation
import UIKit

// SleepWakeAlarmViewController 클래스 정의
class SleepWakeAlarmViewController: UIViewController {
    
    // MARK: - Properties
    
    var sleepWakeAlarmViewModel: SleepWakeAlarmViewModel // 뷰 모델
    var goalTimeLabel: UILabel // 수면 목표를 표시할 라벨
    var sleepDurationTimePicker: UIDatePicker // 수면 목표를 설정할 타임 피커
    var isTimePickerVisible = false // 타임 피커의 가시성 여부
    var tableView: UITableView // 수면 목표와 기상 시각을 표시할 테이블 뷰
    
    // MARK: - 초기화 메서드
    
    init(sleepWakeAlarmViewModel: SleepWakeAlarmViewModel) {
        self.sleepWakeAlarmViewModel = sleepWakeAlarmViewModel
        self.goalTimeLabel = UILabel()
        self.sleepDurationTimePicker = UIDatePicker()
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
    }

    // 스토리보드 또는 인터페이스 빌더에서 사용하지 않을 경우 필수 구현
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 기상 시각을 표시할 라벨 및 타임 피커
    let wakeUpTimeLabel = UILabel()
    let wakeUpTimePicker = UIDatePicker()

    // MARK: - 뷰 라이프사이클 메서드

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSleepGoalPicker))
        goalTimeLabel.addGestureRecognizer(tapGesture)
    }

    // MARK: - 액션 메서드

    // 수면 목표 타임 피커의 가시성을 전환하는 메서드
    @objc private func toggleSleepGoalPicker() {
        if isTimePickerVisible {
            hideSleepGoalPicker()
        } else {
            showSleepGoalPicker()
        }
    }

    // 수면 목표 타임 피커를 보여주는 메서드
    @objc private func showSleepGoalPicker() {
        sleepDurationTimePicker.isHidden = false
        isTimePickerVisible = true
    }

    // 수면 목표 타임 피커를 숨기는 메서드
    @objc private func hideSleepGoalPicker() {
        sleepDurationTimePicker.isHidden = true
        isTimePickerVisible = false
    }

    // MARK: - UI 설정 메서드

    private func setupUI() {
        // 테이블 뷰 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SleepWakeAlarmCell.self, forCellReuseIdentifier: "SleepWakeAlarmCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // 수면 목표 라벨 설정
        let sleepGoalLabel = UILabel()
        sleepGoalLabel.text = "수면 목표"
        sleepGoalLabel.translatesAutoresizingMaskIntoConstraints = false

        // 목표 시간을 표시할 라벨 초기값 설정
        goalTimeLabel.text = "0시간"
        goalTimeLabel.textColor = UIColor.systemBlue
        goalTimeLabel.isUserInteractionEnabled = true
        goalTimeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSleepGoalPicker)))
        goalTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        // 수면 목표 타임 피커 설정
        sleepDurationTimePicker.datePickerMode = .countDownTimer
        sleepDurationTimePicker.locale = Locale(identifier: "en_GB")
        sleepDurationTimePicker.translatesAutoresizingMaskIntoConstraints = false
        sleepDurationTimePicker.addTarget(self, action: #selector(handleSleepGoalChange), for: .valueChanged)

        // 기상 시각 라벨 설정
        let wakeUpTimeLabel = UILabel()
        wakeUpTimeLabel.text = "기상 시각"
        wakeUpTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        // 기상 시각을 표시할 타임 피커 설정
        let wakeUpTimePicker = UIDatePicker()
        wakeUpTimePicker.datePickerMode = .time
        wakeUpTimePicker.translatesAutoresizingMaskIntoConstraints = false
        wakeUpTimePicker.addTarget(self, action: #selector(handleWakeUpTimeChange), for: .valueChanged)

        // 수평으로 배열할 StackView
        let horizontalStackView = UIStackView(arrangedSubviews: [sleepGoalLabel, goalTimeLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 16
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false

        // 수평으로 배열할 StackView
        let sleepPickerStackView = UIStackView(arrangedSubviews: [sleepDurationTimePicker])
        sleepPickerStackView.axis = .horizontal
        sleepPickerStackView.spacing = 16
        sleepPickerStackView.translatesAutoresizingMaskIntoConstraints = false

        // 수평으로 배열할 StackView
        let wakeUpStackView = UIStackView(arrangedSubviews: [wakeUpTimeLabel, wakeUpTimePicker])
        wakeUpStackView.axis = .horizontal
        wakeUpStackView.spacing = 16
        wakeUpStackView.translatesAutoresizingMaskIntoConstraints = false

        // 세로로 배열할 StackView
        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView, sleepPickerStackView, wakeUpStackView, tableView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 16
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

        // StackView를 메인 뷰에 추가
        view.addSubview(verticalStackView)

        // StackView의 제약조건 설정
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - 타임 피커 핸들링 메서드

    // 기상 시각이 변경될 때 호출되는 메서드
    @objc private func handleWakeUpTimeChange() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let selectedTime = dateFormatter.string(from: wakeUpTimePicker.date)
        print("Selected wake up time: \(selectedTime)")
    }

    // 수면 목표가 변경될 때 호출되는 메서드
    @objc private func handleSleepGoalChange() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: sleepDurationTimePicker.date)

        if let hour = components.hour, let minute = components.minute {
            goalTimeLabel.text = String(format: "%d시간 %02d분", hour, minute)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate 프로토콜 구현

extension SleepWakeAlarmViewController: UITableViewDataSource, UITableViewDelegate {

    // 테이블 뷰의 섹션당 행 개수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sleepWakeAlarmViewModel.sleepGoals.count
    }

    // 각 행에 대한 셀을 반환하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SleepWakeAlarmCell", for: indexPath) as? SleepWakeAlarmCell else {
            fatalError("Failed to dequeue SleepWakeAlarmCell")
        }

        // 셀에 표시할 뷰 모델 가져오기
        let cellViewModel = sleepWakeAlarmViewModel.cellViewModel(at: indexPath)
        // 셀 구성하기
        cell.configure(with: cellViewModel)

        return cell
    }
    // 주어진 indexPath에 대한 SleepWakeAlarmCellViewModel을 반환하는 메서드
    func cellViewModel(at indexPath: IndexPath) -> SleepWakeAlarmCellViewModel {
        return sleepWakeAlarmViewModel.cellViewModel(at: indexPath)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
struct SleepWakeAlarmViewController_Preview: UIViewControllerRepresentable {
    var sleepWakeAlarmViewModel: SleepWakeAlarmViewModel // 추가된 부분

    // 초기화 메서드
    init(sleepWakeAlarmViewModel: SleepWakeAlarmViewModel) {
        self.sleepWakeAlarmViewModel = sleepWakeAlarmViewModel
    }

    // UIViewController를 생성하여 반환하는 메서드
    func makeUIViewController(context: Context) -> SleepWakeAlarmViewController {
        return SleepWakeAlarmViewController(sleepWakeAlarmViewModel: sleepWakeAlarmViewModel)
    }

    // UIViewController를 업데이트하는 메서드
    func updateUIViewController(_ uiViewController: SleepWakeAlarmViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요할 때 사용
    }
}

// SwiftUI Preview
@available(iOS 16.0, *)
struct SleepWakeAlarmViewController_Preview_Preview: PreviewProvider {
    // 미리보기용 SleepWakeAlarmViewModel 인스턴스 생성
    static var previews: some View {
        let viewModel = SleepWakeAlarmViewModel(sleepGoals: ["8 hours", "7 hours", "6 hours"], wakeUpTimes: ["07:00 AM", "06:30 AM", "06:00 AM"])
        // SleepWakeAlarmViewController_Preview를 사용하여 미리보기 생성
        SleepWakeAlarmViewController_Preview(sleepWakeAlarmViewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
    }
}
#endif

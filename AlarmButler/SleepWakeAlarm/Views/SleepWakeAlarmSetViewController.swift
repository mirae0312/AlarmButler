//
//  SleepWakeAlarmSetViewController.swift
//  AlarmButler
//
//  Created by 김우경 on 2/10/24.

//SleepWakeAlarmSetViewController.swift

import Foundation
import UIKit

class SleepWakeAlarmSetViewController: UIViewController {

    // 추가 버튼
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)  // 텍스트 색상 추가
        // TODO: 추가 버튼에 대한 액션 추가 (필요시)
        return button
    }()

    // 취소 버튼
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)  // 텍스트 색상 추가
        // TODO: 취소 버튼에 대한 액션 추가 (필요시)
        return button
    }()

    // 활성화된 요일 라벨
    let activeDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "활성화된 요일"
        // TODO: 라벨 외관 설정 (필요시)
        return label
    }()

    // 활성화된 요일을 표시할 StackView
    lazy var activeDaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        // 원 화 수 목 금 토 일 버튼 추가
        let dayButtons: [UIButton] = ["월", "화", "수", "목", "금", "토", "일"].map { day in
            let button = UIButton()
            button.setTitle(day, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            return button
        }

        // StackView에 버튼들 추가
        dayButtons.forEach { stackView.addArrangedSubview($0) }

        // TODO: StackView 설정 (필요시)
        return stackView
    }()

    // 수면 목표 라벨
    let sleepGoalLabel: UILabel = {
        let label = UILabel()
        label.text = "수면 목표"
        // TODO: 라벨 외관 설정 (필요시)
        return label
    }()

    // 수면 목표를 선택할 UIDatePicker
    let sleepGoalPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.locale = Locale(identifier: "en_GB")
        // TODO: DatePicker 설정 (필요시)
        return picker
    }()

    // 기상 시각 라벨
    let wakeUpTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "기상 시각"
        // TODO: 라벨 외관 설정 (필요시)
        return label
    }()

    // 기상 시각 피커
    let wakeUpTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        // TODO: DatePicker 설정 (필요시)
        return picker
    }()

    // 알람 옵션 라벨
    let alarmOptionsLabel: UILabel = {
        let label = UILabel()
        label.text = "알람 옵션"
        // TODO: 라벨 외관 설정 (필요시)
        return label
    }()

    // 사운드 옵션 버튼
    let soundOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("사운드 옵션 바로가기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        // TODO: 버튼에 대한 액션 추가 (사운드 옵션 페이지로 이동하는 액션 등)
        return button
    }()

    // Dictionary to track selected days
    var selectedDays: [String: Bool] = [:]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI 설정 메서드

    private func setupUI() {
        // 배경색
        view.backgroundColor = .white

        // 스크롤 뷰 추가
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()

        view.addSubview(scrollView)

        // 스크롤 뷰의 제약 조건 설정
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 나머지 코드는 scrollView에 추가하도록 수정
        scrollView.addSubview(cancelButton)

        // 취소 버튼
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // 추가 버튼
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // 수면 패턴 추가 레이블
        let sleepPatternLabel: UILabel = {
            let label = UILabel()
            label.text = "수면 패턴 추가"
            label.font = UIFont.boldSystemFont(ofSize: 25) // 폰트 크기 조절
            // TODO: 라벨 외관 설정 (필요시)
            return label
        }()

        view.addSubview(sleepPatternLabel)
        sleepPatternLabel.translatesAutoresizingMaskIntoConstraints = false
        let topPadding: CGFloat = 0  // 위쪽 여백 크기 조절
        let spacingBetweenLabels: CGFloat = 16  // "수면 패턴 추가" 레이블과 "활성화된 요일" 레이블 사이의 여백 조절

        NSLayoutConstraint.activate([
            sleepPatternLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: topPadding),
            sleepPatternLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        view.addSubview(activeDaysLabel)
        activeDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activeDaysLabel.topAnchor.constraint(equalTo: sleepPatternLabel.bottomAnchor, constant: spacingBetweenLabels),
            activeDaysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // 활성화된 요일 레이블
        view.addSubview(activeDaysLabel)
        activeDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activeDaysLabel.topAnchor.constraint(equalTo: sleepPatternLabel.bottomAnchor, constant: 16),
            activeDaysLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // 활성화된 요일 스택 뷰
        let activeDaysBox: UIView = {
            let box = createTopicBox()
            return box
        }()

        activeDaysBox.addSubview(activeDaysStackView)
        activeDaysStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activeDaysStackView.topAnchor.constraint(equalTo: activeDaysBox.topAnchor, constant: 8),
            activeDaysStackView.leadingAnchor.constraint(equalTo: activeDaysBox.leadingAnchor, constant: 16),
            activeDaysStackView.trailingAnchor.constraint(equalTo: activeDaysBox.trailingAnchor, constant: -16),
            activeDaysStackView.bottomAnchor.constraint(equalTo: activeDaysBox.bottomAnchor, constant: -8)
        ])


        view.addSubview(activeDaysBox)
        activeDaysBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activeDaysBox.topAnchor.constraint(equalTo: activeDaysLabel.bottomAnchor, constant: 8),
            activeDaysBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            activeDaysBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])

        // 세부 사항 레이블
        view.addSubview(sleepGoalLabel)
        sleepGoalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepGoalLabel.topAnchor.constraint(equalTo: activeDaysBox.bottomAnchor, constant: 32),
            sleepGoalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // 수면 목표 피커
        let sleepGoalBox: UIView = {
            let box = createTopicBox()
            box.addSubview(sleepGoalPicker)
            sleepGoalPicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sleepGoalPicker.topAnchor.constraint(equalTo: box.topAnchor, constant: 8),
                sleepGoalPicker.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
                sleepGoalPicker.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
                sleepGoalPicker.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8)
            ])
            return box
        }()

        view.addSubview(sleepGoalBox)
        sleepGoalBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepGoalBox.topAnchor.constraint(equalTo: sleepGoalLabel.bottomAnchor, constant: 8),
            sleepGoalBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            sleepGoalBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])

        // 기상 시각 라벨
        view.addSubview(wakeUpTimeLabel)
        wakeUpTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wakeUpTimeLabel.topAnchor.constraint(equalTo: sleepGoalBox.bottomAnchor, constant: 16),
            wakeUpTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])

        // 기상 시각 피커 박스
        let wakeUpTimeBox: UIView = {
            let box = createTopicBox()
            box.addSubview(wakeUpTimeLabel)
            box.addSubview(wakeUpTimePicker)
            wakeUpTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            wakeUpTimePicker.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                wakeUpTimeLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 8),
                wakeUpTimeLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),

                wakeUpTimePicker.topAnchor.constraint(equalTo: wakeUpTimeLabel.topAnchor),
                wakeUpTimePicker.leadingAnchor.constraint(equalTo: wakeUpTimeLabel.trailingAnchor, constant: 8),
                wakeUpTimePicker.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
                wakeUpTimePicker.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8),

                wakeUpTimeLabel.centerYAnchor.constraint(equalTo: wakeUpTimePicker.centerYAnchor),
                wakeUpTimeLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8)
            ])

            return box
        }()

        view.addSubview(wakeUpTimeBox)
        wakeUpTimeBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wakeUpTimeBox.topAnchor.constraint(equalTo: sleepGoalBox.bottomAnchor, constant: 16),
            wakeUpTimeBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            wakeUpTimeBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])

        // 알람 옵션 레이블
        view.addSubview(alarmOptionsLabel)
        alarmOptionsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alarmOptionsLabel.topAnchor.constraint(equalTo: wakeUpTimeBox.bottomAnchor, constant: 16),
            alarmOptionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])

        // 사운드 옵션 레이블 추가
        view.addSubview(soundOptionButton)
        soundOptionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundOptionButton.topAnchor.constraint(equalTo: alarmOptionsLabel.bottomAnchor, constant: 16),
            soundOptionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // 사운드 옵션 상자 추가
        let soundOptionBox: UIView = {
            let box = createTopicBox()
            return box
        }()

        view.addSubview(soundOptionBox)
        soundOptionBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundOptionBox.topAnchor.constraint(equalTo: alarmOptionsLabel.bottomAnchor, constant: 16),
            soundOptionBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            soundOptionBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            soundOptionBox.heightAnchor.constraint(equalToConstant: 100) // 높이 조절
        ])

        soundOptionBox.addSubview(soundOptionButton)
        soundOptionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundOptionButton.centerXAnchor.constraint(equalTo: soundOptionBox.centerXAnchor),
            soundOptionButton.centerYAnchor.constraint(equalTo: soundOptionBox.centerYAnchor)
        ])

        // 여기에 스크롤 뷰의 contentSize 설정
        let yourDesiredHeight: CGFloat = soundOptionBox.frame.maxY + 30
        scrollView.contentSize = CGSize(width: view.frame.width, height: yourDesiredHeight)
    }

    // 토픽 박스 생성
    private func createTopicBox() -> UIView {
        let box = UIView()
        box.backgroundColor = .systemGray6
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        return box
    }

    // 요일 버튼이 눌렸을 때 호출되는 메서드
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.currentTitle ?? ""
        
        // 선택한 요일의 텍스트 색상을 토글
        if let isSelected = selectedDays[day] {
            selectedDays[day] = !isSelected
        } else {
            selectedDays[day] = true
        }

        // 업데이트된 상태에 따라 텍스트 색상 변경
        let textColor: UIColor = selectedDays[day] ?? false ? .systemBlue : .black
        sender.setTitleColor(textColor, for: .normal)
    }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct SleepWakeAlarmSetViewController_Preview: PreviewProvider {
    static var previews: some View {
        // SleepWakeAlarmSetViewController를 UIViewRepresentable로 래핑하여 미리보기
        SleepWakeAlarmSetViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

// UIViewController를 UIViewRepresentable로 래핑하는 구조체
@available(iOS 13.0, *)
struct SleepWakeAlarmSetViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SleepWakeAlarmSetViewController {
        return SleepWakeAlarmSetViewController()
    }

    func updateUIViewController(_ uiViewController: SleepWakeAlarmSetViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요한 경우 처리
    }
}
#endif

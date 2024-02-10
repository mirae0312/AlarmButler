//
//  SleepWakeAlarmSetViewController.swift
//  AlarmButler
//
//  Created by 김우경 on 2/10/24.
//

import Foundation
import UIKit

class SleepWakeAlarmSetViewController: UIViewController {
    
    // 추가 버튼
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        // TODO: 추가 버튼에 대한 액션 추가 (필요시)
        return button
    }()
    
    // 취소 버튼
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
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
    let activeDaysStackView: UIStackView = {
        let stackView = UIStackView()
        // TODO: StackView 설정 및 요일 버튼 추가 (필요시)
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
    
    // 기상 시각을 선택할 UIDatePicker
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
    
    // 사운드 및 햅틱 설정 라벨
    let soundAndHapticLabel: UILabel = {
        let label = UILabel()
        label.text = "사운드 및 햅틱"
        // TODO: 라벨 외관 설정 (필요시)
        return label
    }()
    
    // 사운드 볼륨 조절 슬라이더
    let soundSlider: UISlider = {
        let slider = UISlider()
        // TODO: 슬라이더 설정 (필요시)
        return slider
    }()
    
    // 다시 알림 설정 스위치
    let repeatAlarmSwitch: UISwitch = {
        let switchControl = UISwitch()
        // TODO: 스위치 설정 (필요시)
        return switchControl
    }()
    
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
        let activeDaysStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.distribution = .fillEqually

            // 원 화 수 목 금 토 일 버튼 추가
            let dayButtons: [UIButton] = ["월", "화", "수", "목", "금", "토", "일"].map { day in
                let button = UIButton()
                button.setTitle(day, for: .normal)
                button.setTitleColor(.black, for: .normal)
                // TODO: 버튼에 대한 액션 추가 (필요시)
                return button
            }

            // StackView에 버튼들 추가
            dayButtons.forEach { stackView.addArrangedSubview($0) }

            // TODO: StackView 설정 (필요시)
            return stackView
        }()

        // 활성화된 요일 상자
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
            return box
        }()

        sleepGoalBox.addSubview(sleepGoalPicker)
        sleepGoalPicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepGoalPicker.topAnchor.constraint(equalTo: sleepGoalBox.topAnchor, constant: 8),
            sleepGoalPicker.leadingAnchor.constraint(equalTo: sleepGoalBox.leadingAnchor, constant: 16),
            sleepGoalPicker.trailingAnchor.constraint(equalTo: sleepGoalBox.trailingAnchor, constant: -16),
            sleepGoalPicker.bottomAnchor.constraint(equalTo: sleepGoalBox.bottomAnchor, constant: -8)
        ])

        view.addSubview(sleepGoalBox)
        sleepGoalBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sleepGoalBox.topAnchor.constraint(equalTo: sleepGoalLabel.bottomAnchor, constant: 8),
            sleepGoalBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            sleepGoalBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        // 기상 시각 레이블
        view.addSubview(wakeUpTimeLabel)
        wakeUpTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wakeUpTimeLabel.topAnchor.constraint(equalTo: sleepGoalBox.bottomAnchor, constant: 16),
            wakeUpTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        // 기상 시각 피커
        let wakeUpTimeBox: UIView = {
            let box = createTopicBox()
            return box
        }()
        
        wakeUpTimeBox.addSubview(wakeUpTimePicker)
        wakeUpTimePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wakeUpTimePicker.topAnchor.constraint(equalTo: wakeUpTimeBox.topAnchor, constant: 8),
            wakeUpTimePicker.leadingAnchor.constraint(equalTo: wakeUpTimeBox.leadingAnchor, constant: 16),
            wakeUpTimePicker.trailingAnchor.constraint(equalTo: wakeUpTimeBox.trailingAnchor, constant: -16),
            wakeUpTimePicker.bottomAnchor.constraint(equalTo: wakeUpTimeBox.bottomAnchor, constant: -8)
        ])
        
        view.addSubview(wakeUpTimeBox)
        wakeUpTimeBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wakeUpTimeBox.topAnchor.constraint(equalTo: wakeUpTimeLabel.bottomAnchor, constant: 8),
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
        
        // 사운드 및 햅틱 레이블
        view.addSubview(soundAndHapticLabel)
        soundAndHapticLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundAndHapticLabel.topAnchor.constraint(equalTo: alarmOptionsLabel.bottomAnchor, constant: 8),
            soundAndHapticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        // 사운드 슬라이더
        let soundSliderBox: UIView = {
            let box = createTopicBox()
            return box
        }()
        
        soundSliderBox.addSubview(soundSlider)
        soundSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundSlider.topAnchor.constraint(equalTo: soundSliderBox.topAnchor, constant: 8),
            soundSlider.leadingAnchor.constraint(equalTo: soundSliderBox.leadingAnchor, constant: 16),
            soundSlider.trailingAnchor.constraint(equalTo: soundSliderBox.trailingAnchor, constant: -16),
            soundSlider.bottomAnchor.constraint(equalTo: soundSliderBox.bottomAnchor, constant: -8)
        ])
        
        view.addSubview(soundSliderBox)
        soundSliderBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            soundSliderBox.topAnchor.constraint(equalTo: soundAndHapticLabel.bottomAnchor, constant: 8),
            soundSliderBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            soundSliderBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        // 다시 알림 스위치
        let repeatAlarmSwitchBox: UIView = {
            let box = createTopicBox()
            return box
        }()
        
        repeatAlarmSwitchBox.addSubview(repeatAlarmSwitch)
        repeatAlarmSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            repeatAlarmSwitch.topAnchor.constraint(equalTo: repeatAlarmSwitchBox.topAnchor, constant: 8),
            repeatAlarmSwitch.leadingAnchor.constraint(equalTo: repeatAlarmSwitchBox.leadingAnchor, constant: 16),
            repeatAlarmSwitch.trailingAnchor.constraint(equalTo: repeatAlarmSwitchBox.trailingAnchor, constant: -16),
            repeatAlarmSwitch.bottomAnchor.constraint(equalTo: repeatAlarmSwitchBox.bottomAnchor, constant: -8)
        ])
        
        view.addSubview(repeatAlarmSwitchBox)
        repeatAlarmSwitchBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            repeatAlarmSwitchBox.topAnchor.constraint(equalTo: soundSliderBox.bottomAnchor, constant: 8),
            repeatAlarmSwitchBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            repeatAlarmSwitchBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            repeatAlarmSwitchBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        // 여기에 스크롤 뷰의 contentSize 설정
          let yourDesiredHeight: CGFloat = repeatAlarmSwitchBox.frame.maxY + 30  // 필요한 만큼 조절하세요
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

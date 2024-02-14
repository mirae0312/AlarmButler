// SleepWakeAlarmSetViewController.swift
// 수면 및 기상 알람 설정을 위한 뷰 컨트롤러

import UIKit
import SnapKit

// 델리게이트를 위한 프로토콜 정의
protocol SleepWakeAlarmSetViewControllerDelegate: AnyObject {
    func didFinishEditingAlarm(with alarm: SleepWakeAlarmViewModel)
}
    
class SleepWakeAlarmSetViewController: UIViewController {

    // 약한 참조로 델리게이트 프로퍼티 추가
       weak var delegate: SleepWakeAlarmSetViewControllerDelegate?

    // MARK: - 속성
    
    // 활성화된 요일을 담을 박스
    private lazy var activeDaysBox: UIView = {
        let box = UIView()
        box.backgroundColor = .systemGray6
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        return box
    }()
    
    // 저장 버튼
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 저장 버튼 액션
     @objc private func saveButtonTapped() {
         // 선택된 요일, 수면 목표, 기상 시각 등을 사용하여 알람을 생성
         let createdAlarm = createAlarm()

         // 델리게이트를 통해 알람이 추가되었음을 알림
         delegate?.didFinishEditingAlarm(with: createdAlarm)

         // 화면을 닫거나 다른 작업을 수행할 수 있음
         navigationController?.popViewController(animated: true)
     }

     // 알람을 생성하는 메서드 (수면 목표, 기상 시각 등을 사용)
     private func createAlarm() -> SleepWakeAlarmViewModel {
         // 실제 알람 생성 로직 구현

         // 임시로 예시 데이터 사용
         let sleepGoals = [480] // 예시: 8시간을 분 단위로 표현
         let wakeUpTimes = [Date()] // 예시: 현재 시각

         return SleepWakeAlarmViewModel(sleepGoals: sleepGoals, wakeUpTimes: wakeUpTimes)
     }

    
    // 취소 버튼
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 수면 패턴 추가 레이블
    private let sleepPatternLabel: UILabel = {
        let label = UILabel()
        label.text = "수면 패턴 추가"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    // 활성화된 요일 레이블
    private let activeDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "활성화된 요일"
        return label
    }()
    
    // 활성화된 요일 스택 뷰
    let activeDaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        // 월, 화, 수, 목, 금, 토, 일 버튼 추가
        let dayButtons: [UIButton] = ["월", "화", "수", "목", "금", "토", "일"].map { day in
            let button = UIButton()
            button.setTitle(day, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            return button
        }
        
        // StackView에 버튼들 추가
        dayButtons.forEach { stackView.addArrangedSubview($0) }
        
        return stackView
    }()
    private var selectedDays: [String: Bool] = [:]
    // 선택된 요일을 로드하는 메서드
    private func loadSelectedDays() {
        for (day, isSelected) in selectedDays {
            if isSelected {
                if let button = activeDaysStackView.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == day }) {
                    button.setTitleColor(.systemBlue, for: .normal)
                }
            }
        }
    }
    
    // 주어진 토픽에 대한 박스를 생성하는 메서드
    private func createTopicBox() -> UIView {
        let box = UIView()
        box.backgroundColor = .systemGray6
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        box.translatesAutoresizingMaskIntoConstraints = false  // Auto Layout을 사용하기 위해 false로 설정
        return box
    }

    // 버튼이 탭되었을 때의 처리 메서드
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.currentTitle ?? ""
        
        if let isSelected = selectedDays[day] {
            selectedDays[day] = !isSelected
        } else {
            selectedDays[day] = true
        }
        
        let textColor: UIColor = selectedDays[day] ?? false ? .systemBlue : .black
        sender.setTitleColor(textColor, for: .normal)
    }
    // 수면 목표 레이블 추가
       private let sleepGoalLabel: UILabel = {
           let label = UILabel()
           label.text = "수면 목표"
           return label
       }()

       // 수면 목표를 선택할 UIDatePicker 추가
       private let sleepGoalPicker: UIDatePicker = {
           let picker = UIDatePicker()
           picker.datePickerMode = .countDownTimer
           picker.locale = Locale(identifier: "en_GB")
           return picker
       }()
    
    // 기상 시각 레이블 추가
      private let wakeUpTimeLabel: UILabel = {
          let label = UILabel()
          label.text = "기상 시각"
          return label
      }()
    
    // 기상 시각 피커 추가
      private let wakeUpTimePicker: UIDatePicker = {
          let picker = UIDatePicker()
          picker.datePickerMode = .time
          return picker
      }()
    
    // 알람 옵션 레이블 추가
        private let alarmOptionsLabel: UILabel = {
            let label = UILabel()
            label.text = "알람 옵션"
            return label
        }()
    
    // 사운드 옵션 버튼 추가
     private let soundOptionButton: UIButton = {
         let button = UIButton()
         button.setTitle("사운드 옵션 바로가기", for: .normal)
         button.setTitleColor(.systemBlue, for: .normal)
         return button
     }()
    // MARK: - 뷰 라이프사이클
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UI 설정 메서드 호출
        loadSelectedDays() // 선택된 요일 로드
    }
    
    // MARK: - UI 설정 메서드
    
    private func setupUI() {
        // 뷰 배경색 설정
        view.backgroundColor = .white
        
        // 스크롤뷰 생성
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 컨텐츠 뷰 추가
        let contentView: UIView = {
            let view = UIView()
            return view
        }()

        scrollView.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
        
        // 취소 버튼 설정
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 추가 버튼 설정
        contentView.addSubview(saveButton)
              saveButton.snp.makeConstraints { make in
                  make.top.equalToSuperview().offset(8)
                  make.trailing.equalToSuperview().offset(-16)
              }
        
        // 수면 패턴 추가 레이블 설정
        contentView.addSubview(sleepPatternLabel)
        sleepPatternLabel.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        // 활성화된 요일 레이블 설정
        contentView.addSubview(activeDaysLabel)
        activeDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(sleepPatternLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 활성화된 요일 박스 설정
        contentView.addSubview(activeDaysBox)
        activeDaysBox.snp.makeConstraints { make in
            make.top.equalTo(activeDaysLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        // 활성화된 요일 스택 뷰 설정
        activeDaysBox.addSubview(activeDaysStackView)
        activeDaysStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        // 수면 목표 레이블 설정
        contentView.addSubview(sleepGoalLabel)
        sleepGoalLabel.snp.makeConstraints { make in
            make.top.equalTo(activeDaysBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 수면 목표 박스 설정
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
        
        contentView.addSubview(sleepGoalBox)
        sleepGoalBox.snp.makeConstraints { make in
            make.top.equalTo(sleepGoalLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        // 기상 시각 레이블 설정
        contentView.addSubview(wakeUpTimeLabel)
        wakeUpTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sleepGoalBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        // 기상 시각 박스 설정
        let wakeUpTimeBox: UIView = {
            let box = createTopicBox()
            
            // 기상 시각 레이블과 타임피커를 같은 줄에 위치하도록 함
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.addArrangedSubview(wakeUpTimeLabel)
            stackView.addArrangedSubview(wakeUpTimePicker)
            
            box.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: box.topAnchor, constant: 8),
                stackView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
                stackView.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8)
            ])
            
            wakeUpTimePicker.translatesAutoresizingMaskIntoConstraints = false

            return box
        }()

        contentView.addSubview(wakeUpTimeBox)
        wakeUpTimeBox.snp.makeConstraints { make in
            make.top.equalTo(sleepGoalBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        // 알람 옵션 레이블 설정
        contentView.addSubview(alarmOptionsLabel)
        alarmOptionsLabel.snp.makeConstraints { make in
            make.top.equalTo(wakeUpTimeBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 사운드 옵션 박스 설정
        let soundOptionBox: UIView = {
            let box = createTopicBox()
            box.addSubview(soundOptionButton)
            soundOptionButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                soundOptionButton.centerXAnchor.constraint(equalTo: box.centerXAnchor),
                soundOptionButton.centerYAnchor.constraint(equalTo: box.centerYAnchor)
            ])
            return box
        }()

        contentView.addSubview(soundOptionBox)
        soundOptionBox.snp.makeConstraints { make in
            make.top.equalTo(alarmOptionsLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(100)
        }
        
        // 스크롤뷰의 컨텐츠 크기 설정
        let yourDesiredHeight: CGFloat = soundOptionBox.frame.maxY + 30
        scrollView.contentSize = CGSize(width: view.frame.width, height: yourDesiredHeight)
        
        // 스크롤뷰의 huggingPriority 설정
        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // 선택된 요일을 로드하는 메서드
        loadSelectedDays()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct SleepWakeAlarmSetViewController_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UIViewControllerPreview {
                SleepWakeAlarmSetViewController()
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

@available(iOS 13.0, *)
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        self.viewController = builder()
    }

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요한 경우 처리
    }
}
#endif

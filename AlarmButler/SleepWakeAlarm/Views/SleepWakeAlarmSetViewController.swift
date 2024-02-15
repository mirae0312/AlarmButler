import UIKit
import UserNotifications

protocol SleepWakeAlarmSetViewControllerDelegate: AnyObject {
    func didFinishEditingAlarm(with alarm: SleepWakeAlarmViewModel)
}

class SleepWakeAlarmSetViewController: UIViewController {
    
    weak var delegate: SleepWakeAlarmSetViewControllerDelegate?
    
    private lazy var activeDaysBox: UIView = {
        let box = UIView()
        box.backgroundColor = .systemGray6
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        return box
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let sleepPatternLabel: UILabel = {
        let label = UILabel()
        label.text = "수면 패턴 추가"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    private let activeDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "활성화된 요일"
        return label
    }()
    
    let activeDaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        let dayButtons: [UIButton] = ["월", "화", "수", "목", "금", "토", "일"].map { day in
            let button = UIButton()
            button.setTitle(day, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
            return button
        }
        dayButtons.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private var selectedDays: [String: Bool] = [:]
    
    private let sleepGoalLabel: UILabel = {
        let label = UILabel()
        label.text = "수면 목표"
        return label
    }()
    
    private let sleepGoalPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.locale = Locale(identifier: "en_GB")
        return picker
    }()
    
    private let wakeUpTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "기상 시각"
        return label
    }()
    
    private let wakeUpTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        return picker
    }()
    
    private let alarmOptionsLabel: UILabel = {
        let label = UILabel()
        label.text = "알람 옵션"
        return label
    }()
    
    private let soundOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("사운드 옵션 바로가기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSelectedDays()
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        requestNotificationAuthorization()
    }
    
    private func requestNotificationAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("사용자가 알림 권한을 허용했습니다.")
            } else {
                print("사용자가 알림 권한을 거부했습니다.")
            }
        }
    }
    
    @objc private func soundOptionButtonTapped() {
        let soundOptionVC = AlarmSoundPickerViewController()
        present(soundOptionVC, animated: true, completion: nil)
    }
    
    // 사용자가 선택한 사운드 파일 이름을 저장하는 변수 추가
    var selectedSoundFileName: String?

    // 사운드를 선택한 후 뒤로 버튼을 눌렀을 때 호출되는 메서드
    func didFinishSelectingSound(soundFileName: String) {
        selectedSoundFileName = soundFileName // 선택한 사운드 파일 이름 저장
    }

    // 저장 버튼을 눌렀을 때 호출되는 메서드
    @objc private func saveButtonTapped(_ sender: UIButton) {
        // 알림 콘텐츠 생성
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "알람"
        notificationContent.body = "일어나세요! 지금 기상 시간입니다."
        
        // 사용자가 선택한 사운드 파일 이름으로 사운드 설정
        if let selectedSoundFileName = selectedSoundFileName {
            let soundName = UNNotificationSoundName(rawValue: selectedSoundFileName)
            let notificationSound = UNNotificationSound(named: soundName)
            notificationContent.sound = notificationSound
        } else {
            // 기본 사운드 사용
            notificationContent.sound = .default
        }
        
        // 알림 트리거 설정 및 요청 생성
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTimePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let notificationRequest = UNNotificationRequest(identifier: "WakeUpAlarm", content: notificationContent, trigger: trigger)
        
        // 알림 요청 추가
        notificationCenter.add(notificationRequest) { error in
            if let error = error {
                print("로컬 알림 스케줄링 실패: \(error.localizedDescription)")
            } else {
                print("로컬 알림이 성공적으로 스케줄링되었습니다.")
            }
        }
        
        let createdAlarm = createAlarm()
        delegate?.didFinishEditingAlarm(with: createdAlarm)
        dismiss(animated: true, completion: nil)
        print("Save button tapped!")
    }
    
    private func createAlarm() -> SleepWakeAlarmViewModel {
        let selectedDaysArray = selectedDays.compactMap { $0.key }
        let sleepGoal = Int(sleepGoalPicker.countDownDuration / 60)
        let wakeUpTime = wakeUpTimePicker.date
        return SleepWakeAlarmViewModel(sleepGoals: [sleepGoal], wakeUpTimes: [wakeUpTime], selectedDay: selectedDaysArray.isEmpty ? nil : selectedDaysArray.joined(separator: ","))
    }
    
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
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
        print("Cancel button tapped!")
    }
    
    private func loadSelectedDays() {
        for (day, isSelected) in selectedDays {
            if isSelected {
                if let button = activeDaysStackView.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == day }) {
                    button.setTitleColor(.systemBlue, for: .normal)
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentView: UIView = {
            let view = UIView()
            return view
        }()
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
        
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        contentView.addSubview(sleepPatternLabel)
        sleepPatternLabel.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(activeDaysLabel)
        activeDaysLabel.snp.makeConstraints { make in
            make.top.equalTo(sleepPatternLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(activeDaysBox)
        activeDaysBox.snp.makeConstraints { make in
            make.top.equalTo(activeDaysLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        activeDaysBox.addSubview(activeDaysStackView)
        activeDaysStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        contentView.addSubview(sleepGoalLabel)
        sleepGoalLabel.snp.makeConstraints { make in
            make.top.equalTo(activeDaysBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
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
        
        contentView.addSubview(wakeUpTimeLabel)
        wakeUpTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(sleepGoalBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        let wakeUpTimeBox: UIView = {
            let box = createTopicBox()
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
        
        contentView.addSubview(alarmOptionsLabel)
        alarmOptionsLabel.snp.makeConstraints { make in
            make.top.equalTo(wakeUpTimeBox.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(soundOptionButton)
        soundOptionButton.snp.makeConstraints { make in
            make.top.equalTo(alarmOptionsLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        soundOptionButton.addTarget(self, action: #selector(soundOptionButtonTapped), for: .touchUpInside)
        
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
        
        let yourDesiredHeight: CGFloat = soundOptionBox.frame.maxY + 30
        scrollView.contentSize = CGSize(width: view.frame.width, height: yourDesiredHeight)
        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        loadSelectedDays()
    }
    
    private func createTopicBox() -> UIView {
        let box = UIView()
        box.backgroundColor = .systemGray6
        box.layer.cornerRadius = 8
        box.layer.masksToBounds = true
        box.translatesAutoresizingMaskIntoConstraints = false
        return box
    }
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct SleepWakeAlarmSetViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            UIViewControllerPreview {
//                SleepWakeAlarmSetViewController()
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//}
//
//@available(iOS 13.0, *)
//struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
//    let viewController: ViewController
//
//    init(_ builder: @escaping () -> ViewController) {
//        self.viewController = builder()
//    }
//
//    // MARK: - UIViewControllerRepresentable
//
//    func makeUIViewController(context: Context) -> ViewController {
//        viewController
//    }
//
//    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
//        // 뷰 컨트롤러 업데이트가 필요한 경우 처리
//    }
//}
//#endif

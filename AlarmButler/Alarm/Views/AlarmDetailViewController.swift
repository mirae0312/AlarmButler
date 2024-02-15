//
//  AlarmDetailViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/7/24.
//

import UIKit
import SnapKit
import CoreData

class AlarmDetailViewController: UIViewController {
    // MARK: - UI 컴포넌트 정의
    // 네비게이션 바 관련 UI
    var customNavigationBar: UIView!
    var titleLabel: UILabel!
    var backButton, saveButton, deleteButton: UIButton!
    // 시간 선택 피커
    var timePicker: UIDatePicker!
    // 옵션들을 담을 컨테이너
    var optionsContainer, repeatOptionView, labelOptionView, soundOptionView, snoozeOptionView: UIView!
    // 반복, 사운드의 기본 값
    var repeatOptionValue: String = "안 함"
    var soundOptionValue: String = "거울"
    var optionSwitch: UISwitch!
    // 레이블 값
    var labelTextField: UITextField?
    // ViewModel 인스턴스
    var viewModel: AlarmDetailViewModel!
    // 저장 성공 후 작동할 클로저
    var onSave: (() -> Void)?
    // 알람 고유 id
    var alarmId: NSManagedObjectID?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Setup Methods
    private func configureUI() {
        setupViewBackground()       // 배경색 설정
        setupCustomNavigationBar()  // 네비게이션 바
        setupTimePicker()           // 시간 선택 피커
        setupOptionsContainer()     // 옵션 컨테이너 설정
        updateOptionValues()        // 옵션 뷰에 반복, 사운드 현재 값을 표시하는 메소드
        initializeViewModel()
        if let _ = self.alarmId {
            setupDeleteButton()
            titleLabel.text = "알람 편집"  // 편집 화면의 타이틀 변경
        } else {
            titleLabel.text = "알람 추가"  // 추가 화면의 타이틀 변경
        }
    }
    
    // MARK: - 배경색 설정
    private func setupViewBackground() {
        view.backgroundColor = .white
    }
    
    // MARK: - 알람 저장 액션
    @objc func saveAlarm() {
        guard let viewModel = viewModel else {
            print("ViewModel is nil")
            return
        }

        let textFieldText = labelTextField?.text ?? ""
        let time = timePicker.date // timePicker에서 선택된 시간
        let sound = soundOptionValue // 선택된 사운드 옵션
        let snooze = snoozeOptionView.subviews.compactMap({ $0 as? UISwitch }).first?.isOn ?? true // 다시 알림 스위치 상태
        let repeatDays = repeatOptionValue != "안 함" ? getSelectedDaysFromOptionValue(repeatOptionValue) : Set<String>() // 반복 설정

        viewModel.title = textFieldText
        viewModel.time = time
        viewModel.sound = sound
        viewModel.isEnabled = snooze
        viewModel.repeatDays = repeatDays
        
        viewModel.saveAlarm()
        onSave?() // 저장 성공 후 Closure 호출
        dismissViewController() // 모달 닫기
    }
    
    // ViewModel 초기화 메소드
    private func initializeViewModel() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        if let alarmId = self.alarmId {
            // 기존 알람 편집인 경우
            viewModel = AlarmDetailViewModel(context: context, alarmId: alarmId)
            viewModel.loadAlarmData()
            updateUIWithAlarmDetails() // 데이터 로드 후 UI 업데이트
            updateOptionValues()
        } else {
            // 새 알람 추가인 경우
            viewModel = AlarmDetailViewModel(context: context)
        }
    }
    
    // MARK: - 네비게이션 바 설정
    func setupCustomNavigationBar() {
        // 네비게이션 바 초기화 및 뷰에 추가
        customNavigationBar = UIView()
        customNavigationBar.backgroundColor = .systemGray6
        view.addSubview(customNavigationBar)
        
        // 네비게이션 바 레이아웃 설정
        customNavigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44) // 네비게이션 바 높이
        }
        
        // 타이틀 설정
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        customNavigationBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 뒤로 가기 버튼 설정 및 액션 추가
        backButton = UIButton(type: .system)
        backButton.setTitle("취소", for: .normal)
        backButton.setTitleColor(.orange, for: .normal)
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        customNavigationBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        // 저장 버튼 설정 및 액션 추가
        saveButton = UIButton(type: .system)
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.orange, for: .normal)
        saveButton.addTarget(self, action: #selector(saveAlarm), for: .touchUpInside)
        customNavigationBar.addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    // 뷰 컨트롤러 닫기 액션
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 시간 선택 피커 설정
    func setupTimePicker() {
        // 시간 선택 피커 초기화 및 뷰에 추가
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time // 시간 모드
        timePicker.preferredDatePickerStyle = .wheels // 피커 스타일
        view.addSubview(timePicker)
        
        // 피커 레이아웃 설정
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    // MARK: - 옵션 컨테이너 및 각 옵션 설정
    func setupOptionsContainer() {
        // 옵션 컨테이너 뷰 초기화 및 뷰에 추가
        optionsContainer = UIView()
        optionsContainer.backgroundColor = .systemGray6 // 배경색
        optionsContainer.layer.cornerRadius = 10 // 모서리 둥글기
        optionsContainer.layer.masksToBounds = true // 자식 뷰들이 둥근 모서리를 넘지 않도록
        view.addSubview(optionsContainer)

        // 컨테이너 레이아웃 설정
        optionsContainer.snp.makeConstraints { make in
            make.top.equalTo(timePicker.snp.bottom).offset(20)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        // 각 옵션 뷰 생성 및 추가
        repeatOptionView = createOptionView(title: "반복", isSwitchEnabled: false)
        labelOptionView = createOptionView(title: "레이블", isSwitchEnabled: false)
        soundOptionView = createOptionView(title: "사운드", isSwitchEnabled: false)
        snoozeOptionView = createOptionView(title: "다시 알림", isSwitchEnabled: true)

        // 옵션 뷰들을 컨테이너에 추가
        let optionViews = [repeatOptionView, labelOptionView, soundOptionView, snoozeOptionView]
        for optionView in optionViews {
            optionsContainer.addSubview(optionView!)
        }
        
        // '반복' 옵션 뷰에 탭 제스처 추가
        let repeatTapGesture = UITapGestureRecognizer(target: self, action: #selector(optionViewTapped))
        repeatOptionView.addGestureRecognizer(repeatTapGesture)
        
        // '레이블' 옵션 뷰에 탭 제스처를 추가
        let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(optionViewTapped))
        labelOptionView.addGestureRecognizer(labelTapGesture)
        
        // '사운드' 옵션 뷰에 탭 제스처를 추가
        let soundTapGesture = UITapGestureRecognizer(target: self, action: #selector(optionViewTapped))
        soundOptionView.addGestureRecognizer(soundTapGesture)

        // 옵션 뷰들의 레이아웃 설정
        layoutOptionViews()
    }

    // 옵션 뷰 생성 및 설정
    func createOptionView(title: String, isSwitchEnabled: Bool) -> UIView {
        // 옵션 뷰 초기화 및 설정
        let optionView = UIView()
        optionView.backgroundColor = .clear
        
        // 옵션 타이틀 레이블 설정
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        optionView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        if title == "레이블" {
            let textField = UITextField()
            textField.borderStyle = .none
            textField.returnKeyType = .done
            textField.tintColor = .orange
            textField.textColor = .systemGray
            textField.delegate = self
            textField.alpha = 1
            textField.tag = 104
            textField.clearButtonMode = .whileEditing
            textField.placeholder = "알람"
            self.labelTextField = textField
            optionView.addSubview(textField)
            
            textField.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp.right).offset(10)
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
        } else {
            // 기본값 레이블 설정 (반복, 사운드, 다시 알림)
            let defaultValueLabel = UILabel()
            defaultValueLabel.textColor = .systemGray
            defaultValueLabel.tag = title == "반복" ? 101 : title == "사운드" ? 102 : 103
            optionView.addSubview(defaultValueLabel)
            
            defaultValueLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
            
            if isSwitchEnabled {
                let optionSwitch = UISwitch()
                optionSwitch.isOn = true
                optionView.addSubview(optionSwitch)
                optionSwitch.snp.makeConstraints { make in
                    make.right.equalToSuperview().inset(17)
                    make.centerY.equalToSuperview()
                }
            }
        }
        
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        optionView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return optionView
    }

    // MARK: - 편집 뷰 인 경우 값 업데이트
    func updateUIWithAlarmDetails() {
        labelTextField?.text = viewModel.title
        timePicker.setDate(viewModel.time, animated: false)

        // viewModel에서 로드한 반복 옵션 값을 업데이트
        repeatOptionValue = viewModel.repeatDays.joined(separator: ", ")
        if let repeatLabel = repeatOptionView.viewWithTag(101) as? UILabel {
            repeatLabel.text = "\(repeatOptionValue) ⟩"
        }

        // viewModel에서 로드한 사운드 옵션 값을 업데이트
        soundOptionValue = viewModel.sound
        if let soundLabel = soundOptionView.viewWithTag(102) as? UILabel {
            soundLabel.text = "\(soundOptionValue) ⟩"
        }

        if let snoozeSwitch = snoozeOptionView.subviews.compactMap({ $0 as? UISwitch }).first {
            snoozeSwitch.isOn = viewModel.isEnabled
        }
    }
    
    // 옵션 뷰에 반복, 사운드 현재 값을 표시하는 메소드
    private func updateOptionValues() {
        // '반복' 옵션 뷰에 현재 값을 업데이트
        if let repeatLabel = repeatOptionView.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.tag == 101 }) {
            repeatLabel.text = "\(repeatOptionValue) ⟩"
        }
        
        // '사운드' 옵션 뷰에 현재 값을 업데이트
        if let soundLabel = soundOptionView.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.tag == 102 }) {
            soundLabel.text = "\(soundOptionValue) ⟩"
        }
        
    }

    // 옵션 뷰 탭 시 처리
    @objc func optionViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        
        // 탭한 뷰의 배경색 변경 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            tappedView.backgroundColor = UIColor.systemGray5
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.4, animations: {
                tappedView.backgroundColor = .clear
            }) { _ in
                // '반복' 옵션 뷰가 탭된 경우
                if tappedView == self?.repeatOptionView {
                    self?.repeatOptionViewTapped(sender)
                }
                // '레이블' 옵션 뷰가 탭된 경우
                else if tappedView == self?.labelOptionView {
                    self?.labelOptionViewTapped()
                }
                // '사운드' 옵션 뷰가 탭된 경우
                else if tappedView == self?.soundOptionView {
                    // 애니메이션 후 임시로 repeatOptionViewTapped 메서드 호출
                    self?.soundOptionViewTapped(sender)
                }
            }
        }
    }

    // 옵션 뷰들의 레이아웃 설정
    func layoutOptionViews() {
        let optionViews = [repeatOptionView, labelOptionView, soundOptionView, snoozeOptionView]
        for (index, optionView) in optionViews.enumerated() {
            optionView?.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(44)

                if index == 0 {
                    make.top.equalToSuperview()
                } else {
                    make.top.equalTo(optionViews[index - 1]!.snp.bottom)
                }

                if index == optionViews.count - 1 {
                    make.bottom.equalToSuperview() // 마지막 옵션 뷰는 컨테이너 바닥에 붙임
                }
            }
        }
    }
}

// MARK: - 레이블 UITextField 관련 설정
extension AlarmDetailViewController: UITextFieldDelegate {
    // '레이블' 옵션 뷰 탭 시 호출될 함수
    @objc func labelOptionViewTapped() {
        if let textField = labelOptionView.subviews.first(where: { $0.tag == 104 }) as? UITextField {
            textField.alpha = 1 // 텍스트 필드를 보이게 함
            textField.becomeFirstResponder()
        }
        
        // 기본값 레이블 숨기기
        if let defaultValueLabel = labelOptionView.subviews.first(where: { $0.tag == 103 }) as? UILabel {
            defaultValueLabel.isHidden = true
        }
    }

    // UITextFieldDelegate 메서드 수정
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트 필드가 비어 있지 않은 경우, 기본값 레이블에 텍스트 필드의 값을 설정하고 텍스트 필드 숨김
        if let text = textField.text, !text.isEmpty, textField.tag == 104 {
            if let defaultValueLabel = labelOptionView.subviews.first(where: { $0.tag == 103 }) as? UILabel {
                // 텍스트 필드의 값을 기본값 레이블에 설정
                defaultValueLabel.text = text
                // 폰트 색상 systemGray로 변경
                defaultValueLabel.textColor = .systemGray
                // 기본값 레이블을 표시
                defaultValueLabel.isHidden = false
                // 텍스트 필드 숨김
                textField.alpha = 0
            }
        } else if textField.tag == 104 {
            // 텍스트 필드가 비어 있는 경우, 기본값 레이블을 "알림"으로 설정하고 텍스트 필드 숨김
            if let defaultValueLabel = labelOptionView.subviews.first(where: { $0.tag == 103 }) as? UILabel {
                defaultValueLabel.text = "알림" // 텍스트 필드가 비어 있으면 기본값으로 "알림"을 설정
                defaultValueLabel.textColor = .systemGray2
                defaultValueLabel.isHidden = false
                textField.alpha = 0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // 텍스트 필드의 편집 상태를 종료
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트 필드의 텍스트를 가져옴
        var currentText = textField.text ?? ""
        
        // 범위와 교체 문자열을 사용하여 업데이트된 텍스트를 생성
        if let textRange = Range(range, in: currentText) {
            currentText.replaceSubrange(textRange, with: string)
        }
        
        // 텍스트 필드의 텍스트를 업데이트
        textField.text = currentText
        
        // 커서를 텍스트의 끝으로 이동시킵니다.
        if let newPosition = textField.position(from: textField.endOfDocument, offset: 0) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        // false를 반환하여 시스템이 텍스트 필드의 텍스트를 자동으로 업데이트하지 않도록 합니다.
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textAlignment = textField.text?.isEmpty ?? true ? .right : .left
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // 클리어 버튼이 눌렸을 때 텍스트 정렬을 오른쪽으로 설정
        textField.textAlignment = .right
        
        // 기본 동작을 수행하도록 true를 반환
        return true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - 반복 RepeatOptionsViewController 관련 메서드
extension AlarmDetailViewController {
    @objc func repeatOptionViewTapped(_ sender: UITapGestureRecognizer) {
        let repeatOptionsVC = RepeatOptionsViewController()
                
        // 이미 선택된 옵션들을 RepeatOptionsViewController에 전달
        repeatOptionsVC.selectedOptions = getSelectedDaysFromOptionValue(repeatOptionValue)
        
        // 선택된 옵션을 받아오는 클로저 설정
        repeatOptionsVC.onOptionsSelected = { [weak self] selectedOptions in
            // 여기에서 선택된 옵션을 처리
            self?.handleSelectedRepeatOptions(selectedOptions)
        }

        // 전환 애니메이션 설정 (오른쪽 > 왼쪽으로 이동)
        let transition = CATransition()
        transition.duration = 0.4 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 형태의 전환
        transition.subtype = CATransitionSubtype.fromRight // 오른쪽에서 왼쪽으로 전환
        self.view.window!.layer.add(transition, forKey: kCATransition)

        // 다음 뷰 컨트롤러 모달로 표시
        self.present(repeatOptionsVC, animated: false, completion: nil)
    }
    
    // RepeatOptionsViewController에서 선택한 요일에 따라 문자열을 반환하는 함수
    func getRepeatOptionString(for selectedDays: Set<String>) -> String {
        let allDays = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
        
        if selectedDays.isEmpty {
            return "안 함"
        }

        let orderedSelectedDays = allDays.filter { selectedDays.contains($0) }
        
        switch orderedSelectedDays.count {
        case 7:
            return "매일"
        case 5 where selectedDays.isSuperset(of: allDays[1...5]):
            return "주중"
        case 2 where selectedDays.isSuperset(of: [allDays.first!, allDays.last!]):
            return "주말"
        case 1:
            return orderedSelectedDays.first!.replacingOccurrences(of: "마다", with: "")
        default:
            var dayNames = orderedSelectedDays.map { $0.replacingOccurrences(of: "요일마다", with: "") }
            if dayNames.count > 1 {
                let lastDayName = dayNames.removeLast()
                return "\(dayNames.joined(separator: ", ")) 및 \(lastDayName)"
            } else {
                return dayNames.first ?? ""
            }
        }
    }
    
    // RepeatOptionsViewController로부터 받은 선택된 옵션을 처리하는 메서드
    func handleSelectedRepeatOptions(_ selectedOptions: Set<String>) {
        // 사용자가 선택한 요일에 따라 문자열을 가져옴
        let repeatText = getRepeatOptionString(for: selectedOptions)
        
        // '반복' 옵션 값 업데이트
        self.repeatOptionValue = repeatText
        
        // UI 업데이트
        if let repeatLabel = repeatOptionView.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.tag == 101 }) {
            // '반복' 옵션 라벨에 새로운 값 표시
            repeatLabel.text = "\(repeatOptionValue) ⟩"
        }
    }
    
    // 선택된 반복 옵션 문자열로부터 Set<String>을 추출하는 메서드. RepeatOptionsViewController로 보낼 데이터
    func getSelectedDaysFromOptionValue(_ optionValue: String) -> Set<String> {
        let dayMap = ["일":"일요일마다", "월":"월요일마다", "화":"화요일마다", "수":"수요일마다", "목":"목요일마다", "금":"금요일마다", "토":"토요일마다"]
        
        var selectedDays = Set<String>()
        
        // "매일", "주중", "주말", "안 함"과 같은 특별한 경우를 처리
        switch optionValue {
        case "매일":
            return Set(dayMap.values)
        case "주중":
            return Set(dayMap.values.filter { !$0.contains("토요일") && !$0.contains("일요일") })
        case "주말":
            return Set(dayMap.values.filter { $0.contains("토요일") || $0.contains("일요일") })
        case "안 함":
            return selectedDays
        default:
            break
        }
        
        // 쉼표로 구분된 요일들을 처리
        let components = optionValue.components(separatedBy: ", ")
        for component in components {
            let subcomponents = component.components(separatedBy: " 및 ")
            for subcomponent in subcomponents {
                if let day = dayMap[String(subcomponent.prefix(1))] {
                    selectedDays.insert(day)
                }
            }
        }
        return selectedDays
    }
}

//  MARK: - 사운드 AlarmSoundPickerViewController 관련 메서드
extension AlarmDetailViewController {
    @objc func soundOptionViewTapped(_ sender: UITapGestureRecognizer) {
        let soundOptionsVC = AlarmSoundPickerViewController()

        // 현재 선택된 사운드를 AlarmSoundPickerViewController에 전달
        soundOptionsVC.selectedSoundName = soundOptionValue
        
        // 선택된 사운드 값을 받아서 처리할 클로저 설정
        soundOptionsVC.onSoundSelected = { [weak self] selectedSound in
            // 선택한 사운드 값을 AlarmDetailViewController의 soundOptionValue에 업데이트
            self?.soundOptionValue = selectedSound ?? "거울"
            // UI 업데이트 메서드 호출
            self?.updateOptionValues()
        }

        // 전환 애니메이션 설정 (오른쪽 > 왼쪽으로 이동)
        let transition = CATransition()
        transition.duration = 0.4 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 형태의 전환
        transition.subtype = CATransitionSubtype.fromRight // 오른쪽에서 왼쪽으로 전환
        self.view.window!.layer.add(transition, forKey: kCATransition)

        // 다음 뷰 컨트롤러 모달로 표시
        present(soundOptionsVC, animated: false, completion: nil)
    }
}


// MARK: - 삭제 버튼 설정
extension AlarmDetailViewController {
    private func setupDeleteButton() {
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("알람 삭제", for: .normal)
        deleteButton.backgroundColor = .systemGray6
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(deleteAlarm), for: .touchUpInside)
        
        view.addSubview(deleteButton)
            
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(optionsContainer.snp.bottom).offset(20) // optionsContainer 아래에 배치
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
    }

    @objc func deleteAlarm() {
        guard let alarmId = alarmId else { return }
            viewModel.deleteAlarm(alarmId: alarmId)
//        guard let alarmId = alarmId,
//              let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
//        
//        let alarmToDelete = context.object(with: alarmId)
//        context.delete(alarmToDelete)
//        
//        do {
//            try context.save()
//            // 이전 뷰 컨트롤러에 삭제 완료를 알리는 클로저를 호출.
            onSave?()
            dismissViewController()
//        } catch let error as NSError {
//            print("알람 삭제 에러: \(error), \(error.userInfo)")
//        }
    }
}

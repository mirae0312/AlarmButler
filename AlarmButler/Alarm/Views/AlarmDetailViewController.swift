//
//  AlarmDetailViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/7/24.
//

import UIKit
import SnapKit

class AlarmDetailViewController: UIViewController {
    // MARK: - UI 컴포넌트 정의
    // 네비게이션 바 관련 UI
    var customNavigationBar: UIView!
    var titleLabel: UILabel!
    var backButton, saveButton: UIButton!
    // 시간 선택 피커
    var timePicker: UIDatePicker!
    // 옵션들을 담을 컨테이너
    var optionsContainer, repeatOptionView, labelOptionView, soundOptionView, snoozeOptionView: UIView!
    // 반복, 사운드의 기본 값
    var repeatOptionValue: String = "안 함"
    var soundOptionValue: String = "래디얼"
    // 레이블 값
    var labelTextField: UITextField?

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
    }
    
    // MARK: - 배경색 설정
    private func setupViewBackground() {
        view.backgroundColor = .white
    }
    
    // TODO: 알람 저장 액션 (구현 필요)
    @objc func saveAlarm() {
        // 알람 저장 로직 구현
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
        titleLabel.text = "알람 추가" // 타이틀 텍스트
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        customNavigationBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 뒤로 가기 버튼 설정 및 액션 추가
        backButton = UIButton(type: .system)
        backButton.setTitle("취소", for: .normal)
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        customNavigationBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        // 저장 버튼 설정 및 액션 추가
        saveButton = UIButton(type: .system)
        saveButton.setTitle("저장", for: .normal)
        saveButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
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
        repeatOptionView = createOptionView(title: "반복", isSwitchEnabled: false, hasTextField: false)
        labelOptionView = createOptionView(title: "레이블", isSwitchEnabled: false, hasTextField: true)
        soundOptionView = createOptionView(title: "사운드", isSwitchEnabled: false, hasTextField: false)
        snoozeOptionView = createOptionView(title: "다시 알림", isSwitchEnabled: true, hasTextField: false)

        // 옵션 뷰들을 컨테이너에 추가
        let optionViews = [repeatOptionView, labelOptionView, soundOptionView, snoozeOptionView]
        for optionView in optionViews {
            optionsContainer.addSubview(optionView!)
        }

        // 옵션 뷰들의 레이아웃 설정
        layoutOptionViews()
        
        // RepeatOptionsViewController를 모달로 띄우기 위한 탭 제스처 추가
        setupRepeatOptionViewGesture()
        
        // labelOptionView 텍스트필드 설정
        setupLabelOptionView()
    }

    // 옵션 뷰 생성 및 설정
    func createOptionView(title: String, isSwitchEnabled: Bool, hasTextField: Bool) -> UIView {
        // 옵션 뷰 초기화 및 설정
        let optionView = UIView()
        optionView.backgroundColor = .clear // 배경색 없음
        
        // 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionViewTapped(_:)))
        optionView.addGestureRecognizer(tapGesture)
        optionView.isUserInteractionEnabled = true
        
        // 옵션 타이틀 레이블 설정
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .black
        optionView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        // "반복" 또는 "사운드" 옵션에 대한 기본값 레이블 추가
        if title == "반복" || title == "사운드" {
            let defaultValueLabel = UILabel()
            defaultValueLabel.textColor = .systemGray // 텍스트 색상 설정
            defaultValueLabel.text = title == "반복" ? "\(repeatOptionValue) ⟩" : "\(soundOptionValue) ⟩" // 초기값으로 'repeatOptionValue' 또는 'soundOptionValue' 사용
            defaultValueLabel.tag = title == "반복" ? 101 : 102 // 태그를 설정하여 나중에 찾기 쉽게 함
            optionView.addSubview(defaultValueLabel)
            
            defaultValueLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15) // 오른쪽 여백 설정
                make.centerY.equalToSuperview()
            }
        }
        
        // 스위치 옵션이 필요한 경우 설정
        if isSwitchEnabled {
            let optionSwitch = UISwitch()
            optionSwitch.isOn = true // 디폴트 활성화 상태
            optionView.addSubview(optionSwitch)
            optionSwitch.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(17)
                make.centerY.equalToSuperview()
            }
        }
        
        // 세퍼레이터 설정
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        optionView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return optionView
    }
    
    // MARK: - 옵션 뷰에 반복, 사운드 현재 값을 표시하는 메소드
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
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                tappedView.backgroundColor = .clear
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
// MARK: - UITextField 관련 설정
extension AlarmDetailViewController: UITextFieldDelegate {

    func setupLabelOptionView() {
        labelOptionView.isUserInteractionEnabled = true // 사용자 상호작용 활성화
        optionsContainer.addSubview(labelOptionView)
        
        labelOptionView.snp.makeConstraints { make in
            // labelOptionView의 레이아웃 설정...
        }

        // 텍스트 필드 초기화 및 설정
        labelTextField = UITextField()
        configureTextField(labelTextField)

        labelOptionView.addSubview(labelTextField!)
        labelTextField?.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30) // 'x' 버튼 공간 확보를 위해 오른쪽 여백 증가
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15) // 왼쪽 여백 설정, 텍스트 필드가 레이블 텍스트를 침범하지 않도록 조정
        }

        // UITapGestureRecognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelOptionViewTapped))
        labelOptionView.addGestureRecognizer(tapGesture)
    }

    func configureTextField(_ textField: UITextField?) {
        textField?.borderStyle = .none
        textField?.textAlignment = .right
        textField?.tintColor = .orange
        textField?.clearButtonMode = .whileEditing
        textField?.returnKeyType = .done
        textField?.delegate = self
        textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc func labelOptionViewTapped(_ sender: UITapGestureRecognizer) {
        labelTextField?.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 텍스트 필드 편집 시작 시 필요한 동작 구현
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 텍스트 필드 편집 종료 시 필요한 동작 구현
        textField.snp.updateConstraints { make in
            make.right.equalToSuperview().inset(10) // 'x' 버튼이 사라진 후 오른쪽 여백 조정
        }
        if textField.text?.isEmpty ?? true {
            // 텍스트가 없을 경우 커서 사라짐 처리
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // 텍스트 필드의 내용이 변경될 때 호출되는 메소드
        if textField.text?.isEmpty ?? true {
            // 텍스트가 없는 경우 처리
            textField.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(30) // 'x' 버튼 공간 확보를 위해 오른쪽 여백 증가
            }
        } else {
            // 텍스트가 있는 경우 처리
            textField.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(10) // 'x' 버튼이 사라진 후 오른쪽 여백 조정
            }
        }
    }
}

// MARK: - RepeatOptionsViewController를 모달로 표시하는 메서드
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
    
    // 선택한 요일에 따라 문자열을 반환하는 함수
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
    

    // RepeatOptionsViewController를 모달로 띄우기 위한 탭 제스처 추가
    func setupRepeatOptionViewGesture() {
        // repeatOptionView는 사용자가 탭할 수 있는 뷰
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(repeatOptionViewTapped(_:)))
        repeatOptionView.addGestureRecognizer(tapGesture)
        repeatOptionView.isUserInteractionEnabled = true
    }
}

extension AlarmDetailViewController {
    // 선택된 반복 옵션 문자열로부터 Set<String>을 추출하는 메서드.
    func getSelectedDaysFromOptionValue(_ optionValue: String) -> Set<String> {
        let dayMap = ["일": "일요일마다", "월": "월요일마다", "화": "화요일마다", "수": "수요일마다", "목": "목요일마다", "금": "금요일마다", "토": "토요일마다"]
        
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


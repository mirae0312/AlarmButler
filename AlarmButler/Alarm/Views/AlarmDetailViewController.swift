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
    var backButton: UIButton!
    var saveButton: UIButton!
    // 시간 선택 피커
    var timePicker: UIDatePicker!
    // 옵션들을 담을 컨테이너
    var optionsContainer: UIView!
    var repeatOptionView: UIView!
    var labelOptionView: UIView!
    var soundOptionView: UIView!
    var snoozeOptionView: UIView!
    // 레이블 옵션을 위한 텍스트 필드 및 알람 레이블
    var labelTextField: UITextField?
    var alarmLabel: UILabel?
    // 반복, 사운드의 기본 값
    var repeatOptionValue: String = "안 함"
    var soundOptionValue: String = "래디얼"

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // UI Setup Methods
    private func configureUI() {
        // 배경색 설정
        view.backgroundColor = .white
        
        // 네비게이션 바, 시간 선택 피커, 옵션 컨테이너 설정
        setupCustomNavigationBar()
        setupTimePicker()
        setupOptionsContainer()
        updateOptionValues()
    }
    
    // 네비게이션 바 설정
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
    
    // 시간 선택 피커 설정
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
    
    // TODO: 알람 저장 액션 (구현 필요)
    @objc func saveAlarm() {
        // 알람 저장 로직 구현
    }
    
    // 옵션 컨테이너 및 각 옵션 설정
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
        
        // 텍스트 필드가 필요한 경우 설정
        if hasTextField {
            labelTextField = UITextField()
            labelTextField?.borderStyle = .none
            labelTextField?.font = UIFont.systemFont(ofSize: 16)
            labelTextField?.tintColor = .orange // 커서 색상
            labelTextField?.returnKeyType = .done
            labelTextField?.clearButtonMode = .whileEditing
            labelTextField?.delegate = self

            optionView.addSubview(labelTextField!)
            labelTextField?.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalToSuperview()
            }
            
            // 알람 레이블 설정
            alarmLabel = UILabel()
            alarmLabel?.text = "알람"
            alarmLabel?.textColor = .lightGray
            optionView.addSubview(alarmLabel!)
            alarmLabel?.snp.makeConstraints { make in
                make.right.equalTo(labelTextField!.snp.left).offset(3)
                make.centerY.equalTo(labelTextField!.snp.centerY)
            }
            
            // 텍스트 변경 감지
            labelTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        
        // 스위치 옵션이 필요한 경우 설정
        if isSwitchEnabled {
            let optionSwitch = UISwitch()
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

    // 텍스트 필드 변경 감지 및 처리
    @objc func textFieldDidChange(_ textField: UITextField) {
        // 텍스트 필드의 내용에 따라 알람 레이블 가시성 및 정렬 조정
        alarmLabel?.isHidden = !(textField.text?.isEmpty ?? true)
        textField.textAlignment = textField.text?.isEmpty ?? true ? .right : .left
        
        // 텍스트 필드가 비어있으면 알람 레이블을 오른쪽으로 이동
        alarmLabel?.snp.remakeConstraints { make in
            if textField.text?.isEmpty ?? true {
                make.right.equalTo(labelOptionView.snp.right).offset(-15)
            } else {
                make.right.equalTo(textField.snp.left).offset(-2)
            }
            make.centerY.equalToSuperview()
        }
        
        // 레이아웃 즉시 업데이트
        self.view.layoutIfNeeded()
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
        
        // 레이블 옵션 뷰를 탭한 경우 텍스트 필드에 포커스
        if tappedView === labelOptionView {
            labelTextField?.becomeFirstResponder()
        } else {
            labelTextField?.resignFirstResponder()
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

// UITextFieldDelegate 프로토콜 구현
extension AlarmDetailViewController: UITextFieldDelegate {
    // 리턴 키를 누르면 키보드 숨기기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// RepeatOptionsViewController를 모달로 표시하는 메서드.
extension AlarmDetailViewController {
    @objc func repeatOptionViewTapped(_ sender: UITapGestureRecognizer) {
        let repeatOptionsVC = RepeatOptionsViewController()
        
        // 화면을 전체적으로 채우도록 모달 프레젠테이션 스타일을 설정
        //repeatOptionsVC.modalPresentationStyle = .fullScreen

        // 전환 애니메이션 설정 (오른쪽 > 왼쪽으로 이동)
        let transition = CATransition()
        transition.duration = 0.3 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 형태의 전환
        transition.subtype = CATransitionSubtype.fromRight // 오른쪽에서 왼쪽으로 전환
        self.view.window!.layer.add(transition, forKey: kCATransition)

        // 다음 뷰 컨트롤러 모달로 표시
        self.present(repeatOptionsVC, animated: false, completion: nil)
    }
    
    // RepeatOptionsViewController를 모달로 띄우기 위한 탭 제스처 추가
    func setupRepeatOptionViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(repeatOptionViewTapped(_:)))
        repeatOptionView.addGestureRecognizer(tapGesture)
        repeatOptionView.isUserInteractionEnabled = true
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
struct ViewControllerPreview2: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AlarmDetailViewController {
        return AlarmDetailViewController()
    }
    
    func updateUIViewController(_ uiViewController: AlarmDetailViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요할 때 사용
    }
}

// SwiftUI Preview
@available(iOS 13.0, *)
struct ViewControllerPreview_Preview2: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview2()
            .edgesIgnoringSafeArea(.all) // Safe Area를 무시하고 전체 화면으로 표시하고 싶은 경우
    }
}
#endif

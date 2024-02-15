//
//  AlarmSoundPickerViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/7/24.
//

import Foundation
import UIKit
import AVFoundation

class AlarmSoundPickerViewController: UIViewController {
    // MARK: - Properties
    // 커스텀 네비게이션 바
    let customNavigationBar = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton(type: .system)
    // 사용자가 선택할 수 있는 사운드 목록
    var options: [String] = []
    // 현재 선택된 사운드 이름
    var selectedSoundName: String?
    // 사운드 재생을 위한 오디오 플레이어
    var audioPlayer: AVAudioPlayer?
    // 옵션 뷰를 담고 있는 컨테이너 뷰
    private var optionsContainer: UIView!
    // 각 사운드 옵션에 대한 뷰 목록
    private var optionViews: [SoundOptionView] = []
    
    // MARK: - 사운드 선택 값을 전달해주는 클로저
    var onSoundSelected: ((String?) -> Void)?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Setup Methods
    private func configureUI() {
        setupViewBackground()           // 배경색 설정
        setupCustomNavigationBar()      // 커스텀 네비게이션 바 설정
        loadSoundOptions()              // 사용 가능한 사운드 옵션 로드
        setupOptionsContainer()         // 사운드 옵션을 담을 컨테이너 설정
        updateSelectedSound()           // 선택된 사운드 업데이트
    }
    
    // MARK: - 배경색 설정
    private func setupViewBackground() {
        view.backgroundColor = .white
    }
    
    // MARK: - Setup Methods
    // 커스텀 네비게이션 바 설정
    private func setupCustomNavigationBar() {
        // 네비게이션 바 컨테이너 뷰 생성
        view.addSubview(customNavigationBar)
        customNavigationBar.backgroundColor = .systemGray6
        
        // 네비게이션 바 레이아웃 설정
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view)
            make.height.equalTo(44) // 표준 네비게이션 바 높이 설정
        }
        
        // 타이틀 레이블 생성 및 설정
        titleLabel.text = "사운드"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        customNavigationBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 뒤로가기 버튼 생성 및 설정
        backButton.setTitle("❮ 뒤로", for: .normal) // 여기에 적절한 텍스트 입력
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavigationBar.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
    }
    
    // 뒤로가기 버튼 탭 시 호출되는 메소드
    @objc private func backButtonTapped() {
        // 화면 전환 애니메이션 설정
        let transition = CATransition()
        transition.duration = 0.4 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 형태의 전환
        transition.subtype = CATransitionSubtype.fromLeft // 왼쪽에서 오른쪽으로 전환
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        // 선택된 사운드 이름을 클로저를 통해 AlarmDetailViewController로 전달
        onSoundSelected?(selectedSoundName)
        
        // 현재 뷰 컨트롤러를 dismiss
        self.dismiss(animated: false, completion: nil)
    }
    
    // 사용 가능한 사운드 옵션을 로드
    private func loadSoundOptions() {
        // 1. 앱 번들의 기본 리소스 URL을 가져옴
        guard let resourceURL = Bundle.main.resourceURL else {
            print("Unable to find the bundle resource URL.")
            return
        }

        let fileManager = FileManager.default
        do {
            // 2. 해당 URL에 있는 모든 파일과 디렉토리의 목록을 가져옴
            let resourceContents = try fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
            // 3. 지원하는 파일 확장자 목록을 정의 (mp3와 wav만 사용)
            let supportedExtensions = ["mp3", "wav"]
            // 4. 가져온 파일 목록에서 지원하는 확장자를 가진 파일만 필터링하여 options 배열에 저장 (거울.mp3로 저장)
            options = resourceContents.compactMap { url in
                let fileExtension = url.pathExtension
                if supportedExtensions.contains(fileExtension) {
                    // 지원하는 확장자를 가진 파일의 이름을 options 배열에 추가
                    return url.lastPathComponent
                } else {
                    // 지원하지 않는 확장자를 가진 파일은 무시
                    return nil
                }
            }
            
        } catch {
            print("Error while enumerating files in \(resourceURL): \(error.localizedDescription)")
        }
    }
    
    // 사운드 옵션 뷰를 생성
    func setupOptionsContainer() {
        optionsContainer = UIView()
        optionsContainer.backgroundColor = .systemGray6
        optionsContainer.layer.cornerRadius = 10
        optionsContainer.layer.masksToBounds = true
        view.addSubview(optionsContainer)
        
        optionsContainer.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(20)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        var lastOptionView: UIView?
        for option in options {
            let optionView = createOptionView(title: option)
            optionViews.append(optionView) // 옵션 뷰 배열에 추가
            optionsContainer.addSubview(optionView)
            
            optionView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let lastOptionView = lastOptionView {
                    make.top.equalTo(lastOptionView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.height.equalTo(50)
            }
            lastOptionView = optionView
        }
        
        // 마지막 OptionView가 optionsContainer의 바닥에 붙도록 설정
        lastOptionView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    // 옵션 뷰 생성 및 설정
    // UI에 파일 이름을 표시할 때는 확장자를 제외한 이름을 사용
    private func createOptionView(title: String) -> SoundOptionView {
        let optionView = SoundOptionView()
        // displayName은 확장자를 제거한 화면에 보여주기 위한 'base name'을 표시 
        // 실제 파일 이름은 (거울.mp3 -> 거울)
        let displayName = title.components(separatedBy: ".").first ?? title
        optionView.title = displayName
        optionView.isSelected = (displayName == selectedSoundName)
        optionView.onSelect = { [weak self] selected in
            self?.selectedSoundName = selected ? displayName : nil
            self?.updateOptionViews()
            if selected {
                // 여기서는 확장자가 포함된 전체 파일명을 재생 함수에 전달
                self?.playSound(named: title)
            }
        }
        return optionView
    }
    
    // 옵션 뷰의 선택 상태를 업데이트
    private func updateOptionViews() {
        for optionView in optionViews {
            // 확장자를 제거한 'base name'을 비교
            let displayName = optionView.title?.components(separatedBy: ".").first ?? ""
            optionView.isSelected = (displayName == selectedSoundName)
        }
    }
    
    // 선택된 사운드를 재생
    private func playSound(named soundName: String) {
        // 1. 파일 이름에서 확장자를 분리 (거울.mp3 -> 거울)
        let components = soundName.components(separatedBy: ".")
        // 파일 이름이 올바른 형식인지 확인(이름과 확장자가 모두 있어야 함)
        guard components.count == 2, let fileName = components.first, let fileExtension = components.last else {
            print("Invalid sound file name: \(soundName)")
            return
        }
        
        // 2. 주어진 파일 이름과 확장자를 사용하여 번들 내의 리소스 URL을 탐색
        // Bundle.main.url(forResource: fileName, withExtension: fileExtension)을 사용해 확장자를 명시적으로 분리하여 사용함으로써, 올바른 파일을 정확히 로드하고 재생
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Unable to find the sound file: \(soundName)")
            return
        }
        
        // 3. 사운드 파일로부터 오디오 플레이어를 생성하고 재생을 시도
        do {
            // 이미 재생 중인 사운드가 있으면 정지
            audioPlayer?.stop()
            // 새 오디오 플레이어 인스턴스를 생성
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            // 오디오 플레이어를 준비 상태로 만듬
            audioPlayer?.prepareToPlay()
            // 사운드 재생
            audioPlayer?.play()
        } catch {
            print("Failed to play the sound file: \(error)")
        }
    }
    
    // 선택된 사운드에 따라 UI를 업데이트하는 메서드
    private func updateSelectedSound() {
        // optionViews를 업데이트하여 선택된 사운드에 체크 표시
        for optionView in optionViews {
            optionView.isSelected = (optionView.title == selectedSoundName)
        }
    }
    
    // 사운드 옵션 뷰를 탭할 때 호출되는 메서드
    @objc func soundOptionViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? SoundOptionView, let tappedSoundName = tappedView.title else { return }
        
        // 선택된 사운드가 다시 탭되면 사운드만 재생
        if tappedSoundName == selectedSoundName {
            playSound(named: tappedSoundName)
            return
        }
        
        // 새 선택에 대해 선택을 업데이트하고 사운드를 재생
        for optionView in optionViews {
            if optionView.title == tappedSoundName {
                // 새 사운드를 선택하고 재생
                optionView.isSelected = true
                selectedSoundName = tappedSoundName
                playSound(named: tappedSoundName)
            } else {
                // 다른 옵션의 선택을 해제
                optionView.isSelected = false
            }
        }
    }

}

// MARK: - SoundOptionView
class SoundOptionView: UIView {
    // 사운드 옵션의 제목
    var title: String? {
        didSet { titleLabel.text = title }
    }
    // 옵션이 선택되었는지 여부
    var isSelected: Bool = false {
        didSet {
            // 체크박스 이미지 뷰 상태 업데이트
            checkmarkImageView.isHidden = !isSelected // 체크마크 표시 업데이트
        }
    }
    
    // 선택 콜백
    var onSelect: ((Bool) -> Void)?
    
    // UI Components
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupTapGesture()
    }
    
    // MARK: - Setup Methods
    // 뷰 구성 요소를 설정
    private func setupViews() {
        backgroundColor = .systemGray6 // 디자인에 맞는 색으로 설정
        titleLabel.font = UIFont.systemFont(ofSize: 16) // 글꼴 크기 필요에 따라 설정
        addSubview(titleLabel)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark") // 체크마크 이미지 사용
        checkmarkImageView.tintColor = .orange // 틴트 색상 필요에 따라 설정
        checkmarkImageView.isHidden = !isSelected
        addSubview(checkmarkImageView)
        
        // 세퍼레이터 설정
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20) // 왼쪽 여백 필요에 따라 조절
            make.centerY.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20) // 오른쪽 여백 필요에 따라 조절
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20)) // 크기 필요에 따라 조절
        }
    }
    
    // 탭 제스처를 설정
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    // 탭 제스처에 응답하여 선택 상태를 토글
    @objc private func didTapView() {
        // 선택 상태를 토글하지 않고 선택 콜백을 트리거
        onSelect?(true) // 항상 true를 전달하여 선택 상태를 유지
        
        // 옵션 배경색 변경 애니메이션 적용
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundColor = UIColor.systemGray5 // 배경색 변경 애니메이션
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = .systemGray6 // 원래 배경색으로 복귀하는 애니메이션
            }
        }
    }
}

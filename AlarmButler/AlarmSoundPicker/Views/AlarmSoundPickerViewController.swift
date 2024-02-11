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
    
    var options: [String] = []
    // 선택된 사운드 이름
    var selectedSoundName: String?
    
    // 사운드 재생을 위한 오디오 플레이어
    var audioPlayer: AVAudioPlayer?
    
    // UI Components
    private var optionsContainer: UIView!
    private var optionViews: [SoundOptionView] = []
    
    // 반복 선택 값을 전달해주는 클로저
    var onOptionsSelected: ((Set<String>) -> Void)?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Setup Methods
    private func configureUI() {
        // 배경색 설정
        view.backgroundColor = .white
        
        loadSoundOptions()
        setupCustomNavigationBar()
        setupOptionsContainer()
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
        
        // closure를 사용하여 선택된 옵션을 전달
        
        // 현재 뷰 컨트롤러를 dismiss
        self.dismiss(animated: false, completion: nil)
    }
    
    private func loadSoundOptions() {
        guard let resourceURL = Bundle.main.resourceURL else {
            print("Unable to find the bundle resource URL.")
            return
        }

        let fileManager = FileManager.default
        do {
            let resourceContents = try fileManager.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil, options: [])
            let supportedExtensions = ["mp3", "wav"]
            options = resourceContents.compactMap { url in
                let fileExtension = url.pathExtension
                if supportedExtensions.contains(fileExtension) {
                    return url.lastPathComponent
                } else {
                    return nil
                }
            }
            
            print("Loaded sound options: \(options)")
        } catch {
            print("Error while enumerating files in \(resourceURL): \(error.localizedDescription)")
        }
    }
    
    // 옵션 컨테이너 설정
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
        // 확장자를 제거한 'base name'을 표시
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
    
    private func updateOptionViews() {
        for optionView in optionViews {
            // 확장자를 제거한 'base name'을 비교
            let displayName = optionView.title?.components(separatedBy: ".").first ?? ""
            optionView.isSelected = (displayName == selectedSoundName)
        }
    }
    
    private func playSound(named soundName: String) {
        let components = soundName.components(separatedBy: ".")
        guard components.count == 2, let fileName = components.first, let fileExtension = components.last else {
            print("Invalid sound file name: \(soundName)")
            return
        }
        
        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Unable to find the sound file: \(soundName)")
            return
        }
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play the sound file: \(error)")
        }
    }
}


// MARK: - SoundOptionView
class SoundOptionView: UIView {
    // Properties
    var title: String? {
        didSet { titleLabel.text = title }
    }
    
    var isSelected: Bool = false {
        didSet {
            // 체크박스 이미지 뷰 상태 업데이트
            checkmarkImageView.isHidden = !isSelected
        }
    }
    
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func didTapView() {
        isSelected.toggle()
        onSelect?(isSelected)
        
        // 옵션 배경색 변경 애니메이션 적용
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundColor = UIColor.systemGray5
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = .systemGray6
            }
        }
    }
}

extension URL {
    // 파일이 오디오 파일인지 확인하는 확장.
    var isPlayableAudio: Bool {
        let playableExtensions = ["m4a", "mp3", "wav", "aiff"]
        return playableExtensions.contains(self.pathExtension)
    }
}

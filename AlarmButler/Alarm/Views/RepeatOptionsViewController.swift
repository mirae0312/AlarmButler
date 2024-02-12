//
//  RepeatOptionsViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/9/24.
//

import UIKit
import SnapKit

class RepeatOptionsViewController: UIViewController {
    // MARK: - Properties
    // 커스텀 네비게이션 바
    let customNavigationBar = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton(type: .system)
    
    // 반복 옵션과 선택된 옵션을 담을 배열 및 집합
    var options: [String] = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    var selectedOptions: Set<String> = []
    
    // UI Components
    private var optionsContainer: UIView!
    private var optionViews: [RepeatOptionView] = []
    
    // 반복 선택 값을 전달해주는 클로저
    var onOptionsSelected: ((Set<String>) -> Void)?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Setup Methods
    private func configureUI() {
        setupViewBackground()       // 배경색 설정
        setupCustomNavigationBar()  // 커스텀 네비게이션 바 설정
        setupOptionsContainer()     // 옵션 컨테이너 설정
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 안전 영역 상단에 위치
            make.left.right.equalTo(view) // 뷰의 좌우에 맞춤
            make.height.equalTo(44) // 표준 네비게이션 바 높이 설정
        }
        
        // 타이틀 레이블 생성 및 설정
        titleLabel.text = "반복" // 제목 설정
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17) // 폰트 및 크기 설정
        titleLabel.textAlignment = .center // 텍스트 정렬 설정
        customNavigationBar.addSubview(titleLabel) // 네비게이션 바에 제목 레이블 추가
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview() // 네비게이션 바 중앙에 위치
        }
        
        // 뒤로가기 버튼 생성 및 설정
        backButton.setTitle("❮ 뒤로", for: .normal) // 버튼 타이틀 설정
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside) // 버튼 액션 설정
        customNavigationBar.addSubview(backButton) // 네비게이션 바에 뒤로가기 버튼 추가
        
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10) // 왼쪽 여백 설정
            make.centerY.equalToSuperview() // 네비게이션 바의 세로 중앙에 위치
            make.width.equalTo(60) // 버튼 너비 설정
        }
    }
    
    // 뒤로가기 버튼 탭 시 호출되는 메서드
    @objc private func backButtonTapped() {
        let transition = CATransition()
        transition.duration = 0.4 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 애니메이션 타입 설정
        transition.subtype = CATransitionSubtype.fromLeft // 왼쪽에서 오른쪽으로 이동하는 서브타입 설정
        self.view.window!.layer.add(transition, forKey: kCATransition) // 애니메이션 적용
        
        onOptionsSelected?(selectedOptions) // 선택된 옵션을 클로저를 통해 전달
        self.dismiss(animated: false, completion: nil) // 뷰 컨트롤러 닫기
    }
    
    
    // 옵션 컨테이너 설정 메서드
    func setupOptionsContainer() {
        optionsContainer = UIView()
        optionsContainer.backgroundColor = .systemGray6 // 배경색 설정
        optionsContainer.layer.cornerRadius = 10 // 모서리 둥글기
        optionsContainer.layer.masksToBounds = true // 자식 뷰가 모서리를 넘지 않도록 설정
        view.addSubview(optionsContainer) // 뷰에 옵션 컨테이너 추가
        
        optionsContainer.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(20) // 네비게이션 바 아래에 위치
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(20) // 좌우 여백 설정
        }
        
        var lastOptionView: UIView? // 마지막으로 추가된 옵션 뷰를 추적하기 위한 변수
        for option in options { // 모든 옵션에 대해 반복
            let optionView = createOptionView(title: option) // 옵션 뷰 생성
            optionView.isSelected = selectedOptions.contains(option) // 선택된 옵션인지 확인하여 상태 설정
            optionsContainer.addSubview(optionView) // 옵션 컨테이너에 옵션 뷰 추가
            
            optionView.snp.makeConstraints { make in
                make.left.right.equalToSuperview() // 옵션 컨테이너의 좌우에 맞춤
                if let lastOptionView = lastOptionView { // 이전 옵션 뷰가 있으면
                    make.top.equalTo(lastOptionView.snp.bottom) // 이전 옵션 뷰 아래에 위치
                } else {
                    make.top.equalToSuperview() // 첫 번째 옵션 뷰는 컨테이너의 상단에 위치
                }
                make.height.equalTo(50) // 옵션 뷰의 높이 설정
            }
            lastOptionView = optionView // 마지막 옵션 뷰 업데이트
        }
        
        // 마지막 옵션 뷰가 컨테이너의 바닥에 붙도록 설정
        lastOptionView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
    
    // 옵션 뷰 생성 및 설정 메서드
    func createOptionView(title: String) -> RepeatOptionView {
        let optionView = RepeatOptionView() // 옵션 뷰 인스턴스 생성
        optionView.title = title // 옵션 뷰 제목 설정
        optionView.onSelect = { [weak self] selected in // 옵션 선택 콜백 설정
            if selected { // 옵션이 선택된 경우
                self?.selectedOptions.insert(title) // 선택된 옵션 집합에 추가
            } else { // 옵션이 선택 해제된 경우
                self?.selectedOptions.remove(title) // 선택된 옵션 집합에서 제거
            }
        }
        
        optionView.isSelected = selectedOptions.contains(title) // 옵션 뷰의 선택 상태 설정
        return optionView // 생성된 옵션 뷰 반환
    }
}


// MARK: - RepeatOptionView
class RepeatOptionView: UIView {
    var title: String? { // 옵션 제목
        didSet { titleLabel.text = title } // 제목이 설정되면 레이블에 표시
    }
    
    var isSelected: Bool = false { // 옵션 선택 상태
        didSet { // 선택 상태가 변경될 때
            checkmarkImageView.isHidden = !isSelected // 선택 상태에 따라 체크마크 이미지 뷰의 표시 여부 결정
        }
    }
    
    var onSelect: ((Bool) -> Void)? // 옵션 선택 콜백
    
    // UI Components
    private let titleLabel = UILabel() // 옵션 제목 레이블
    private let checkmarkImageView = UIImageView() // 체크마크 이미지 뷰
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews() // 뷰 설정 메서드 호출
        setupTapGesture() // 탭 제스처 설정 메서드 호출
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews() // 뷰 설정 메서드 호출
        setupTapGesture() // 탭 제스처 설정 메서드 호출
    }
    
    // 뷰 설정 메서드
    private func setupViews() {
        backgroundColor = .systemGray6 // 배경색 설정
        titleLabel.font = UIFont.systemFont(ofSize: 16) // 제목 레이블 폰트 설정
        addSubview(titleLabel) // 제목 레이블 추가
        
        checkmarkImageView.image = UIImage(systemName: "checkmark") // 체크마크 이미지 설정
        checkmarkImageView.tintColor = .orange // 체크마크 이미지 색상 설정
        checkmarkImageView.isHidden = !isSelected // 선택 상태에 따라 체크마크 이미지 뷰 표시 여부 결정
        addSubview(checkmarkImageView) // 체크마크 이미지 뷰 추가
        
        // 세퍼레이터 설정
        let separator = UIView()
        separator.backgroundColor = .systemGray5 // 세퍼레이터 색상 설정
        addSubview(separator) // 세퍼레이터 추가
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview() // 세퍼레이터 위치 설정
            make.height.equalTo(1) // 세퍼레이터 높이 설정
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20) // 제목 레이블 왼쪽 여백 설정
            make.centerY.equalToSuperview() // 제목 레이블 세로 중앙 정렬
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20) // 체크마크 이미지 뷰 오른쪽 여백 설정
            make.centerY.equalToSuperview() // 체크마크 이미지 뷰 세로 중앙 정렬
            make.size.equalTo(CGSize(width: 20, height: 20)) // 체크마크 이미지 뷰 크기 설정
        }
    }
    
    // 탭 제스처 설정 메서드
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView)) // 탭 제스처 인식기 생성 및 액션 설정
        addGestureRecognizer(tapGesture) // 뷰에 탭 제스처 인식기 추가
    }
    
    // 탭 제스처 액션 메서드
    @objc private func didTapView() {
        isSelected.toggle() // 선택 상태 토글
        onSelect?(isSelected) // 선택 콜백 호출
        
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

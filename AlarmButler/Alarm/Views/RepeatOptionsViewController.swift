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
    let customNavigationBar = UIView()
    let titleLabel = UILabel()
    let backButton = UIButton(type: .system)
    var options: [String] = ["일요일마다", "월요일마다", "화요일마다", "수요일마다", "목요일마다", "금요일마다", "토요일마다"]
    var selectedOptions: Set<String> = []

    // MARK: - UI Components
    private var optionViews: [OptionView] = []

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // 배경색 설정

        setupCustomNavigationBar()
        setupOptionViews()
    }

    // MARK: - Setup Methods
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
        titleLabel.text = "반복" // 여기에 적절한 타이틀 입력
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

    @objc private func backButtonTapped() {
        // 화면 전환 애니메이션 설정
        let transition = CATransition()
        transition.duration = 0.3 // 애니메이션 지속 시간 설정
        transition.type = CATransitionType.push // 푸시 형태의 전환
        transition.subtype = CATransitionSubtype.fromLeft // 왼쪽에서 오른쪽으로 전환
        self.view.window!.layer.add(transition, forKey: kCATransition)

        // 현재 뷰 컨트롤러를 dismiss
        self.dismiss(animated: false, completion: nil)
    }

    private func setupOptionViews() {
        for option in options {
            let optionView = OptionView()
            optionView.title = option
            optionView.isSelected = selectedOptions.contains(option)
            optionView.onSelect = { [weak self] selected in
                if selected {
                    self?.selectedOptions.insert(option)
                } else {
                    self?.selectedOptions.remove(option)
                }
            }
            optionViews.append(optionView)
            view.addSubview(optionView)

            optionView.snp.makeConstraints { make in
                // Your constraints here
            }
        }
    }
}

// MARK: - OptionView
class OptionView: UIView {
    // MARK: - Properties
    var title: String? {
        didSet { titleLabel.text = title }
    }

    var isSelected: Bool = false {
        didSet { checkmarkImageView.isHidden = !isSelected }
    }

    var onSelect: ((Bool) -> Void)?

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    // MARK: - Initializer
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
        titleLabel.textColor = .white
        addSubview(titleLabel)
        
        checkmarkImageView.image = UIImage(systemName: "checkmark") // Use your checkmark image
        checkmarkImageView.isHidden = !isSelected
        addSubview(checkmarkImageView)

        // Setup your constraints for titleLabel and checkmarkImageView
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @objc private func didTapView() {
        isSelected.toggle()
        onSelect?(isSelected)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
struct ViewControllerPreview3: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RepeatOptionsViewController {
        return RepeatOptionsViewController()
    }
    
    func updateUIViewController(_ uiViewController: RepeatOptionsViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요할 때 사용
    }
}

// SwiftUI Preview
@available(iOS 13.0, *)
struct ViewControllerPreview_Preview3: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview3()
            .edgesIgnoringSafeArea(.all) // Safe Area를 무시하고 전체 화면으로 표시하고 싶은 경우
    }
}
#endif

//
//  AlarmListViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit
import SnapKit

class AlarmListViewController: UIViewController {
    var customNavigationBar: UIView!
    var titleLabel: UILabel!
    var editButton: UIButton!
    var addButton: UIButton!
    var tableView: UITableView!
    var viewModel = AlarmListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomNavigationBar()
        viewModel.fetchAlarms() // 알람 데이터 불러오기
        setupTableView()
    }

    // 네비게이션 바 설정
    func setupCustomNavigationBar() {
        customNavigationBar = UIView()
        customNavigationBar.backgroundColor = .systemGray6
        view.addSubview(customNavigationBar)
        
        // Auto Layout 설정
        customNavigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44) // 네비게이션 바 표준 높이
        }
        
        // 타이틀 레이블 설정
        titleLabel = UILabel()
        titleLabel.text = "알람"
        customNavigationBar.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 편집 버튼 설정
        editButton = UIButton(type: .system)
        editButton.setTitle("편집", for: .normal)
        editButton.addTarget(self, action: #selector(toggleEditing), for: .touchUpInside)
        customNavigationBar.addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        // 추가 버튼 설정
        addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.addTarget(self, action: #selector(addAlarm), for: .touchUpInside)
        customNavigationBar.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }

    // 새 알람 추가 액션
    @objc private func addAlarm() {
        let detailVC = AlarmDetailViewController()
        
        // 부모 뷰 컨트롤러의 컨텍스트 내에서 모달로 표시되도록 설정합니다.
        definesPresentationContext = true
        
        // 모달로 표시될 뷰 컨트롤러의 modalPresentationStyle을 automatic으로 설정합니다.
        detailVC.modalPresentationStyle = .automatic
        
        // AlarmDetailViewController를 모달로 표시.
        present(detailVC, animated: true, completion: nil)
    }

    // 편집 모드 전환 액션
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true) // 편집 모드 전환
        // 편집 버튼의 타이틀을 편집 모드에 따라 변경.
        let buttonTitle = tableView.isEditing ? "완료" : "편집"
        editButton.setTitle(buttonTitle, for: .normal)
    }

    // 테이블뷰 설정과 SnapKit을 사용한 레이아웃 정의
    private func setupTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AlarmCell")
        tableView.backgroundColor = UIColor.lightGray

        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom) // 커스텀 네비게이션 바의 하단에 맞춤
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide) // 뷰의 하단 안전 영역에 맞춤
        }
    }
}

// UITableViewDataSource 및 UITableViewDelegate 구현
extension AlarmListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.alarms.count // 알람 개수 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        let alarm = viewModel.alarms[indexPath.row]
        cell.textLabel?.text = "\(alarm.title ?? "") - \(alarm.time?.description ?? "")" // 알람 정보 표시
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 편집 가능 설정
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarmToDelete = viewModel.alarms[indexPath.row]
            viewModel.deleteAlarm(alarm: alarmToDelete) // 알람 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic) // 테이블뷰에서도 삭제
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
// SwiftUI 뷰로 UIKit 뷰 컨트롤러를 래핑
struct ViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AlarmListViewController {
        return AlarmListViewController()
    }
    
    func updateUIViewController(_ uiViewController: AlarmListViewController, context: Context) {
        // 뷰 컨트롤러 업데이트가 필요할 때 사용
    }
}

// SwiftUI Preview
@available(iOS 13.0, *)
struct ViewControllerPreview_Preview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview()
            .edgesIgnoringSafeArea(.all) // Safe Area를 무시하고 전체 화면으로 표시하고 싶은 경우
    }
}
#endif

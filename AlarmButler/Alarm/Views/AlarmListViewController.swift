//
//  AlarmListViewController.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit
import SnapKit
import CoreData

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
        fetchCoreData()
    }
    
    func fetchCoreData() {
        // AppDelegate에서 NSManagedObjectContext 인스턴스 가져오기
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        // Fetch Request 생성
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AlarmEntity")
        
        do {
            // Fetch Request 실행
            let results = try context.fetch(fetchRequest)
            
            // 결과 출력
            for result in results as! [NSManagedObject] {
                if let alarmEntity = result as? AlarmEntity {
                    // 객체의 속성에 접근하여 출력
                    print("---------------------------------------------------")
                    print("알람 ID: \(alarmEntity.alarmId ?? UUID())")
                    print("알람 제목: \(alarmEntity.title ?? "기본 제목")")
                    print("알람 시간: \(alarmEntity.time ?? Date())")
                    print("알람 소리: \(alarmEntity.sound ?? "기본 소리")")
                    print("알람 활성화 상태: \(alarmEntity.isEnabled)")
                    if let repeatDays = alarmEntity.repeatDays as? [String] {
                        print("반복 요일: \(repeatDays.joined(separator: ", "))")
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
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
        
        // onSave Closure 구현
        detailVC.onSave = { [weak self] in
            // 알람 저장 후 해야 할 작업
            self?.dismiss(animated: true, completion: nil) // 모달 닫기
            self?.viewModel.fetchAlarms() // 알람 데이터 다시 불러오기
            self?.tableView.reloadData() // 테이블 뷰 리로드
        }
        
        present(detailVC, animated: true, completion: nil)
    }

    // 편집 모드 전환 액션
    @objc private func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true) // 편집 모드 전환
        // 편집 버튼의 타이틀을 편집 모드에 따라 변경.
        let buttonTitle = tableView.isEditing ? "완료" : "편집"
        editButton.setTitle(buttonTitle, for: .normal)
    }

    // MARK: - 테이블뷰 설정
    // 테이블뷰 설정과 SnapKit을 사용한 레이아웃 정의
    private func setupTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlarmListTableViewCell.self, forCellReuseIdentifier: "AlarmListTableViewCell") // AlarmListTableViewCell 등록
        tableView.backgroundColor = UIColor.white //  설정

        tableView.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom) // 커스텀 네비게이션 바의 하단에 맞춤
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide) // 뷰의 하단 안전 영역에 맞춤
        }
    }
}

// UITableViewDataSource 및 UITableViewDelegate 구현
// UITableViewDataSource 구현
extension AlarmListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.alarms.count // 뷰 모델의 알람 개수 반환
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmListTableViewCell", for: indexPath) as? AlarmListTableViewCell else {
            return UITableViewCell()
        }
        let alarm = viewModel.alarms[indexPath.row]
        cell.configureWith(alarm) // 알람 데이터를 셀에 설정
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0 // 셀의 높이를 100포인트로 설정
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

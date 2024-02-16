//
//  WorldClockVC.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import Foundation
import UIKit
import SnapKit

class WorldClockViewController: UIViewController {    
    let clockDataManager = WorldClockManager.shared
    
    // 세계 시계 데이터 배열
    var clockData: [WorldClockEntity] {
        ///0번째에 세계시계 라벨
        ///1번째에 셰계시간 데이터
        get {
            return clockDataManager.getSavedWorldClock()
        }
    }
    
    private lazy var worldLabel = {
        let worldLabel = UILabel()
        worldLabel.text = "세계 시계"
        worldLabel.textColor = .black
        worldLabel.font = UIFont.boldSystemFont(ofSize: 40)
        return worldLabel
    }()
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identi)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    //네비게이션바 설정
    let navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.barTintColor = .white
        return navigationBar
    }()
    
    func setUpNavigationBar() {
        let navItem = UINavigationItem()

        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedButton))
        rightButton.tintColor = .systemOrange
        navigationItem.rightBarButtonItem = rightButton
        navItem.rightBarButtonItem = rightButton
        navigationBar.setItems([navItem], animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        setUpNavigationBar()
        addSubView()
        autoLayout()
    }
}

extension WorldClockViewController {
    private func addSubView(){
        view.addSubview(navigationBar)
        view.addSubview(tableView)
        view.addSubview(worldLabel)
    }
        
    private func autoLayout(){
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        worldLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalToSuperview().offset(8)
            make.height.equalTo(60)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(worldLabel.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
        
    // TimeZoneViewController로부터 전달받은 데이터를 처리하는 함수
//    func addClockData(_ region: String, _ timeZone: TimeZone) {
//        print("addClockData")
//        clockDataManager.saveWorldClockData(newRegion: region, newTimeZone: timeZone) {
//        }
//    }
}

extension WorldClockViewController: UITableViewDelegate, UITableViewDataSource {
    //셀이 비었을 때 세계시계 없음 Label
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identi, for: indexPath) as! CustomTableViewCell
        cell.clockData = clockData[indexPath.row]
        return cell
        
    }
    
    // 테이블 뷰의 특정 행을 편집할 때의 동작 설정
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            clockDataManager.removeClock(deleteTarget: clockData[indexPath.row]) {
            tableView.reloadData()
            }
        }
    }
}

extension WorldClockViewController {
    @objc private func tappedButton() {
        print("tappedButton")
        //let firstVC = WorldClockViewController()
        let VC = TimeZoneController()
        VC.delegate = self
        //데이터 연결, clockData는 TimZoneController가 표시되기 전에 설정
        VC.clockData = clockDataManager.getWorldClockData()
        self.present(VC, animated: true)
        //firstVC.tableView.reloadData()
    }
}

extension WorldClockViewController: TimeZoneViewControllerDelegate {
    func didUpdateWorldClockData() {
        // 테이블 뷰를 리로드합니다.
        tableView.reloadData()
    }
}

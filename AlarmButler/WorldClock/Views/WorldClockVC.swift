//
//  WorldClockVC.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI


class WorldClockViewController: UIViewController {
    
    let clockDataManager = WorldClockManager.shared
    
    var colckData: [WorldClockEntity] {
        get {
            return clockDataManager.getSavedWorldClock()
        }
    }
    
    
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.register(WorldClockViewCell.self, forCellReuseIdentifier: WorldClockViewCell.identi)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identi)
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
    }
    
    private func autoLayout(){
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // TimeZoneViewController로부터 전달받은 데이터를 처리하는 함수
    func addClockData(_ region: String, _ timeZone: TimeZone) {
        clockDataManager.saveWorldClockData(newRegion: region, newTimeZone: timeZone) {
            // 저장이 완료되면 화면을 갱신합니다. (예: 테이블 뷰 리로드)
            self.tableView.reloadData()
        }
    }
}

extension WorldClockViewController: UITableViewDelegate, UITableViewDataSource {
    //셀이 비었을 때 세계시계 없음 Label
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colckData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: WorldClockViewCell.identi, for: indexPath) as! WorldClockViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identi, for: indexPath) as! CustomTableViewCell
            
            cell.clockData = colckData[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let _ = tableView.cellForRow(at: indexPath) as? WorldClockViewCell {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            
            clockDataManager.removeClock(deleteTarget: colckData[indexPath.row]) {
            tableView.reloadData()
            }
        }
    }
}

extension WorldClockViewController {
    @objc private func tappedButton() {
        let firstVC = WorldClockViewController()
        let VC = TimeZoneController()
        VC.delegate = self
        //데이터 연결, clockData는 TimZoneController가 표시되기 전에 설정
        VC.clockData = clockDataManager.getWorldClockData()
        self.present(VC, animated: true)
        firstVC.tableView.reloadData()
    }
}

extension WorldClockViewController: TimeZoneViewControllerDelegate {
    func didUpdateWorldClockData() {
        // 테이블 뷰를 리로드합니다.
        tableView.reloadData()
    }
}

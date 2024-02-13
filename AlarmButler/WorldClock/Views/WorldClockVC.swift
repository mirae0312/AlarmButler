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
        tableView.backgroundColor = .gray
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
}

extension WorldClockViewController: UITableViewDelegate, UITableViewDataSource {
    //셀이 비었을 때 세계시계 없음 Label
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorldClockViewCell.identi, for: indexPath) as! WorldClockViewCell
        
        return cell
    }
}

extension WorldClockViewController {
    @objc private func tappedButton() {
        let VC = TimZoneController()
        self.present(VC, animated: true)
    }
}


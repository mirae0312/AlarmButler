//
//  WorldClockModel.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation
import UIKit
import SnapKit


class WorldClockViewController: UIViewController {
    //슬라이드로 셀 삭제
    //셀이 비었으면 "비었습니다" label
    
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.register(WorldClockViewCell.self, forCellReuseIdentifier: WorldClockViewCell.identi)
        return tableView
    }()
    private lazy var worldLabel = {
        let worldLabel = UILabel()
        worldLabel.text = "세계 시계"
        worldLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        return worldLabel
    }()

    private lazy var plusButton: UIBarButtonItem = {
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedButton))
        plusButton.tintColor = .systemOrange
        
        return plusButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = plusButton
        
        addSubView()
        autoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.rightBarButtonItem = plusButton
    }
}
extension WorldClockViewController {
    private func addSubView(){
        
        view.addSubview(tableView)
        view.addSubview(worldLabel)
        
    }

    private func autoLayout(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(worldLabel.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        worldLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(22)
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

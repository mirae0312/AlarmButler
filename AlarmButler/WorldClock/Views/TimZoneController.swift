//
//  AddView.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/7/24.
//

import UIKit
import SnapKit


class TimZoneController: UIViewController {
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색"
        searchBar.showsCancelButton = true

        return searchBar
    }()
    
    
    private lazy var addTableView: UITableView = {
        let addTableView = UITableView()
        addTableView.backgroundColor = .gray
        addTableView.register(TimeZoneTableViewCell.self, forCellReuseIdentifier: TimeZoneTableViewCell.identi)
        return addTableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        addTableView.delegate = self
        addTableView.dataSource = self
        addSubView()
        autoLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //서치바를 항상 편집모드로 해서 취소버튼 항상 활성화 되도록
        searchBar.becomeFirstResponder()
    }
    
}
extension TimZoneController {
    private func addSubView() {
        view.addSubview(searchBar)
        view.addSubview(addTableView)
    }
    private func autoLayout() {
        
        searchBar.snp.makeConstraints{ make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        addTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension TimZoneController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeZoneTableViewCell.identi, for: indexPath) as! TimeZoneTableViewCell
        
        return cell
    }
}

extension TimZoneController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}


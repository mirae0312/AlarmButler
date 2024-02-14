//
//  TimeZoneController.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import UIKit
import SnapKit
import SwiftUI

class TimZoneController: UIViewController {
    
    var filteredData: [(String, TimeZone)] = []
    
    let sectionTitle = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var clockData: [(String, TimeZone)] = [] {
        didSet {
            setClockDataSection()
        }
    }
    
    lazy var clockDataWithSection: [String: [String]] = [:]
    
    lazy var timezoneDataWithSection: [String: [TimeZone]] = [:]
    
    let worldClockManager = WorldClockManager.shared
    
    //초성을 추출하는 함수
    //0xAC00...0xD7A3 = 가...힣 범위의 유니코드
    func getInitialConsonant(text: String) -> String? {
        //주어진 문자열의 첫 번째 문자의 unicode스칼라 값을 가져옴
        guard let firstChar = text.unicodeScalars.first?.value else { return nil }
        //fiestChar이 한글 범위 내에 있는지 확인
        guard 0xAC00...0xD7A3 ~= firstChar else { return nil }
        //초성 중성 종성 중 초성만 뽑아내기
        //유니코드 = (초성 인덱스 * 21 + 중성 인덱스) * 28 + 종성 인덱스 + 0xAC00
        let value = ((firstChar - 0xAC00) / 28 ) / 21
        //유니코드를 문자열로 변환
        //%C는 포맷 문자열
        //0x1100는 ㄱ의 유니코드
        return String(format:"%C", value + 0x1100)
    }
    
    func setClockDataSection() {
        let _ = clockData.map { (region, timeZone) in
            //초성 얻기
            //getInitialConsonant(text: region)에서 반환된 초성 값을 가져오는 것
            guard var initialConsonant = getInitialConsonant(text: region) else { return }
            //해당 지역명의 초성을 얻어내는 함수
            
            initialConsonant = toInitialConsonant(consonant: initialConsonant)
            
            if let _ = clockDataWithSection[initialConsonant] {
                print(":휴식:")
            } else {
                clockDataWithSection[initialConsonant] = []
            }
            if let _ = timezoneDataWithSection[initialConsonant] {
                print(":휴식:")
            } else {
                timezoneDataWithSection[initialConsonant] = []
            }
            clockDataWithSection[initialConsonant]?.append(region)
            timezoneDataWithSection[initialConsonant]?.append(timeZone)
        }
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //서치바를 항상 편집모드로 해서 취소버튼 항상 활성화 되도록
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        addTableView.delegate = self
        addTableView.dataSource = self
        addSubView()
        autoLayout()
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .lightGray
        }
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if(filteredData.count != 0) {
            return nil
        }
        return sectionTitle
    }
   func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if(filteredData.count != 0) {
            return 0
        }
        return index
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(filteredData.count != 0) {
            return 1
        }
        return sectionTitle.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(filteredData.count != 0) {
            //수정 필요
            return nil
        }
        return sectionTitle[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionArray = clockDataWithSection[sectionTitle[section]] else {
            return 0
        }
        
        if(filteredData.count > 0) {
            return filteredData.count
        } else {
            return sectionArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimeZoneTableViewCell.identi, for: indexPath) as! TimeZoneTableViewCell
        
        guard let sectionArray = clockDataWithSection[sectionTitle[indexPath.section]] else {
            return UITableViewCell()
        }
        if(filteredData.count == 0) {
            cell.data = sectionArray[indexPath.row]
        } else {
            cell.data = filteredData[indexPath.row].0
        }
        
        return cell
    }
    //셀 선택시
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath) {
        if(filteredData.count > 0) {
            worldClockManager.saveWorldClockData(newRegion: filteredData[indexPath.row].0, newTimeZone: filteredData[indexPath.row].1) {
                self.dismiss(animated: true)
            }
        } else {
            worldClockManager.saveWorldClockData(newRegion: clockDataWithSection[sectionTitle[indexPath.section]]![indexPath.row], newTimeZone: timezoneDataWithSection[sectionTitle[indexPath.section]]![indexPath.row]) {
                self.dismiss(animated: true)
            }
        }
    }
}


extension TimZoneController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? clockData : clockData.filter({ tuple -> Bool in
            return tuple.0.range(of: searchText, options: [.caseInsensitive]) != nil
        })
        addTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
}

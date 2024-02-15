//
//  TimeZoneController.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/12/24.
//

import UIKit
import SnapKit

// 세계 시간대 뷰 컨트롤러 델리게이트 프로토콜
protocol TimeZoneViewControllerDelegate: AnyObject {
    // 세계 시계 데이터가 업데이트되었음을 델리게이트에게 알리는 메서드
    func didUpdateWorldClockData()
}

class TimeZoneController: UIViewController {
    let worldClockManager = WorldClockManager.shared
    
    weak var delegate: TimeZoneViewControllerDelegate?
    // 초성별 지역 이름 데이터 딕셔너리
    lazy var clockDataWithSection: [String: [String]] = [:]
    // 초성별 시간대 데이터 딕셔너리
    lazy var timezoneDataWithSection: [String: [TimeZone]] = [:]
    
    var filteredData: [(String, TimeZone)] = []
    
    let sectionTitle = ["ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var clockData: [(String, TimeZone)] = [] {
        didSet {
            setClockDataSection()
        }
    }

    
    // 주어진 문자열의 초성을 추출하는 함수
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
    
    // 시계 데이터 섹션을 설정하는 메서드
    func setClockDataSection() {
        let _ = clockData.map { (region, timeZone) in
            guard var initialConsonant = getInitialConsonant(text: region) else { return }
            initialConsonant = toInitialConsonant(consonant: initialConsonant)
            
            if clockDataWithSection[initialConsonant] == nil {
                clockDataWithSection[initialConsonant] = []
            }
            if timezoneDataWithSection[initialConsonant] == nil {
                timezoneDataWithSection[initialConsonant] = []
            }
            //초성별로 지역과 해당하는 시간대를 그룹화하여 저장
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



extension TimeZoneController {
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


extension TimeZoneController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 13// 원하는 높이로 변경
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .lightGray
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

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
        if !filteredData.isEmpty {
            cell.data = filteredData[indexPath.row].0
        } else {
            cell.data = sectionArray[indexPath.row]
        }
        return cell
    }
    
    //셀 선택시
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _ = WorldClockViewController()
        if(filteredData.count > 0) {
            worldClockManager.saveWorldClockData(newRegion: filteredData[indexPath.row].0, newTimeZone: filteredData[indexPath.row].1) {
                self.delegate?.didUpdateWorldClockData()
                self.dismiss(animated: true)
            }
        } else {
            worldClockManager.saveWorldClockData(newRegion: clockDataWithSection[sectionTitle[indexPath.section]]![indexPath.row], newTimeZone: timezoneDataWithSection[sectionTitle[indexPath.section]]![indexPath.row]) {
                self.delegate?.didUpdateWorldClockData()
                self.dismiss(animated: true)
            }
        }
    }
}


extension TimeZoneController: UISearchBarDelegate {
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


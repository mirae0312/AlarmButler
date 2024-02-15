//
//  TimerRingtoneSelectViewController.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import UIKit
import SnapKit

class TimerRingtoneSelectViewController: UIViewController,UITableViewDelegate {
    
    var viewModel = TimerViewModel()
    var tableview = UITableView()
    
    var soundUpdateClosure: ((String) -> Void)?
    
    let sounds: [String] = ["electronic","toaster", "kitchen","beeping"]
    
    var selectedSoundFromTimerViewController: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupController()

    }
    
    func setupUI(){
        // 네비게이션 바 설정
        navigationItem.title = "타이머 종료 시"
        
        let leftBarButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        leftBarButton.tintColor = UIColor.systemOrange
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(settingButtonTapped))
        rightBarButton.tintColor = UIColor.systemOrange
        navigationItem.rightBarButtonItem = rightBarButton
        
        //메인 뷰 설정
        view.backgroundColor = UIColor.systemBackground
        
        //테이블 뷰 설정 및 제약 조건 추가
        tableview.register(TimerRingtoneSelectTableViewCell.self, forCellReuseIdentifier: "RingCell")
        tableview.backgroundColor = UIColor.systemGray6

        view.addSubview(tableview)
        
        // SnapKit 레이아웃
        tableview.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50 * sounds.count)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.layer.cornerRadius = 10
        tableview.layer.masksToBounds = true
    }

    @objc func cancelButtonTapped(){
        self.dismiss(animated: true)
    }
    
    @objc func settingButtonTapped(){
        self.dismiss(animated: true)
    }
    
    func setupController(){
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    deinit{
        audioPlayer?.stop()
    }
    
}

extension TimerRingtoneSelectViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RingCell", for: indexPath) as? TimerRingtoneSelectTableViewCell else {
            return UITableViewCell()
        }

        // 직접 sounds 배열에서 사운드 이름을 사용
        let soundName = sounds[indexPath.row]
        cell.soundLabel.text = soundName
        cell.accessoryType = .none
        cell.tintColor = .systemOrange

        // 선택된 사운드와 현재 셀의 사운드가 같은 경우 체크마크를 표시
        if let selectedSound = selectedSoundFromTimerViewController, soundName == selectedSound {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSound = sounds[indexPath.row]
        soundUpdateClosure?(selectedSound)
        
        // 모든 visible cells의 체크마크를 제거
        let _ = tableView.visibleCells.map { cell in
            if let timerCell = cell as? TimerRingtoneSelectTableViewCell, timerCell.accessoryType == .checkmark {
                timerCell.accessoryType = .none
            }
        }
        
        // 현재 선택된 셀에 체크마크를 추가
        if let cell = tableView.cellForRow(at: indexPath) as? TimerRingtoneSelectTableViewCell {
            cell.accessoryType = .checkmark
        }

        // 선택된 사운드 재생
        playSound(fileName: selectedSound)

        // 선택한 행의 선택 상태를 해제
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

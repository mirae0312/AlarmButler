//
//  TimerViewController.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import UIKit
import SnapKit

class TimerViewController: UIViewController {
    
    // UI Components
    let cancelButton = UIButton()
    let startButton = UIButton()
    var timeLabel = UILabel()
    var timeSubLabel = UILabel()
    var ringtoneSelectView = UIView()
    let chevronImage = UIImageView()
    let timerQuit = UILabel()
    var ringtoneLabel = UILabel()
    var tableView = UITableView()
    let timePicker = UIPickerView()
    
    var circularProgressView = CircularProgressView()
    var viewModel = TimerViewModel()
    var initialSeconds: Int = 0 // 타이머의 전체 시간을 초 단위로 저장
    var timer: Timer?
    
    let date: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(abbreviation: "KST")
        df.dateFormat = "a HH:mm"
        return df
    }()
    
    var remainingTimeInSeconds: Int = 0 // 남은 시간을 초 단위로 추적
    
    var isOn: Bool = false {
        didSet {
            updateTimerUI()
        }
    }
    var paused: Bool = false {
        didSet {
            updateTimerUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupController()
        setupPickerLabel()
        setupConstraints()
    }
    
    private func animateTimerTransition() {
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.timePicker.alpha = 0
            self?.circularProgressView.alpha = 1
        }
    }
    // MARK: - Setup UI and Bindings
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        timePicker.isHidden = false
        //        circularProgressView.isHidden = true
        
        view.addSubview(timePicker)
        view.addSubview(cancelButton)
        view.addSubview(startButton)
        view.addSubview(ringtoneSelectView)
        ringtoneSelectView.addSubview(ringtoneLabel)
        ringtoneSelectView.addSubview(chevronImage)
        ringtoneSelectView.addSubview(timerQuit)
        view.addSubview(tableView)
        tableView.register(TimerLabelTableViewCell.self, forCellReuseIdentifier: "TimerRecordCell")
        
        cancelButton.layer.cornerRadius = 40
        startButton.layer.cornerRadius = 40
        
        startButton.setTitle("시작", for: .normal)
        startButton.backgroundColor = UIColor.systemGreen
        startButton.setTitleColor(UIColor.label, for: .normal)
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.backgroundColor = UIColor.systemGray6
        cancelButton.setTitleColor(UIColor.label, for: .normal)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        ringtoneSelectView.backgroundColor = UIColor.systemGray5
        ringtoneSelectView.layer.cornerRadius = 10
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ringtoneSelectViewTapped))
        ringtoneSelectView.addGestureRecognizer(tap)
        ringtoneSelectView.isUserInteractionEnabled = true
        
        timerQuit.text = "타이머 종료 시"
        timerQuit.textColor = UIColor.secondaryLabel
        
        chevronImage.image = UIImage(systemName: "chevron.right")
        chevronImage.tintColor = UIColor.systemGray2
        
        ringtoneLabel.text = "실행중단"
        ringtoneLabel.textColor = UIColor.tertiaryLabel
        
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.systemGray6
    }
    
    @objc func ringtoneSelectViewTapped(){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.ringtoneSelectView.layer.opacity = 0.6
        }
        
        let ringtoneSelectVC = TimerRingtoneSelectViewController()
        
        // 선택한 벨소리를 ViewModel에 저장하는 콜백 설정
        ringtoneSelectVC.soundUpdateClosure = { [weak self] selectedSound in
            self?.viewModel.selectedRingtone = selectedSound
            self?.ringtoneLabel.text = selectedSound
        }
        // 선택한 벨소리를 표시하기 위해 현재 선택된 벨소리를 전달
        ringtoneSelectVC.selectedSoundFromTimerViewController = viewModel.selectedRingtone
        
        let navigationController = UINavigationController(rootViewController: ringtoneSelectVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setupPickerLabel() {
        let labelsText = ["시간", "분", "초"]
        var labels: [Int: UILabel] = [:]
        
        for (index, text) in labelsText.enumerated() {
            let label = UILabel()
            label.text = text
            labels[index] = label
        }
        
        timePicker.setPickerLabels(labels: labels, containedView: self.view)
    }
    
    func setupController() {
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func setupConstraints() {
        timePicker.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview().offset(20)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        startButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview().offset(20)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        ringtoneSelectView.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        
        timerQuit.snp.makeConstraints{
            make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        
        chevronImage.snp.makeConstraints {
            make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-10)
        }
        
        ringtoneLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(chevronImage.snp.left).offset(-10)
        }
        
        tableView.snp.makeConstraints{
            make in
            make.top.equalTo(ringtoneSelectView.snp.bottom).offset(10)
            make.height.equalTo(150)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        isOn = false
        paused = true
        remainingTimeInSeconds = 0
        
        if let id = viewModel.currentTimerId {
            viewModel.updateTimerRecord(id: id, newIsActive: false)
        }
        resetTimerUI()
    }
    
    @objc func startButtonTapped(_ sender: UIButton) {
        // timePicker에서 선택된 시간, 분, 초가 모두 0인지 확인
        let hour = timePicker.selectedRow(inComponent: 0)
        let minute = timePicker.selectedRow(inComponent: 1)
        let second = timePicker.selectedRow(inComponent: 2)
        let totalSeconds = hour * 3600 + minute * 60 + second
        
        // totalSeconds가 0이 아니면 circularProgressView 설정 진행
        if totalSeconds > 0 {
            if circularProgressView.superview == nil {
                view.addSubview(circularProgressView)
            }
        }
        setupTimerUI()
        if isOn {
            if paused {
                // 타이머가 활성화되어 있고, 일시 정지된 상태이면, 타이머를 재개합니다.
                resumeTimer()
            } else {
                // 타이머가 활성화되어 있고, 일시 정지되지 않았다면, 타이머를 일시 정지합니다.
                pauseTimer()
            }
        } else {
            
            // 타이머를 시작하기 위한 설정값 확인
            let hour = timePicker.selectedRow(inComponent: 0)
            let minute = timePicker.selectedRow(inComponent: 1)
            let second = timePicker.selectedRow(inComponent: 2)
            let totalSeconds = hour * 3600 + minute * 60 + second
            
            if totalSeconds == 0 {
                return
            }
            
            // 타이머가 아직 시작되지 않은 경우 타이머 시작
            if !isOn {
                remainingTimeInSeconds = totalSeconds
                let selectedRingtone = ringtoneLabel.text ?? "toaster"
                startTimer(hour: hour, minute: minute, second: second, ringTone: selectedRingtone)
            }
        }
    }
    
    func startTimer(hour: Int, minute: Int, second: Int, ringTone: String) {
        isOn = true
        paused = false
        let duration = hour * 3600 + minute * 60 + second
        
        timer?.invalidate()
        timePicker.alpha = 0
        
        circularProgressView.alpha = 1
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        // 타이머가 시작될 때 Circular Progress 업데이트
        updateCircularProgress()
        
        remainingTimeInSeconds = duration
        initialSeconds = duration
        let label = "\(hour)시 \(minute)분 \(second)초"
        let ringTone = ringtoneLabel.text ?? "toaster"
        viewModel.saveTimerRecord(duration: duration, label: label, ringTone: ringTone, isActive: isOn)
    }
    
    func pauseTimer() {
        paused = true
        timer?.invalidate()
    }
    
    func resumeTimer() {
        paused = false
        
        // `updateTime` 함수를 타이머의 콜백으로 지정하여 시간 감소 및 UI 업데이트
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTimerUI() {
        
        updateStartButton()
        
        timePicker.isHidden = isOn
        circularProgressView.isHidden = !isOn
    }
    
    private func updateStartButton() {
        let buttonTitle: String
        let buttonColor: UIColor
        
        if isOn {
            buttonTitle = paused ? "재개" : "일시 정지"
            buttonColor = paused ? .systemTeal : .systemOrange
        } else {
            buttonTitle = "시작"
            buttonColor = .systemGreen
        }
        
        startButton.setTitle(buttonTitle, for: .normal)
        startButton.backgroundColor = buttonColor
    }
    
    func updateTimeLabel() {
        // 타이머가 중지된 경우 함수 실행을 중단
        guard isOn else { return }
        
        let hours = remainingTimeInSeconds / 3600
        let minutes = (remainingTimeInSeconds % 3600) / 60
        let seconds = remainingTimeInSeconds % 60
        
        let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        timeLabel.text = hours > 0 ? formattedTime : String(format: "%02d:%02d", minutes, seconds)
        timeLabel.font = timeLabel.font.withSize(hours > 0 ? 78 : 82)
        timeSubLabel.text = date.string(from: Date(timeIntervalSinceNow: TimeInterval(timePicker.selectedRow(inComponent: 0) * 3600 + timePicker.selectedRow(inComponent: 1) * 60 + timePicker.selectedRow(inComponent: 2))))
        
    }
    
    func setupTimerUI() {
        circularProgressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.75)
            make.height.equalTo(circularProgressView.snp.width)
        }
        circularProgressView.trackColor = .lightGray
        circularProgressView.progressColor = .systemOrange
        circularProgressView.trackLineWidth = 15
        circularProgressView.progressLineWidth = 15
        circularProgressView.backgroundColor = .clear
        
        circularProgressView.addSubview(timeLabel)
        circularProgressView.addSubview(timeSubLabel)
        setupLabels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        circularProgressView.layer.cornerRadius = circularProgressView.frame.width / 2
        circularProgressView.clipsToBounds = true
        tableView.layer.masksToBounds = true
    }
    
    private func setupLabels() {
        timeLabel.textColor = UIColor.label
        timeSubLabel.textColor = UIColor.label
        
        timeLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        timeSubLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(20)
        }
    }
    
    func resetTimerUI() {
        // UI 컴포넌트를 초기 상태로 되돌리기
        timePicker.isHidden = false
        circularProgressView.isHidden = true
        timeLabel.text = "00:00"
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let self = self else { return }
            self.circularProgressView.alpha = 0
            self.timePicker.alpha = 1
        }
        
        resetTimePickerComponents()
        tableView.reloadData()
    }
    
    // 타임 피커의 모든 컴포넌트를 초기 상태로 설정
    private func resetTimePickerComponents() {
        let components = [0, 1, 2] // 시, 분, 초 컴포넌트 인덱스
        components.forEach { component in
            timePicker.selectRow(0, inComponent: component, animated: false)
        }
    }
}

extension TimerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component < viewModel.time.count {
            return "\(viewModel.time[component][row])"
        } else {
            return nil
        }
    }
}

extension TimerViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.time[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.time.count
    }
}

extension UIPickerView {
    func setPickerLabels(labels: [Int: UILabel], containedView: UIView) {
        let fontSize: CGFloat = 20
        let labelWidth: CGFloat = containedView.bounds.width / CGFloat(numberOfComponents)
        let labelY: CGFloat = (frame.size.height / 2) - (fontSize / 2)
        
        labels.forEach { componentIndex, label in
            guard componentIndex < numberOfComponents, let labelText = label.text else { return }
            
            let labelXOffset: CGFloat = labelText.count == 2 ? 36 : 24
            let labelX: CGFloat = frame.origin.x + labelWidth * CGFloat(componentIndex) + labelXOffset
            label.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: fontSize)
            configureLabel(label, withFontSize: fontSize)
            addLabelToPicker(label)
        }
    }
    
    private func configureLabel(_ label: UILabel, withFontSize fontSize: CGFloat) {
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = UIColor.label
    }
    
    private func addLabelToPicker(_ label: UILabel) {
        guard !subviews.contains(label) else { return }
        addSubview(label)
    }
}
extension TimerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 타이머 기록 가져오기
        let selectedTimer = viewModel.timerRecords[indexPath.row]
        
        // 기존 타이머 중지
        timer?.invalidate()
        
        // 모든 셀의 체크마크 제거
        clearCheckmarks(in: tableView)
        
        // 새 타이머 시작
        startNewTimer(withDuration: Int(selectedTimer.duration), ringTone: viewModel.selectedRingtone ?? "toaster")
        
        // 현재 선택된 셀에 체크마크 추가
        addCheckmarkToSelectedCell(at: indexPath, in: tableView)
        
        // 선택 상태 해제
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func startNewTimer(withDuration duration: Int, ringTone: String) {
        timer?.invalidate()
        view.addSubview(circularProgressView)
        setupTimerUI()
        animateTimerTransition()
        remainingTimeInSeconds = duration
        initialSeconds = duration
        viewModel.selectedRingtone = ringTone
        isOn = true
        paused = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        updateCircularProgress()
    }
    
    @objc func updateTime() {
        if remainingTimeInSeconds > 0 {
            remainingTimeInSeconds -= 1
            
            DispatchQueue.main.async { [weak self] in
                self?.updateTimeLabel()
                self?.updateCircularProgress()
            }
            
            if let id = viewModel.currentTimerId {
                viewModel.updateTimerRecord(id: id, newIsActive: true)
            }
        } else {
            // 타이머가 자연적으로 0에 도달하여 종료될 경우
            timer?.invalidate()
            timer = nil
            isOn = false
            paused = false
            if let id = viewModel.currentTimerId {
                viewModel.updateTimerRecord(id: id, newIsActive: false)
            }
            // 타이머 종료 시 알림음 재생
            viewModel.notifyTimerCompletion()
            // UI 컴포넌트를 초기 상태로 되돌리고, 필요한 UI 업데이트 수행
            DispatchQueue.main.async { [weak self] in
                self?.resetTimerUI()
            }
        }
    }
    
    func updateCircularProgress() {
        // 진행률 계산
        let progress = CGFloat(remainingTimeInSeconds) / CGFloat(initialSeconds)
        
        // Circular Progress 업데이트 (
        circularProgressView.setProgressWithAnimation(duration: 1.0, value: CGFloat(progress))
    }
    
    private func clearCheckmarks(in tableView: UITableView) {
        for cell in tableView.visibleCells where cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        }
    }
    
    private func addCheckmarkToSelectedCell(at indexPath: IndexPath, in tableView: UITableView) {
        if let cell = tableView.cellForRow(at: indexPath) as? TimerLabelTableViewCell {
            cell.accessoryType = .checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            viewModel.deleteTimerRecord(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(_: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        44
    }
}
extension TimerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.timerRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimerRecordCell", for: indexPath) as? TimerLabelTableViewCell else {
            return UITableViewCell()
        }
        let record = viewModel.timerRecords[indexPath.row]
        let duration = Int(record.duration)
        
        cell.recordLabel.text = "\(viewModel.formatTimeForDisplay(duration: duration)) 타이머"
        cell.accessoryType = .none
        cell.tintColor = .systemOrange
        
        return cell
        
    }
}


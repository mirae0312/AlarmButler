//
//  TimerView.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import UIKit
import SnapKit

class TimerViewController: UIViewController {
    
    // UI Components
    let cancelButton = UIButton()
    let startButton = UIButton()
    var timerView = UIView()
//    var timerInnerView = UIView()
    var timeLabel = UILabel()
    var timeSubLabel = UILabel()
    var ringtoneSelectView = UIView()
    let chevronImage = UIImageView()
    let timerQuit = UILabel()
    var ringtoneLabel = UILabel()
    var tableView = UITableView()
    let timePicker = UIPickerView()
    
    var circularProgressView: CircularProgressView?
    var initialSeconds: Int = 0 // 타이머의 전체 시간을 초 단위로 저장
    
    var viewModel = TimerViewModel()
    
    var timer: Timer?
    var remainingSeconds: Int = 0
        
    var time: [[Int]] = [
        Array(0...23),
        Array(0...59),
        Array(0...59)
    ]
    
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
            setupTimerUI()
        }
    }

    var paused: Bool = false {
        didSet {
            updateTimerUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupController()
        setupPickerLabel()
        setupConstraints()
        setupBindings()
        
        // ViewModel의 클로저 구현
        viewModel.updateTimeLabelClosure = { [weak self] timeStr in
            DispatchQueue.main.async {
                self?.timeLabel.text = timeStr
                // 폰트 크기를 조정하지 않고, 필요한 경우 기본값 또는 뷰 설정에서 정의한 값 사용
                // 만약 동적으로 폰트 크기를 조정하고 싶다면, 여기서 직접 조건에 따라 폰트 크기를 결정하고 적용
            }
        }


    }
    
    // MARK: - Setup UI and Bindings
    func setupUI() {
        timerView.isHidden = true
        
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
        cancelButton.setTitleColor(UIColor.label, for: .normal)
        
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
        chevronImage.tintColor = .gray
        
        ringtoneLabel.text = "실행중단"
        ringtoneLabel.textColor = UIColor.tertiaryLabel
        
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.systemYellow
    }
    
    @objc func ringtoneSelectViewTapped(){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.ringtoneSelectView.layer.opacity = 0.6
        }
        
        let modalViewController = TimerRingtoneSelectViewController()
        
        let navigationController = UINavigationController(rootViewController: modalViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setupPickerLabel() {
        let hourLabel = UILabel()
        hourLabel.text = "시간"
        
        let minuteLabel = UILabel()
        minuteLabel.text = "분"
        
        let secondLabel = UILabel()
        secondLabel.text = "초"
        
        timePicker.setPickerLabels(labels: [0:hourLabel, 1: minuteLabel, 2: secondLabel], containedView: self.view)
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
        // 타이머 중지
        timer?.invalidate()
        timer = nil
        
        isOn = false
        paused = true
        
        resetTimer()
    }
    
    @objc func startButtonTapped(_ sender: UIButton) {
        // 타이머 설정값을 가져옴
        let hour = timePicker.selectedRow(inComponent: 0)
        let minute = timePicker.selectedRow(inComponent: 1)
        let second = timePicker.selectedRow(inComponent: 2)
        let totalSeconds = hour * 3600 + minute * 60 + second
        
        // 모든 설정값이 0인 경우, 즉 타이머가 설정되지 않은 경우 함수 종료
        if hour == 0 && minute == 0 && second == 0 {
            print("모든 설정값이 0입니다. 타이머를 설정해주세요.")
            return
        }
        
        if !isOn && !paused {
            remainingTimeInSeconds = totalSeconds
            startTimer(hour: hour, minute: minute, second: second)
        } else if paused {
            // 타이머가 일시 정지 상태인 경우, 타이머 재개
            resumeTimer()
        } else {
            // 그 외의 경우(타이머가 실행 중인 경우), 타이머를 일시 정지
            pauseTimer()
        }
    }

    func startTimer(hour: Int, minute: Int, second: Int) {
        isOn = true
        paused = false
        remainingTimeInSeconds = hour * 3600 + minute * 60 + second
        
        timer?.invalidate() // 기존 타이머가 있으면 종료
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        // 저장 로직
        let duration = hour * 3600 + minute * 60 + second
        let label = "\(hour)시 \(minute)분 \(second)초"
        viewModel.saveTimerRecord(duration: duration, label: label, ringtone: "기본 벨소리")
        
        // Timer 화면에 띄우기
        updateTimerUI()
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
        // 타이머 실행 상태에 따라 UI 업데이트
        if isOn {
            // 타이머가 실행 중일 때
            if paused {
                // 타이머가 일시 정지 상태일 때
                startButton.setTitle("재개", for: .normal)
                startButton.backgroundColor = UIColor.systemTeal
            } else {
                // 타이머가 실행 중일 때
                startButton.setTitle("일시 정지", for: .normal)
                startButton.backgroundColor = UIColor.systemOrange
            }
            timePicker.isHidden = true
            timerView.isHidden = false
        } else {
            // 타이머가 실행 중이지 않을 때 (정지 상태)
            startButton.setTitle("시작", for: .normal)
            startButton.backgroundColor = UIColor.systemGreen
            timePicker.isHidden = false
            timerView.isHidden = true
        }

        // 기타 필요한 UI 업데이트 로직
        // 예: cancelButton의 스타일 변경 등
    }
    
    @objc func updateTimeLabel() {
        // 타이머가 중지된 경우 함수 실행을 중단
        if !isOn {
            return
        }
        let hours = remainingTimeInSeconds / 3600
        let minutes = (remainingTimeInSeconds % 3600) / 60
        let seconds = remainingTimeInSeconds % 60
        
        print("updateTimeLabel 호출: \(hours)시 \(minutes)분 \(seconds)초")
        
        if hours == 0 && minutes == 0 && seconds == 0 {
            print("모든 값이 0으로 설정됨. 타이머 리셋.")
            isOn = false
            paused = true
            resetTimer()
            return
        }
        
        // 시간, 분, 초 포맷팅 (1자리 숫자 앞에 0 추가)
        let hour = String(format: "%02d", hours)
        let minute = String(format: "%02d", minutes)
        let second = String(format: "%02d", seconds)
        
        // 시간 표시 업데이트
        if hours == 0 {
            timeLabel.text = "\(minute):\(second)"
            timeLabel.font = timeLabel.font.withSize(82)
        } else {
            timeLabel.text = "\(hour):\(minute):\(second)"
            timeLabel.font = timeLabel.font.withSize(78)
        }
//        print("타이머 레이블 업데이트: \(timeLabel.text ?? "nil")")
        
        // 타이머 시간 감소 로직
        if seconds > 0 {
            timePicker.selectRow(seconds - 1, inComponent: 2, animated: false)
        } else if minutes > 0 {
            timePicker.selectRow(minutes - 1, inComponent: 1, animated: false)
            timePicker.selectRow(59, inComponent: 2, animated: false)
        } else if hours > 0 {
            timePicker.selectRow(hours - 1, inComponent: 0, animated: false)
            timePicker.selectRow(59, inComponent: 1, animated: false)
            timePicker.selectRow(59, inComponent: 2, animated: false)
        }
    }
    
    func setupTimerUI() {
        
        view.addSubview(timerView)
//        timerView.addSubview(timerInnerView)
//        timerInnerView.addSubview(timeLabel)
//        timerInnerView.addSubview(timeSubLabel)
        
        timerView.backgroundColor = .systemOrange
//        timerInnerView.backgroundColor = UIColor.systemGray6
        timerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.width.equalTo(self.view.snp.width).multipliedBy(0.85)
            make.height.equalTo(timerView.snp.width)
        }
        
//        timerInnerView.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(13)
//        }
        timerView.addSubview(timeLabel)
        timerView.addSubview(timeSubLabel)
        setupLabels()
        
        setupCircularProgressView()
        
        setupAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        timerView.layer.cornerRadius = timerView.frame.width / 2
//        timerInnerView.layer.cornerRadius = timerInnerView.frame.width / 2
//        circularProgressView.layer.cornerRadius = circularProgressView.frame.width / 2
        timerView.clipsToBounds = true
//        timerInnerView.clipsToBounds = true
        tableView.layer.masksToBounds = true
    }
    
    private func setupCircularProgressView() {
        circularProgressView = CircularProgressView()
        guard let circularProgressView = circularProgressView else { return }
        timerView.addSubview(circularProgressView)

        circularProgressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        circularProgressView.trackColor = .lightGray
        circularProgressView.progressColor = .blue
        circularProgressView.trackLineWidth = 5
        circularProgressView.progressLineWidth = 5
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
    
    private func setupAnimation() {
        timePicker.alpha = 1
        timerView.alpha = 0
        
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.timePicker.alpha = 0
            self?.timerView.alpha = 1
        }
    }
    
    func resetTimer() {
        // 타이머 중지
        viewModel.stopTimer()
        
        // UI 컴포넌트 업데이트
        timePicker.isHidden = false
        timerView.isHidden = true
        
        // 타이머 뷰와 타임 피커 뷰의 페이드 인/아웃 애니메이션
        UIView.animate(withDuration: 0.6) { [weak self] in
            guard let self = self else { return }
            self.timerView.alpha = 0
            self.timePicker.alpha = 1
        }
        
        // 타임 피커의 모든 컴포넌트를 초기값으로 리셋
        resetTimePickerComponents()
        
        // 테이블 뷰 리로드
        tableView.reloadData()
    }

    // 타임 피커의 모든 컴포넌트를 초기 상태로 설정
    private func resetTimePickerComponents() {
        let components = [0, 1, 2] // 시, 분, 초 컴포넌트 인덱스
        components.forEach { component in
            timePicker.selectRow(0, inComponent: component, animated: false)
        }
    }
    
    private func setupBindings() {
        viewModel.onTimerUpdate = { [weak self] formattedTime in
            DispatchQueue.main.async {
                self?.timeLabel.text = formattedTime
            }
        }
    }
}

extension TimerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component < time.count {
            return "\(time[component][row])"
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
        // 기본 레이블 설정
        let fontSize: CGFloat = 20
        let labelWidth: CGFloat = containedView.bounds.width / CGFloat(numberOfComponents)
        
        // 레이블의 Y 위치 계산
        let labelY: CGFloat = (frame.size.height / 2) - (fontSize / 2)
        
        for (componentIndex, label) in labels {
            // 컴포넌트 인덱스 검증 및 라벨 텍스트 길이에 따른 X 위치 조정
            guard componentIndex < numberOfComponents, let labelText = label.text else { continue }
            
            let labelXOffset: CGFloat = labelText.count == 2 ? 36 : 24
            let labelX: CGFloat = frame.origin.x + labelWidth * CGFloat(componentIndex) + labelXOffset
            
            // 라벨의 최종 프레임 설정
            label.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: fontSize)
            
            // 라벨 스타일 설정
            configureLabel(label, withFontSize: fontSize)
            
            // 라벨을 UIPickerView에 추가
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
        if !subviews.contains(label) {
            addSubview(label)
        }
    }
}


extension TimerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 선택된 타이머 기록 가져오기
        let selectedTimer = viewModel.timerRecords[indexPath.row]
        
        // 기존 타이머 중지
        timer?.invalidate()

        // 새 타이머 시작
        startNewTimer(withDuration: Int(selectedTimer.duration))

        // 모든 셀의 체크마크 제거
        clearCheckmarks(in: tableView)

        // 현재 선택된 셀에 체크마크 추가
        addCheckmarkToSelectedCell(at: indexPath, in: tableView)
        
        // 선택 상태 해제
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func startNewTimer(withDuration duration: Int) {
        // 남은 시간을 설정
        remainingTimeInSeconds = duration
        
        // 기존 타이머가 있으면 종료
        timer?.invalidate()
        
        // 새 타이머 시작
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        // 타이머 상태 업데이트
        isOn = true
        paused = false
        
        // UI 업데이트
        updateTimerUI()
    }

    @objc func updateTime() {
        // 타이머 업데이트 로직
        if remainingTimeInSeconds > 0 {
            // 남은 시간 감소
            remainingTimeInSeconds -= 1
            
            let progress = 1 - Double(remainingTimeInSeconds) / Double(initialSeconds) // initialSeconds는 타이머 시작 시간(초)입니다.
            circularProgressView?.setProgress(value: progress)
            
            // 시간 업데이트 UI 호출
            updateTimeLabel()
        } else {
            // 타이머 종료 로직
            timer?.invalidate()
            timer = nil
            isOn = false
            paused = false
            
            // 타이머 종료 후 필요한 UI 업데이트
            updateTimerUI()
        }
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
            // ViewModel을 통해 해당 타이머 기록 삭제
            viewModel.deleteTimerRecord(at: indexPath.row)

            // 테이블 뷰에서 행 삭제
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


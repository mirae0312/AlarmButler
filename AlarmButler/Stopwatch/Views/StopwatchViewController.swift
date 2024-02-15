////
////  StopwatchView.swift
////  AlarmButler
////
////  Created by mirae on 2/5/24.
////
//
import SnapKit


class StopwatchViewController: UIViewController {
    
    let mainTimer = UILabel()
    let lapTimer = UILabel()
    let lapAndResetButton = UIButton()
    let startAndStopButton = UIButton()
    let tableView = UITableView()
    
//    MARK: Initializing
    var viewModel = StopwatchViewModel()
    
    
    
    init(viewModel: StopwatchViewModel = StopwatchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupMainTimer()
//        setupLapTimer()
        setuplapAndResetButton()
        setupstartAndStopButton()
        setupTableView()
        
        tableViewConfiguration()
        buttonConfitguration()
        
        tableView.dataSource = self
        viewModel.delegate = self
    }
    
    
    
    func tableViewConfiguration() {
        self.tableView.register(StopwatchTableViewCell.self, forCellReuseIdentifier: "lapCell")
        self.tableView.rowHeight = 40
    }
    
    func buttonConfitguration() {
        self.startAndStopButton.addTarget(self, action: #selector(self.runStopAction), for: .touchUpInside)
        self.lapAndResetButton.addTarget(self, action: #selector(self.lapResetAction), for: .touchUpInside)
    }
    
    // MARK: setup
    
    func setupMainTimer() {
        mainTimer.font = .boldSystemFont(ofSize: 80)
        mainTimer.text = "00.00.00"
        mainTimer.sizeToFit()
        mainTimer.textColor = .black
        view.addSubview(mainTimer)
        
        mainTimer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(140) // 상단 여백 설정
            $0.centerX.equalToSuperview() // 가로축 중앙 정렬
            $0.left.right.equalToSuperview().inset(25) // 좌우 여백 설정
        }
    }
    
    func setupLapTimer() {
        lapTimer.font = .boldSystemFont(ofSize: 30)
        lapTimer.text = "00.00.00"
        lapTimer.sizeToFit()
        lapTimer.textColor = .black
        view.addSubview(lapTimer)
        
        mainTimer.snp.makeConstraints {
            $0.top.equalTo(self.mainTimer.snp.bottom).offset(10) // 상단 여백 설정
            $0.centerX.equalToSuperview() // 가로축 중앙 정렬
            $0.left.right.equalToSuperview().inset(25) // 좌우 여백 설정
        }
    }
    
    func setuplapAndResetButton() {
        let button = lapAndResetButton
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 35
        view.addSubview(button)
        
        button.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.top.equalTo(self.mainTimer.snp.bottom).offset(50)
            $0.centerX.equalToSuperview().offset(-135)
        }
    }
    
    func setupstartAndStopButton() {
        let button = startAndStopButton
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 35
        view.addSubview(button)
        
        button.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.top.equalTo(self.lapAndResetButton)
            $0.centerX.equalToSuperview().offset(135)
        }
    }
    
    func setupTableView() {
        
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGray6
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.lapAndResetButton.snp.bottom).offset(50)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Action
    
    @objc func runStopAction() {
        self.viewModel.runAndStop {
            switch self.viewModel.isRnunnig {
            case .runnig:
                self.changeButton(self.startAndStopButton, title: "Start", titleColor: .black)
                self.startAndStopButton.backgroundColor = .systemGreen
                self.lapAndResetButton.setTitle("Reset", for: .normal)
            case .stop:
                self.changeButton(self.startAndStopButton, title: "Stop", titleColor: .white)
                startAndStopButton.backgroundColor = .systemRed
                self.lapAndResetButton.setTitle("Lap", for: .normal)
            }
        }
    }
    
    @objc func lapResetAction() {
        self.viewModel.lapReset(mainTime: self.mainTimer.text, lapTime: "") {
            if self.viewModel.isRnunnig == .stop {
                self.mainTimer.text = "00.00.00"
            }
            self.tableView.reloadData()
        }
    }
    
    func changeButton(_ button: UIButton, title: String, titleColor: UIColor) {
        button.setTitle(title, for: UIControl.State())
        button.setTitleColor(titleColor, for: UIControl.State())
    }
}

// MARK: Delegate
extension StopwatchViewController: UpdateTimerLabelDelegate {
    func updateTimer(stopwatch: Stopwatch, _ text: String) {
        switch stopwatch.watchType {
        case .main:
            self.mainTimer.text = text
        case .lap: break
//            self.lapTimer.text = text
            
        }
    }
}

// MARK: DataSource
extension StopwatchViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lapCell", for: indexPath) as! StopwatchTableViewCell
        
        let stopwatch = viewModel.laps[indexPath.row]
        
        cell.backgroundColor = .systemGray4
        cell.setUplapLabel(lapTime: stopwatch.lapTime, mainTime: stopwatch.mainTime)
        cell.lapLabel.text = "Lap \(viewModel.laps.count - indexPath.row)"

        return cell
    }
    
    
}






//
//  TimerView.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation
import SnapKit
import SwiftUI

class TimerView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        <#code#>
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    
    var timer = Timer()
    
    let hourPickerView = UIPickerView()
    let minutePickerView = UIPickerView()
    let secondPickerView = UIPickerView()
    
    let hourLabel = UILabel()
    let minuteLabel = UILabel()
    let secondLabel = UILabel()
    
    let timePicker = UIPickerView()
    var viewModel = TimerViewModel()
    
    let cancelButton = UIButton()
    let startButton = UIButton()
    weak var timerView: UIView!
    weak var timerInnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupUI()
        setupPickerViews()
        setupConstraints()
        setupTimer()
        
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        hourLabel.text = "시간"
        minuteLabel.text = "분"
        secondLabel.text = "초"
        
        hourLabel.textAlignment = .center
        minuteLabel.textAlignment = .center
        secondLabel.textAlignment = .center
        
        view.addSubview(hourLabel)
        view.addSubview(minuteLabel)
        view.addSubview(secondLabel)
        
        cancelButton.backgroundColor = .systemGray
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.layer.cornerRadius = 40
        cancelButton.clipsToBounds = true
        
        startButton.backgroundColor = .systemBlue
        startButton.setTitle("시작", for: .normal)
        startButton.layer.cornerRadius = 40
        startButton.clipsToBounds = true
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        view.addSubview(cancelButton)
        view.addSubview(startButton)
    }
    
    func setupPickerViews() {
        hourPickerView.tag = 0
        minutePickerView.tag = 1
        secondPickerView.tag = 2
        
        hourPickerView.delegate = self
        minutePickerView.delegate = self
        secondPickerView.delegate = self
        
        hourPickerView.dataSource = self
        minutePickerView.dataSource = self
        secondPickerView.dataSource = self
        
        view.addSubview(hourPickerView)
        view.addSubview(minutePickerView)
        view.addSubview(secondPickerView)
        
        
        func setupTimer(){
            
            timerView.isHidden = true
            timerView.backgroundColor = .systemOrange
            timerView.clipsToBounds = true
            timerView.layer.cornerRadius = timerView.layer.bounds.width / 2
            
            timerInnerView.backgroundColor = .black
            timerInnerView.clipsToBounds = true
            timerInnerView.layer.cornerRadius =  timerInnerView.layer.bounds.width / 2
            
            timePicker.alpha = 1
            timerView.alpha = 0
            
            UIView.animate(withDuration: 0.6) {[weak self] in
                self?.timePicker.alpha = 0
                self?.timerView.alpha = 1
            }
            
            view.addSubview(timerView)
            
        }
        
        func setupConstraints() {
            timerView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(50)
                make.centerX.equalToSuperview()
            }
            
            hourPickerView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(18)
                
                make.centerY.equalToSuperview().offset(-200)
                make.width.equalToSuperview().dividedBy(4) // Adjust size as needed
            }
            
            hourLabel.snp.makeConstraints { make in
                make.left.equalTo(hourPickerView.snp.right)
                make.centerY.equalToSuperview().offset(-200)
            }
            
            minutePickerView.snp.makeConstraints { make in
                make.left.equalTo(hourLabel.snp.right)
                make.centerY.equalToSuperview().offset(-200)
                make.width.equalToSuperview().dividedBy(4) // Adjust size as needed
            }
            
            minuteLabel.snp.makeConstraints { make in
                make.left.equalTo(minutePickerView.snp.right)
                make.centerY.equalToSuperview().offset(-200)
            }
            
            secondPickerView.snp.makeConstraints { make in
                make.left.equalTo(minuteLabel.snp.right)
                make.centerY.equalToSuperview().offset(-200)
                make.width.equalToSuperview().dividedBy(4) // Adjust size as needed
            }
            
            secondLabel.snp.makeConstraints { make in
                make.left.equalTo(secondPickerView.snp.right)
                make.centerY.equalToSuperview().offset(-200)
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
        }
        
        
        func startButtonTapped(_ sender: UIButton) {
            viewModel.startTimer()
            // Update UI if needed
        }
        
        
            func pauseButtonTapped(_ sender: UIButton) {
                viewModel.pauseTimer()
                // Update UI if needed
            }
        
        
        func stopButtonTapped(_ sender: UIButton) {
            viewModel.stopTimer()
            // Update UI if needed
        }
        
        // UIPickerViewDataSource and UIPickerViewDelegate methods
        
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            let value = (pickerView.tag == 0 ? viewModel.hours[row] : (pickerView.tag == 1 ? viewModel.minutes[row] : viewModel.seconds[row]))
            return "\(value)"
        }
        
    }
    
    extension TimerView: UIPickerViewDelegate {
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
    }
    
    extension TimerView: UIPickerViewDataSource {
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch pickerView.tag {
            case 0: return viewModel.hours.count
            case 1: return viewModel.minutes.count
            case 2: return viewModel.seconds.count
            default: return 0
            }
        }
    }
    
    
#if canImport(SwiftUI) && DEBUG
    
    struct TimerViewPreview: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> TimerView {
            return TimerView()
        }
        
        func updateUIViewController(_ uiViewController: TimerView, context: Context) {
            // Update the view controller if necessary
        }
    }
    
    @available(iOS 13.0, *)
    struct TimerViewPreview_Preview: PreviewProvider {
        static var previews: some View {
            Group {
                TimerViewPreview()
                    .edgesIgnoringSafeArea(.all) // Apply this to a SwiftUI view container
            }
        }
    }
#endif
    
    
    
    

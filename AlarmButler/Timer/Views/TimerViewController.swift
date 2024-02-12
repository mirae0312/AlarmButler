//
//  TimerView.swift
//  AlarmButler
//
//  Created by mirae on 2/5/24.
//

import Foundation
import SnapKit

class TimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let hourPickerView = UIPickerView()
    let minutePickerView = UIPickerView()
    let secondPickerView = UIPickerView()
    
    let hourLabel = UILabel()
    let minuteLabel = UILabel()
    let secondLabel = UILabel()
    
    let pickerView = UIPickerView()
    var viewModel = TimerViewModel()
    
    let cancelButton = UIButton()
    let startButton = UIButton()
    
    //    lazy var startButton: UIButton = {
    //        let button = UIButton()
    //        button.backgroundColor = .systemBlue
    //        button.setTitle("시작", for: .normal)
    //    }()
    //
    //    lazy var pauseButton: UIButton = {
    //        let button = UIButton()
    //        button.backgroundColor = .systemOrange
    //        button.setTitle("중지", for: .normal)
    //    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupLabels()
        setupPickerViews()
        setupButton()
        setupConstraints()
        
        
    }
    
    func setupLabels() {
        hourLabel.text = "시간"
        minuteLabel.text = "분"
        secondLabel.text = "초"
        
        hourLabel.textAlignment = .center
        minuteLabel.textAlignment = .center
        secondLabel.textAlignment = .center
        
        view.addSubview(hourLabel)
        view.addSubview(minuteLabel)
        view.addSubview(secondLabel)
    }
    
    func setupButton() {
        view.addSubview(cancelButton)
        cancelButton.backgroundColor = .systemGray
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.layer.cornerRadius = 40
        cancelButton.clipsToBounds = true
        view.addSubview(startButton)
        startButton.backgroundColor = .systemBlue
        startButton.setTitle("시작", for: .normal)
        startButton.layer.cornerRadius = 40
        startButton.clipsToBounds = true
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
    }
    
    func setupConstraints() {
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
    
    //    @objc
    //    func startButtonTapped(_ sender: UIButton) {
    //        viewModel.startTimer()
    //        // Update UI if needed
    //    }
    
    //    @objc
    //    func pauseButtonTapped(_ sender: UIButton) {
    //        viewModel.pauseTimer()
    //        // Update UI if needed
    //    }
    
    //    @objc
    //    func stopButtonTapped(_ sender: UIButton) {
    //        viewModel.stopTimer()
    //        // Update UI if needed
    //    }
    
    // UIPickerViewDataSource and UIPickerViewDelegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0: return viewModel.hours.count
        case 1: return viewModel.minutes.count
        case 2: return viewModel.seconds.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = (pickerView.tag == 0 ? viewModel.hours[row] : (pickerView.tag == 1 ? viewModel.minutes[row] : viewModel.seconds[row]))
        return "\(value)"
    }
    
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct TimerViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TimerViewController {
        return TimerViewController()
    }
    
    func updateUIViewController(_ uiViewController: TimerViewController, context: Context) {
        // Update the view controller if necessary
    }
}

@available(iOS 13.0, *)
struct TimerViewControllerPreview_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            TimerViewControllerPreview()
                .edgesIgnoringSafeArea(.all) // Apply this to a SwiftUI view container
        }
    }
}
#endif






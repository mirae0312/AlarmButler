//
//  playSound.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/13/24.
//

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer!

func playSound(fileName: String) {
    guard let bundlePath = Bundle.main.path(forResource: fileName, ofType: "wav") else { return }
    let url = URL(fileURLWithPath: bundlePath)

    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    } catch {
        print("오디오 파일 재생 실패: \(error)")
    }
}


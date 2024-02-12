//
//  TimerSoundPlayer.swift
//  AlarmButler
//
//  Created by t2023-m0024 on 2/12/24.
//

import Foundation
import AVFoundation

var audioPlayer:AVAudioPlayer!
func playSound(fileName: String) {
    if(fileName == ""){
        return
    }
    guard let path = Bundle.main.path(forResource: fileName, ofType:"mp3") else {
            print("bundle error")
            return
    }
        let url = URL(fileURLWithPath: path)
    
    do{
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        
        guard let player = audioPlayer else {
            print("player load error")
            return
        }
        
        player.prepareToPlay()
        player.play()
    }catch{
        print("audio load error")
        print(error.localizedDescription)
    }
}

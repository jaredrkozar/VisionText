//
//  AudioManager.swift
//  VisionText
//
//  Created by Jared Kozar on 4/9/23.
//

import UIKit
import AVFoundation

enum AudioState {
    case notPlaying
    case playing
    case paused
    
    var icon: UIImage {
        switch self {
            case .paused, .notPlaying:
                return UIImage(systemName: "play.circle")!
            case .playing:
                return UIImage(systemName: "pause.circle")!
            default:
                return UIImage(systemName: "play.circle")!
        }
    }
    
    var text: String {
        switch self {
            case .paused:
                return "Resume"
            case .notPlaying:
                return "Speak Text"
            case .playing:
                return "Pause"
            default:
                return "Speak Text"
        }
    }
}

class AudioManager: AVSpeechSynthesizer, AVSpeechSynthesizerDelegate {
    
    var textToSpeak: String?
    
    let synthesizer = AVSpeechSynthesizer()
    
    var speed: Float = 0.5
    var pitch: Float = 1.0
    var volume: Float = 2.0
    var returnRange: ((_ range: NSRange)->())?
    
    init(text: String?) {
        super.init()
        synthesizer.delegate = self
        self.textToSpeak = text
    }
    
    func startSpeakingText() {
        let utterance = AVSpeechUtterance(string: textToSpeak!)
        utterance.rate = speed / 2
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func pauseText() {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    func continueSpeakingText() {
        synthesizer.continueSpeaking()
    }
    
    func stopSpeakingText() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        returnRange!(characterRange)
    }
}

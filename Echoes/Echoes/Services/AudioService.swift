//
//  AudioService.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import AVFoundation
import Observation


@Observable
final class AudioService {

    @ObservationIgnored private var audioRecorder: AVAudioRecorder?
    @ObservationIgnored private var audioPlayer: AVAudioPlayer?
    private(set) var recordedAudioURL: URL?

    init() {
        setupSession()
    }

    /// Returns the URL of the most recent recording, if any.
    func getRecordedAudioURL() -> URL? {
        recordedAudioURL
    }
    
    func setupSession() {
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
        
    }
    
    private func getRecordingURL() -> URL {
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                     in: .userDomainMask)[0]
        
        let fileName = UUID().uuidString + ".m4a"
        
        return documentsPath.appendingPathComponent(fileName)
    }
    
    func startRecording() {
        
        let audioURL = getRecordingURL()
        recordedAudioURL = audioURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioURL,
                                                settings: settings)
            
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            print("Recording started")
            print("File saved at: \(audioURL)")
            
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
        
    }
    
    func stopRecording() {
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        print("Recording stopped")
        
    }
    
    func playRecording(url: URL) {
        
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            print("Playback started")
            
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        print("Playback stopped")
        
    }
    
    
}


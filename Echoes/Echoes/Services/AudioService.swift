//
//  AudioService.swift
//  Echoes
//
//  Updated by Mikael Engvall on 2026-05-18.
//  Updated by Sara Lindén on 2026-06-03.
//

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

    func setupSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }

    // This should only be called from onboarding / permission flow.
    func requestMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    // This only checks permission. It does not trigger the system permission popup.
    var hasMicrophonePermission: Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }

    private func getRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let fileName = UUID().uuidString + ".m4a"
        return documentsPath.appendingPathComponent(fileName)
    }

    @discardableResult
    func startRecording() -> Bool {
        guard hasMicrophonePermission else {
            print("Microphone permission has not been granted.")
            return false
        }

        let audioURL = getRecordingURL()
        recordedAudioURL = audioURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(
                url: audioURL,
                settings: settings
            )

            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            print("Recording started")
            print("File saved at: \(audioURL)")
            return true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
            return false
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

    func getRecordedAudioURL() -> URL? {
        recordedAudioURL
    }
}

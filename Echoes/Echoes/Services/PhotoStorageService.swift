//
//  PhotoStorageService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import Foundation
import AVFoundation
import Photos

final class PhotoStorageService {

    func requestCameraPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func requestPhotoLibraryPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                let granted = status == .authorized || status == .limited
                continuation.resume(returning: granted)
            }
        }
    }
}

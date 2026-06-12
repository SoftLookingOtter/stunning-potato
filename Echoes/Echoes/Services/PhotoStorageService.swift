//
//  PhotoStorageService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-06-05.
//

import Foundation
import AVFoundation
import Photos
import UIKit

final class PhotoStorageService {

    private let imageDirectoryName = "EchoImages"

    // MARK: - Permissions

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

    // MARK: - Local image storage

    func saveImageData(_ data: Data) throws -> String {
        guard let image = UIImage(data: data) else {
            throw PhotoStorageError.invalidImageData
        }

        guard let jpegData = image.jpegData(compressionQuality: 0.82) else {
            throw PhotoStorageError.couldNotCreateJPEG
        }

        let directoryURL = try imageDirectoryURL()
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        try jpegData.write(to: fileURL, options: [.atomic])

        return fileName
    }

    func imageURL(for fileName: String) throws -> URL {
        let directoryURL = try imageDirectoryURL()
        return directoryURL.appendingPathComponent(fileName)
    }

    func loadImage(named fileName: String) -> UIImage? {
        do {
            let url = try imageURL(for: fileName)
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }

    func deleteImage(named fileName: String) {
        do {
            let url = try imageURL(for: fileName)

            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Could not delete image:", error.localizedDescription)
        }
    }

    private func imageDirectoryURL() throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directoryURL = documentsURL.appendingPathComponent(
            imageDirectoryName,
            isDirectory: true
        )

        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        return directoryURL
    }
}

enum PhotoStorageError: LocalizedError {
    case invalidImageData
    case couldNotCreateJPEG

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "The selected image could not be read."
        case .couldNotCreateJPEG:
            return "The selected image could not be saved."
        }
    }
}

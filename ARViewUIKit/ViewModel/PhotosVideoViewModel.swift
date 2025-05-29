//
//  PhotosVideoViewModel.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 22.04.25.
//

import UIKit
import Combine
import ARKit
import AVFoundation

//final class PhotosVideoViewModel {
//
//    // MARK: - Published Properties (for UI updates)
//
//    // Publishes the thumbnail image whenever it's updated
//    @Published private(set) var previewThumbnail: UIImage?
//    
//    // Publishes the recording state
//    @Published private(set) var isRecording: Bool = false
//    
//    // Publishes the content type (photo or video)
//    @Published private(set) var contentType: ContentType = .photo
//
//    // MARK: - Internal State
//
//    // Stores the full-resolution photo data
//    private(set) var capturedPhotoData: Data?
//    
//    // Stores the URL to the recorded video
//    private(set) var recordedVideoURL: URL?
//    
//    // Video recording properties
//    private var videoRecorder: ARVideoRecorder?
//
//    // MARK: - Types
//    
//    enum ContentType {
//        case photo
//        case video
//    }
//    
//    // MARK: - Public Methods
//
//    /// Call this from the ViewController after a snapshot is taken
//    func handleCapturedImage(_ image: UIImage) {
//        // Process on a background thread
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
//
//            let photoData = image.jpegData(compressionQuality: 0.8)
//            let thumbnail = self.generateThumbnail(for: image, targetSize: CGSize(width: 150, height: 200))
//
//            // Update state on the main thread, which triggers @Published properties
//            DispatchQueue.main.async {
//                self.contentType = .photo
//                self.capturedPhotoData = photoData
//                self.previewThumbnail = thumbnail
//                print("ViewModel updated previewThumbnail for photo.")
//            }
//        }
//    }
//    
//    /// Setup video recorder with ARSCNView
//    func setupVideoRecorder(for arView: ARSCNView) {
//        videoRecorder = ARVideoRecorder(arView: arView)
//    }
//
//    /// Toggles the recording state
//    func toggleRecording() {
//        isRecording.toggle()
//        
//        if isRecording {
//            startRecordingVideo()
//        } else {
//            stopRecordingVideo()
//        }
//        
//        print("ViewModel toggled isRecording to: \(isRecording)")
//    }
//    
//    /// Start video recording
//    private func startRecordingVideo() {
//        videoRecorder?.startRecording()
//    }
//    
//    /// Stop video recording and process the result
//    private func stopRecordingVideo() {
//        videoRecorder?.stopRecording { [weak self] videoURL in
//            guard let self = self, let url = videoURL else { return }
//            
//            // Store the video URL
//            self.recordedVideoURL = url
//            
//            // Generate thumbnail from the video
//            self.generateVideoThumbnail(from: url) { thumbnail in
//                DispatchQueue.main.async {
//                    self.contentType = .video
//                    self.previewThumbnail = thumbnail
//                    print("ViewModel updated previewThumbnail for video.")
//                }
//            }
//        }
//    }
//
//    /// Provides the full image if available
//    func getFullImage() -> UIImage? {
//        guard let data = capturedPhotoData else { return nil }
//        return UIImage(data: data)
//    }
//    
//    /// Provides the video URL if available
//    func getVideoURL() -> URL? {
//        return recordedVideoURL
//    }
//    
//    /// Returns the current content type
//    func getCurrentContentType() -> ContentType {
//        return contentType
//    }
//
//    // MARK: - Private Helpers (Thumbnail Generation)
//
//    private func generateThumbnail(for image: UIImage, targetSize: CGSize) -> UIImage? {
//        let size = image.size
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//        let scaleFactor = min(widthRatio, heightRatio)
//        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
//        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
//        let scaledImage = renderer.image { _ in
//            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
//        }
//        return scaledImage
//    }
//    
//    private func generateVideoThumbnail(from videoURL: URL, completion: @escaping (UIImage?) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            let asset = AVURLAsset(url: videoURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
//            
//            // Try to get thumbnail at the beginning of video
//            let time = CMTime(seconds: 0.5, preferredTimescale: 60)
//            
//            do {
//                let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
//                let resizedThumbnail = self.generateThumbnail(for: thumbnail, targetSize: CGSize(width: 150, height: 200))
//                completion(resizedThumbnail)
//            } catch {
//                print("Error generating video thumbnail: \(error)")
//                completion(nil)
//            }
//        }
//    }
//}

import AVFoundation
import UIKit
import SwiftUI
import Combine

#warning("--------------------------------------------")
// - TODO: - Replace ObservableObject with new macro
//         - Move file to another folder and write documentation
#warning("--------------------------------------------")

@MainActor
final class PhotosVideoViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var previewThumbnail: UIImage?
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var contentType: ContentType = .photo

    // MARK: - Internal State
    private(set) var capturedPhotoData: Data?
    private(set) var recordedVideoURL: URL?
    private var videoRecorder: ARVideoRecorder?

    // MARK: - Types
    enum ContentType {
        case photo
        case video
    }

    // MARK: - Public Methods

    func handleCapturedImage(_ image: UIImage) {
        Task {
            self.capturedPhotoData = image.jpegData(compressionQuality: 0.8)
            let thumbnail = await generateThumbnail(for: image, targetSize: CGSize(width: 150, height: 200))

            self.previewThumbnail = thumbnail
            self.contentType = .photo

            print("ViewModel updated previewThumbnail for photo.")
        }
    }

    func setupVideoRecorder(for arView: ARSCNView) {
        videoRecorder = ARVideoRecorder(arView: arView)
    }

    func toggleRecording() {
        Task {
            isRecording.toggle()
            print("ViewModel toggled isRecording to: \(isRecording)")

            if isRecording {
                videoRecorder?.startRecording()
            } else {
                if let url = await stopRecordingVideo() {
                    recordedVideoURL = url
                    let thumbnail = await generateVideoThumbnail(from: url)
                    previewThumbnail = thumbnail
                    contentType = .video
                    print("ViewModel updated previewThumbnail for video.")
                }
            }
        }
    }

    func getFullImage() -> UIImage? {
        guard let data = capturedPhotoData else { return nil }
        return UIImage(data: data)
    }

    func getVideoURL() -> URL? {
        return recordedVideoURL
    }

    func getCurrentContentType() -> ContentType {
        return contentType
    }

    // MARK: - Private Helpers

    private func stopRecordingVideo() async -> URL? {
        await withCheckedContinuation { continuation in
            videoRecorder?.stopRecording { url in
                continuation.resume(returning: url)
            }
        }
    }

    private func generateThumbnail(for image: UIImage, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let size = image.size
                let widthRatio = targetSize.width / size.width
                let heightRatio = targetSize.height / size.height
                let scaleFactor = min(widthRatio, heightRatio)
                let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

                let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
                let scaledImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
                }

                continuation.resume(returning: scaledImage)
            }
        }
    }

    private func generateVideoThumbnail(from videoURL: URL) async -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 0.5, preferredTimescale: 60)

        return await withCheckedContinuation { continuation in
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, result, error in
                guard result == .succeeded, let cgImage = cgImage else {
                    print("Error generating video thumbnail: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume(returning: nil)
                    return
                }

                Task {
                    let thumbnail = UIImage(cgImage: cgImage)
                    let resizedThumbnail = await MainActor.run {
                        self.syncGenerateThumbnail(for: thumbnail, targetSize: CGSize(width: 150, height: 200))
                    }
                    continuation.resume(returning: resizedThumbnail)
                }
            }
        }
    }
    
    private func syncGenerateThumbnail(for image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
    }
}


// MARK: - Video Recorder Class

class ARVideoRecorder: NSObject {
    // Reference to AR view for screen recording
    private weak var arView: ARSCNView?
    
    // Video writing components
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterAudioInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    // Recording state
    private var isRecording = false
    private var videoOutputURL: URL?
    private var recordingStartTime: TimeInterval = 0
    private var displayLink: CADisplayLink?
    
    // Audio components
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioTime: AVAudioTime?
    private var audioFile: AVAudioFile?
    
    // Completion handler
    private var completionHandler: ((URL?) -> Void)?
    
    // Initialize with AR view
    init(arView: ARSCNView) {
        self.arView = arView
        super.init()
    }
    
 
    func startRecording() {
        guard !isRecording, let arView = arView else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Prepare URL and asset writer...
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let videoName = "ARVideo_\(Date().timeIntervalSince1970).mov"
            self.videoOutputURL = documentsPath.appendingPathComponent(videoName)
            
            if FileManager.default.fileExists(atPath: self.videoOutputURL!.path) {
                try? FileManager.default.removeItem(at: self.videoOutputURL!)
            }
            
            do {
                self.assetWriter = try AVAssetWriter(outputURL: self.videoOutputURL!, fileType: .mov)
                DispatchQueue.main.async {
                    let videoSize = arView.bounds.size
                    
                    let videoSettings: [String: Any] = [
                        AVVideoCodecKey: AVVideoCodecType.h264,
                        AVVideoWidthKey: videoSize.width,
                        AVVideoHeightKey: videoSize.height
                    ]
                    
                    self.assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                    self.assetWriterVideoInput?.expectsMediaDataInRealTime = true
                    
                    let attributes: [String: Any] = [
                        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                        kCVPixelBufferWidthKey as String: videoSize.width,
                        kCVPixelBufferHeightKey as String: videoSize.height
                    ]
                    
                    self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                        assetWriterInput: self.assetWriterVideoInput!,
                        sourcePixelBufferAttributes: attributes
                    )
                    
                    if self.assetWriter!.canAdd(self.assetWriterVideoInput!) {
                        self.assetWriter!.add(self.assetWriterVideoInput!)
                    }
                    
                    self.assetWriter?.startWriting()
                    self.assetWriter?.startSession(atSourceTime: .zero)
                }
                
                DispatchQueue.main.async {
                    self.displayLink = CADisplayLink(target: self, selector: #selector(self.captureFrame))
                    self.displayLink?.add(to: .main, forMode: .common)
                    self.recordingStartTime = CACurrentMediaTime()
                    self.isRecording = true
                    print("Started recording video")
                }
                
            } catch {
                print("AssetWriter setup failed: \(error)")
                DispatchQueue.main.async {
                    self.completionHandler?(nil)
                }
            }
        }
    }

    
    // Stop recording method
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording, let writer = assetWriter else {
            completion(nil)
            return
        }
        
        completionHandler = completion
        
        // Invalidate display link
        displayLink?.invalidate()
        displayLink = nil
        
        // Finalize recording
        isRecording = false
        
        assetWriterVideoInput?.markAsFinished()
        // assetWriterAudioInput?.markAsFinished()  // Uncomment if using audio
        
        writer.finishWriting { [weak self] in
            guard let self = self else { return }
            
            if writer.status == .completed {
                print("DEBUG: Successfully finished writing video to: \(self.videoOutputURL?.path ?? "unknown")")
                DispatchQueue.main.async {
                    self.completionHandler?(self.videoOutputURL)
                }
            } else if let error = writer.error {
                print("DEBUG: Failed to finish writing with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.completionHandler?(nil)
                }
            }
            
            // Clean up
            self.assetWriter = nil
            self.assetWriterVideoInput = nil
            self.assetWriterAudioInput = nil
            self.pixelBufferAdaptor = nil
        }
    }
    
    // Capture frame method called by display link
    @objc private func captureFrame() {
        guard isRecording,
              let arView = arView,
              let _ = assetWriter,
              let videoInput = assetWriterVideoInput,
              let adaptor = pixelBufferAdaptor,
              videoInput.isReadyForMoreMediaData else {
            return
        }
        
        // Calculate current time
        let currentTime = CACurrentMediaTime()
        let frameTime = CMTime(seconds: currentTime - recordingStartTime, preferredTimescale: 600)
        
        // Take snapshot
        autoreleasepool {
            if let image = arView.snapshot().cgImage {
                let width = image.width
                let height = image.height
                
                var pixelBuffer: CVPixelBuffer?
                let status = CVPixelBufferCreate(
                    kCFAllocatorDefault,
                    width,
                    height,
                    kCVPixelFormatType_32ARGB,
                    nil,
                    &pixelBuffer
                )
                
                if status == kCVReturnSuccess, let pixelBuffer = pixelBuffer {
                    CVPixelBufferLockBaseAddress(pixelBuffer, [])
                    
                    let data = CVPixelBufferGetBaseAddress(pixelBuffer)
                    let context = CGContext(
                        data: data,
                        width: width,
                        height: height,
                        bitsPerComponent: 8,
                        bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                        space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                    )
                    
                    if let context = context {
                        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
                        if adaptor.append(pixelBuffer, withPresentationTime: frameTime) {
                            // Frame added successfully
                        } else {
                            print("DEBUG: Error appending pixel buffer at time \(frameTime)")
                        }
                    }
                    
                    CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
                }
            }
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension ARVideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("DEBUG: Error recording video: \(error)")
            completionHandler?(nil)
            return
        }
        
        // Save video to a more permanent location
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedURL = documentsDirectory.appendingPathComponent("arVideo_\(Date().timeIntervalSince1970).mov")
        
        do {
            try FileManager.default.moveItem(at: outputFileURL, to: savedURL)
            print("DEBUG: Video saved to \(savedURL)")
            completionHandler?(savedURL)
        } catch {
            print("DEBUG: Error saving video: \(error)")
            completionHandler?(nil)
        }
    }
}

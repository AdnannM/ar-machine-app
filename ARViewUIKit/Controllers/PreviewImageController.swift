//
//  PreviewImageController.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 14.04.25.
//

import UIKit
import AVKit
import Photos

class PreviewImageController: UIViewController {
    
    // MARK: - Public Properties
    
    var imageToShow: UIImage?
    var videoURLToShow: URL?
    var videoPreviewThumbnail: UIImage?
    
    // MARK: - Private Properties
    
    private let imageView = UIImageView()
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    private let thumbnailImageView = UIImageView()

    private lazy var closeButton = UIButton.makeActionButton(
        systemName: "xmark.circle.fill",
        target: self,
        action: #selector(closeButtonTapped)
    )
    private lazy var saveButton = UIButton.makeActionButton(
        systemName: "square.and.arrow.down",
        target: self,
        action: #selector(saveButtonTapped)
    )
    private lazy var shareButton = UIButton.makeActionButton(
        systemName: "square.and.arrow.up",
        target: self,
        action: #selector(shareButtonTapped)
    )
    
    // Custom video controls
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let videoContainer = UIView()
    
    // Flag to track content type
    private var isVideoContent: Bool {
        return videoURLToShow != nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        if isVideoContent {
            configureVideoPlayer()
        } else {
            configureImageView()
        }
        
        layoutViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainer.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop video playback if active
        
        player?.pause()
    }
    
    deinit {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        playerLayer?.removeFromSuperlayer()
        playerLayer = nil

        imageView.image = nil
    }
}

// MARK: - Setup UI

extension PreviewImageController {
    private func configureView() {
        view.backgroundColor = .black
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = imageToShow
    }
    
    private func configureVideoPlayer() {
        guard let videoURL = videoURLToShow else { return }
        
        // Configure the NEW thumbnail image view
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.backgroundColor = .clear
        thumbnailImageView.image = videoPreviewThumbnail
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isHidden = false
        
        // Configure video container
        videoContainer.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.backgroundColor = .clear
    
        // Create AVPlayer
        player = AVPlayer(url: videoURL)
        
        // Create player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        videoContainer.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        
        // Configure play button
        playButton.setImage(UIImage(systemName: "play.circle.fill")?.applyingSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 80)), for: .normal)
        
        // Add video completion observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    // MARK: - Layout
    
    private func layoutViews() {
        // Add common control buttons
        [closeButton, saveButton, shareButton].forEach {
            view.addSubview($0)
        }
        
        view.addSubview(thumbnailImageView)
        
        // Add content view based on type
        if isVideoContent {
            view.addSubview(videoContainer)
            view.addSubview(playButton)
            
            NSLayoutConstraint.activate([
                
                thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                thumbnailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                thumbnailImageView.topAnchor.constraint(equalTo: view.topAnchor),
                thumbnailImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                videoContainer.topAnchor.constraint(equalTo: view.topAnchor),
                videoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                playButton.widthAnchor.constraint(equalToConstant: 80),
                playButton.heightAnchor.constraint(equalToConstant: 80)
            ])
            
        } else {
            view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Layout common buttons
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            shareButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            
            saveButton.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            saveButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 10)
        ])
        
        // Ensure buttons are on top of content
        [closeButton, saveButton, shareButton].forEach {
            view.bringSubviewToFront($0)
        }
        
        if isVideoContent {
            view.bringSubviewToFront(playButton)
        }
    }
}

// MARK: - Video Control Actions

extension PreviewImageController {
    @objc private func playButtonTapped() {
        if player?.timeControlStatus == .playing {
            player?.pause()
            playButton.setImage(UIImage(systemName: "play.circle.fill")?.applyingSymbolConfiguration(
                UIImage.SymbolConfiguration(pointSize: 80)), for: .normal)
        } else {
            player?.play()
            
            // Hide play button during playback
            UIView.animate(withDuration: 0.3) {
                self.playButton.alpha = 0
            }
        }
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification) {
        // Reset player to beginning
        player?.seek(to: .zero)
        
        // Show replay button
        playButton.setImage(UIImage(systemName: "arrow.clockwise.circle.fill")?.applyingSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 80)), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.playButton.alpha = 1
        }
    }
}

// MARK: - Action

extension PreviewImageController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        if isVideoContent {
            saveVideo()
        } else {
            saveImage()
        }
    }
    
    @objc private func shareButtonTapped() {
        var itemsToShare: [Any] = []
        
        if let image = imageToShow {
            itemsToShare.append(image)
        } else if let videoURL = videoURLToShow {
            itemsToShare.append(videoURL)
        }
        
        guard !itemsToShare.isEmpty else { return }
        
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }
    
    // MARK: - Save Methods
    
    private func saveImage() {
        guard let image = imageToShow else { return }
        let alert = savingAlert()
        present(alert, animated: true)
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveFinished), nil)
    }
    
    private func saveVideo() {
        guard let videoURL = videoURLToShow else { return }
        let alert = savingAlert()
        present(alert, animated: true)
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                    } completionHandler: { success, error in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                if success {
                                    self.showAlert(title: "Saved", message: "Video was successfully saved to your Photos.")
                                } else {
                                    let errorMessage = error?.localizedDescription ?? "Unknown error"
                                    self.showAlert(title: "Error", message: errorMessage)
                                }
                            }
                        }
                    }
                } else {
                    self.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: "Permission denied to save to Photos.")
                    }
                }
            }
        }
    }
    
    @objc private func imageSaveFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        dismiss(animated: true) {
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Saved", message: "Image was successfully saved to your Photos.")
            }
        }
    }
}

// MARK: - Alert Helpers

extension PreviewImageController {
    private func savingAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Saving media...\n\n", preferredStyle: .alert)
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        alert.view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            spinner.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])
        
        return alert
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

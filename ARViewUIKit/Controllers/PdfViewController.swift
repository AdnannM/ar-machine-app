//
//  PdfViewController.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 18.04.25.
//

import UIKit
import PDFKit

class PdfViewController: UIViewController, PDFViewDelegate {
    
    // MARK: - Properties
    var pdfURL: URL?
    private var pdfView: PDFView?
    private var document: PDFDocument?
    private var loadingIndicator: UIActivityIndicatorView!
    private var pageLabel: UILabel!
    private var thumbnailView: PDFThumbnailView!
    private var controlsContainer: UIView!
    private var headerView: UIView!
    private var titleLabel: UILabel!
    private var isFullScreen = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupMemoryWarningObserver()
        
        Task {
            await loadAndDisplayPDF()
        }
    }
    
    deinit {
        cleanupResources()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            cleanupResources()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLoadingIndicator()
        setupHeader()
        setupControls()
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .darkGray
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loadingIndicator.startAnimating()
    }
    
    private func setupHeader() {
        // Create header container
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(headerView)
        
        // PDF title label
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.text = "Loading PDF..."
        headerView.addSubview(titleLabel)
        
        // Back button
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // Share button
        let shareButton = UIButton(type: .system)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        headerView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: shareButton.leadingAnchor, constant: -8),
            
            shareButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            shareButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupControls() {
        // Container for controls
        controlsContainer = UIView()
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(controlsContainer)
        
        // Page indicator label
        pageLabel = UILabel()
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.textColor = .white
        pageLabel.textAlignment = .center
        pageLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        controlsContainer.addSubview(pageLabel)
        
        // Full-screen button
        let fullScreenButton = UIButton(type: .system)
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        fullScreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        fullScreenButton.tintColor = .white
        fullScreenButton.addTarget(self, action: #selector(toggleFullScreen), for: .touchUpInside)
        controlsContainer.addSubview(fullScreenButton)
        
        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsContainer.heightAnchor.constraint(equalToConstant: 44),
            
            pageLabel.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            pageLabel.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            
            fullScreenButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -16),
            fullScreenButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            fullScreenButton.widthAnchor.constraint(equalToConstant: 44),
            fullScreenButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Initially hide controls until PDF is loaded
        controlsContainer.isHidden = true
    }
    
    private func setupThumbnailView(for pdfView: PDFView) {
        // Create thumbnail view
        thumbnailView = PDFThumbnailView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.pdfView = pdfView
        thumbnailView.layoutMode = .horizontal
        thumbnailView.thumbnailSize = CGSize(width: 40, height: 60)
        thumbnailView.backgroundColor = UIColor.systemGray6
        thumbnailView.layer.borderWidth = 0.5
        thumbnailView.layer.borderColor = UIColor.systemGray3.cgColor
        view.addSubview(thumbnailView)
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnailView.bottomAnchor.constraint(equalTo: controlsContainer.topAnchor),
            thumbnailView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    // MARK: - PDF Loading and Display
    private func cacheFileURL(for remoteURL: URL) -> URL {
        let fileName = remoteURL.lastPathComponent
        let cacheDirectory = FileManager.default.temporaryDirectory
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func loadAndDisplayPDF() async {
        guard let remoteURL = pdfURL else {
            loadingIndicator.stopAnimating()
            showErrorAlert(message: "No PDF URL provided")
            return
        }
        
        let localURL = cacheFileURL(for: remoteURL)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            await MainActor.run {
                displayPDF(from: localURL)
                updatePDFTitle(from: remoteURL)
            }
        } else {
            do {
                let (downloadedURL, _) = try await URLSession.shared.download(from: remoteURL)
                try FileManager.default.copyItem(at: downloadedURL, to: localURL)
                await MainActor.run {
                    displayPDF(from: localURL)
                    updatePDFTitle(from: remoteURL)
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    showErrorAlert(message: "Failed to download PDF: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updatePDFTitle(from url: URL) {
        // Extract and clean up the filename for display
        var filename = url.lastPathComponent
        if let range = filename.range(of: ".pdf", options: .caseInsensitive) {
            filename = String(filename[..<range.lowerBound])
        }
        filename = filename.replacingOccurrences(of: "%20", with: " ")
        titleLabel.text = filename
    }
    

    @MainActor
    private func displayPDF(from fileURL: URL) {
        // --- Create PDF view ---
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.delegate = self
        pdfView.displayMode = .singlePageContinuous // Or .singlePage
        pdfView.usePageViewController(true, withViewOptions: nil) // Better for swiping
        pdfView.pageShadowsEnabled = false
        pdfView.displayDirection = .horizontal // If using page curl like effect

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        pdfView.addGestureRecognizer(tapGesture)

        view.addSubview(pdfView)

        guard let headerView = self.headerView else {
            print("Error: HeaderView not initialized before displayPDF")
            // Handle this error appropriately, maybe show an alert
            loadingIndicator.stopAnimating()
            showErrorAlert(message: "UI Initialization Error")
            return
        }

       
        pdfView.removeConstraints(pdfView.constraints)

        let initialConstraints = [
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(initialConstraints)

        // --- Load document in background ---
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            guard let document = PDFDocument(url: fileURL) else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.showErrorAlert(message: "Failed to load PDF document")
                }
                return
            }

            // --- Back on Main Thread after Load ---
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Store references
                self.pdfView = pdfView
                self.document = document
                pdfView.document = document // Set document AFTER pdfView is configured

                self.loadingIndicator.stopAnimating()
                self.controlsContainer.isHidden = false // Show bottom controls
               
                self.updatePageLabel(pdfView) // Update page label immediately

                self.setupThumbnailView(for: pdfView)

                guard let thumbnailView = self.thumbnailView else {
                    print("DEBUG: Error: ThumbnailView setup failed.")
                    return
                }
                
                pdfView.bottomAnchor.constraint(equalTo: thumbnailView.topAnchor).isActive = true

                self.view.bringSubviewToFront(self.headerView)
                self.view.bringSubviewToFront(self.controlsContainer)
                self.view.bringSubviewToFront(thumbnailView) // Bring thumbnail view itself

                // --- Register for page change notifications ---
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(self.pageChanged(_:)),
                    name: Notification.Name.PDFViewPageChanged,
                    object: pdfView
                )
            }
        }
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func shareButtonTapped() {
        guard let pdfURL = document?.documentURL else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [pdfURL],
            applicationActivities: nil
        )
        
        // For iPad, set the popover presentation controller
        if let popover = activityViewController.popoverPresentationController {
            if let shareButton = headerView.subviews.last as? UIButton {
                popover.sourceView = shareButton
                popover.sourceRect = shareButton.bounds
            } else {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            }
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func pageChanged(_ notification: Notification) {
        if let pdfView = notification.object as? PDFView {
            updatePageLabel(pdfView)
        }
    }
    
    private func updatePageLabel(_ pdfView: PDFView) {
        guard let currentPage = pdfView.currentPage,
              let document = pdfView.document else { return }
        
        let currentPageIndex = document.index(for: currentPage) + 1
        let pageCount = document.pageCount
        pageLabel.text = "Page \(currentPageIndex) of \(pageCount)"
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // Toggle controls visibility with tap
        UIView.animate(withDuration: 0.3) {
            self.controlsContainer.isHidden.toggle()
            self.thumbnailView.isHidden = self.controlsContainer.isHidden
        }
    }
    
    @objc private func toggleFullScreen() {
        isFullScreen.toggle()
        
        if isFullScreen {
            navigationController?.setNavigationBarHidden(true, animated: true)
            tabBarController?.tabBar.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.controlsContainer.isHidden = true
                self.thumbnailView.isHidden = true
                self.headerView.isHidden = false
            }
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
            tabBarController?.tabBar.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.controlsContainer.isHidden = false
                self.thumbnailView.isHidden = false
                self.headerView.isHidden = false
            }
        }
    }
    
    @objc private func handleMemoryWarning() {
        // Clear non-essential resources on memory warning
        if let pdfView = self.pdfView, !isViewVisible() {
            pdfView.document = nil
            document = nil
        }
    }
    
    // MARK: - Helper Methods
    private func cleanupResources() {
        pdfView?.document = nil
        document = nil
    }
    
    private func isViewVisible() -> Bool {
        return isViewLoaded && view.window != nil
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - PDF Delegate
    private func pdfViewWillClick(onLink sender: PDFView, with url: URL) -> Bool {
        // Prevent automatic loading of linked resources
        return false
    }
    
    // MARK: - Cache Management
    static func clearCachedPDFs() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension.lowercased() == "pdf" {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("DEBUG: ⚠️ Cache clear failed: \(error.localizedDescription)")
        }
    }
}


// MARK: - Version 1 - worst on memory

//import UIKit
//import PDFKit
//
//class PdfViewController: UIViewController {
//
//    var pdfURL: URL?
//    private var pdfView: PDFView!
//    private let pageLabel = UILabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupTopControls()
//        Task {
//            await loadAndDisplayPDF()
//        }
//    }
//
//    private func setupTopControls() {
//        // Page label in the center
//        pageLabel.text = "Page: -"
//        pageLabel.textAlignment = .center
//        pageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//
//        // Close button
//        let closeButton = UIButton(type: .system)
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .label
//        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
//
//        // Share button
//        let shareButton = UIButton(type: .system)
//        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        shareButton.tintColor = .label
//        shareButton.addTarget(self, action: #selector(sharePDF), for: .touchUpInside)
//
//        // Stack for buttons
//        let buttonStack = UIStackView(arrangedSubviews: [closeButton, shareButton])
//        buttonStack.axis = .horizontal
//        buttonStack.spacing = 12
//
//        // Container view for top controls
//        let topBar = UIView()
//        topBar.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(topBar)
//
//        topBar.addSubview(pageLabel)
//        topBar.addSubview(buttonStack)
//        pageLabel.translatesAutoresizingMaskIntoConstraints = false
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            topBar.heightAnchor.constraint(equalToConstant: 44),
//
//            pageLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
//            pageLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
//
//            buttonStack.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
//            buttonStack.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
//        ])
//    }
//
//    private func cacheFileURL(for remoteURL: URL) -> URL {
//        let fileName = remoteURL.lastPathComponent
//        let cacheDirectory = FileManager.default.temporaryDirectory
//        return cacheDirectory.appendingPathComponent(fileName)
//    }
//
//    private func loadAndDisplayPDF() async {
//        guard let remoteURL = pdfURL else { return }
//
//        let localURL = cacheFileURL(for: remoteURL)
//
//        if FileManager.default.fileExists(atPath: localURL.path) {
//            displayPDF(from: localURL)
//        } else {
//            do {
//                let (downloadedURL, _) = try await URLSession.shared.download(from: remoteURL)
//                try FileManager.default.copyItem(at: downloadedURL, to: localURL)
//                displayPDF(from: localURL)
//            } catch {
//                print("❌ PDF download failed: \(error)")
//            }
//        }
//    }
//
//    @MainActor
//    private func displayPDF(from fileURL: URL) {
//        pdfView = PDFView()
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        pdfView.autoScales = true
//        pdfView.delegate = self
//        view.addSubview(pdfView)
//
//        NSLayoutConstraint.activate([
//            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
//            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        if let document = PDFDocument(url: fileURL) {
//            pdfView.document = document
//            updatePageNumber()
//            NotificationCenter.default.addObserver(
//                self,
//                selector: #selector(pageDidChange),
//                name: .PDFViewPageChanged,
//                object: pdfView
//            )
//        }
//    }
//
//    @objc private func pageDidChange() {
//        updatePageNumber()
//    }
//
//    private func updatePageNumber() {
//        guard let currentPage = pdfView.currentPage,
//              let document = pdfView.document,
//              let index = document.index(for: currentPage) as Int? else {
//            pageLabel.text = "Page: -"
//            return
//        }
//        pageLabel.text = "Page: \(index + 1)"
//    }
//
//    @objc private func dismissSelf() {
//        dismiss(animated: true)
//    }
//
//    @objc private func sharePDF() {
//        guard let documentURL = pdfURL else { return }
//        let activityVC = UIActivityViewController(activityItems: [documentURL], applicationActivities: nil)
//        present(activityVC, animated: true)
//    }
//}
//
//extension PdfViewController: PDFViewDelegate {}






// MARK: - Version 2

/// Displays a PDF document fetched from a URL within a custom view controller interface. It take more memory
///
/// This view controller presents a layout featuring:
/// - A main central `PDFView` area for displaying the PDF content.
/// - A vertical `PDFThumbnailView` on the left side, allowing users to preview pages and navigate the document.
/// - A persistent controls view positioned at the top-right containing Close and Share buttons.
///
/// **Scrolling Behavior:**
/// The main `PDFView` is configured with `displayMode = .singlePageContinuous`. This enables smooth, continuous vertical scrolling through the entire document, similar to a standard web page or document editor.
///
/// **Memory Consideration:**
/// While providing a fluid scrolling experience, the `.singlePageContinuous` display mode can consume significantly more memory compared to page-by-page modes (like `.singlePage`). This is because the `PDFView` may need to render or keep more page data readily available to ensure smooth scrolling. This effect can be more pronounced with very large or complex PDF documents.
///
/// **Fullscreen Mode:**
/// Tapping on the main `PDFView` area toggles a "fullscreen" mode. In this mode, the left thumbnail panel and the top-right controls fade out and collapse, allowing the `PDFView` content to expand and utilize the full screen width for a more immersive reading experience. Tapping again reverts to the standard layout.
///

//import UIKit
//import PDFKit
//
//class PdfViewController: UIViewController, PDFViewDelegate {
//
//    // MARK: - Properties
//    var pdfURL: URL?
//    private var pdfView: PDFView! // Make non-optional, setup in setupLayout
//    private var document: PDFDocument?
//    private var loadingIndicator: UIActivityIndicatorView!
//    private var thumbnailView: PDFThumbnailView! // Make non-optional
//    private var topControlsContainer: UIView!    // New
//    private var closeButton: UIButton!           // New
//    private var shareButton: UIButton!           // New
//
//    private var isFullScreen = false
//
//    // Constraints for animation
//    private var thumbnailWidthConstraint: NSLayoutConstraint?
//    private var pdfViewLeadingConstraint: NSLayoutConstraint?
//
//    private let thumbnailWidth: CGFloat = 80.0 // Adjust as needed
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .darkGray // Adjust background
//
//        // Ensure navigation bar is hidden if you are presenting this modally
//        // or managing UI fully custom. If pushed, manage in viewWillAppear/Disappear
//        navigationController?.isNavigationBarHidden = true
//
//        setupLoadingIndicator()
//        setupLayout() // New setup function
//        setupMemoryWarningObserver()
//
//        Task {
//            await loadAndDisplayPDF()
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Ensure nav bar stays hidden if needed
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        // Hide status bar if desired (especially for fullscreen later)
//        // setNeedsStatusBarAppearanceUpdate()
//    }
//
//    // Manage status bar visibility (optional)
////    override var prefersStatusBarHidden: Bool {
////        return isFullScreen
////    }
////
////    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
////        return .slide
////    }
//
//    deinit {
//        cleanupResources()
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if isMovingFromParent || isBeingDismissed {
//            cleanupResources()
//        }
//    }
//
//    // MARK: - UI Setup (New)
//    private func setupLayout() {
//        // --- Thumbnail View (Left Side) ---
//        thumbnailView = PDFThumbnailView()
//        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
//        thumbnailView.backgroundColor = UIColor.systemGray5 // Example color
//        thumbnailView.layoutMode = .vertical // Vertical scroll
//        thumbnailView.thumbnailSize = CGSize(width: thumbnailWidth - 20, height: (thumbnailWidth - 20) * 1.4) // Adjust aspect ratio
//        view.addSubview(thumbnailView)
//
//        // --- PDF View (Main Area) ---
//        pdfView = PDFView()
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        pdfView.autoScales = true
//        pdfView.displayMode = .singlePageContinuous // Vertical scroll
//        pdfView.backgroundColor = UIColor.lightGray // Example color
//        pdfView.delegate = self
//        view.addSubview(pdfView)
//
//        // Add tap gesture for fullscreen toggle
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        pdfView.addGestureRecognizer(tapGesture)
//
//        // --- Top Controls (Top Right) ---
//        topControlsContainer = UIView()
//        topControlsContainer.translatesAutoresizingMaskIntoConstraints = false
//        // topControlsContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Optional background
//        view.addSubview(topControlsContainer)
//
//        closeButton = UIButton(type: .system)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .white
//        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
//        topControlsContainer.addSubview(closeButton)
//
//        shareButton = UIButton(type: .system)
//        shareButton.translatesAutoresizingMaskIntoConstraints = false
//        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        shareButton.tintColor = .white
//        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
//        topControlsContainer.addSubview(shareButton)
//
//        // --- Constraints ---
//        let safeArea = view.safeAreaLayoutGuide
//
//        // Store constraints needed for animation
//        thumbnailWidthConstraint = thumbnailView.widthAnchor.constraint(equalToConstant: thumbnailWidth)
//        pdfViewLeadingConstraint = pdfView.leadingAnchor.constraint(equalTo: thumbnailView.trailingAnchor)
//
//        NSLayoutConstraint.activate([
//            // Thumbnail View
//            thumbnailView.topAnchor.constraint(equalTo: safeArea.topAnchor),
//            thumbnailView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Stretch to bottom
//            thumbnailView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
//            thumbnailWidthConstraint!, // Activate stored width constraint
//
//            // PDF View
//            pdfView.topAnchor.constraint(equalTo: safeArea.topAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Stretch to bottom
//            pdfViewLeadingConstraint!, // Activate stored leading constraint
//            pdfView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
//
//            // Top Controls Container (Positioned Top-Right)
//            topControlsContainer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
//            topControlsContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
//
//            // Close Button (Inside Top Controls)
//            closeButton.topAnchor.constraint(equalTo: topControlsContainer.topAnchor),
//            closeButton.leadingAnchor.constraint(equalTo: topControlsContainer.leadingAnchor),
//            closeButton.bottomAnchor.constraint(equalTo: topControlsContainer.bottomAnchor),
//            closeButton.widthAnchor.constraint(equalToConstant: 44),
//            closeButton.heightAnchor.constraint(equalToConstant: 44),
//
//            // Share Button (Inside Top Controls, to the right of Close)
//            shareButton.topAnchor.constraint(equalTo: topControlsContainer.topAnchor),
//            shareButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
//            shareButton.trailingAnchor.constraint(equalTo: topControlsContainer.trailingAnchor),
//            shareButton.bottomAnchor.constraint(equalTo: topControlsContainer.bottomAnchor),
//            shareButton.widthAnchor.constraint(equalToConstant: 44),
//            shareButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//
//        // Ensure top controls are above PDF view
//        view.bringSubviewToFront(topControlsContainer)
//    }
//
//
//    private func setupMemoryWarningObserver() {
//        // ... (same as before)
//    }
//
//    private func setupLoadingIndicator() {
//        // ... (same as before, but maybe bring it to front initially)
////        view.addSubview(loadingIndicator) // Add first
////        NSLayoutConstraint.activate([
////             loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
////             loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
////         ])
////        view.bringSubviewToFront(loadingIndicator) // Make sure it's visible
////        loadingIndicator.startAnimating()
//    }
//
//    // MARK: - PDF Loading and Display
//     private func cacheFileURL(for remoteURL: URL) -> URL {
//         let fileName = remoteURL.lastPathComponent
//                 let cacheDirectory = FileManager.default.temporaryDirectory
//                 return cacheDirectory.appendingPathComponent(fileName)
//     }
//
//     private func loadAndDisplayPDF() async {
//          guard let remoteURL = pdfURL else {
//              // ... error handling ...
//              return
//          }
//          let localURL = cacheFileURL(for: remoteURL)
//
//          // ... download/cache logic (same as before) ...
//            if FileManager.default.fileExists(atPath: localURL.path) {
//                await MainActor.run { displayPDF(from: localURL) }
//            } else {
//                // Download logic... then displayPDF
//                 do {
//                     let (downloadedURL, _) = try await URLSession.shared.download(from: remoteURL)
//                     try FileManager.default.copyItem(at: downloadedURL, to: localURL)
//                     await MainActor.run { displayPDF(from: localURL) }
//                 } catch {
//                      await MainActor.run {
//                          self.loadingIndicator.stopAnimating()
//                          self.showErrorAlert(message: "Failed to download PDF: \(error.localizedDescription)")
//                      }
//                 }
//            }
//     }
//
//    @MainActor
//    private func displayPDF(from fileURL: URL) {
//        // Load document in background (optional, but good practice)
//        Task(priority: .userInitiated) {
//            guard let document = PDFDocument(url: fileURL) else {
//                // Run UI updates on the main thread
//                await MainActor.run {
//                    self.loadingIndicator.stopAnimating()
//                    self.showErrorAlert(message: "Failed to load PDF document")
//                }
//                return
//            }
//
//            // Run UI updates on the main thread
//            await MainActor.run {
//                self.document = document
//                self.pdfView.document = document
//                self.thumbnailView.pdfView = self.pdfView // Link thumbnail view
//
////                self.loadingIndicator.stopAnimating()
//
//                // No controls container or page label to show/update anymore
//            }
//        }
//    }
//
//
//    // MARK: - Actions
//    @objc private func closeButtonTapped() { // Renamed from backButtonTapped
//        // Choose appropriate dismiss/pop based on how VC was presented
//         if let navController = navigationController {
//             navController.popViewController(animated: true)
//         } else {
//             dismiss(animated: true, completion: nil)
//         }
//    }
//
//    @objc private func shareButtonTapped() {
//        guard let pdfURL = document?.documentURL else {
//            showErrorAlert(message: "PDF document not available for sharing.")
//            return
//        }
//
//        let activityViewController = UIActivityViewController(
//            activityItems: [pdfURL],
//            applicationActivities: nil
//        )
//
//        // Popover for iPad
//        if let popover = activityViewController.popoverPresentationController {
//            // Anchor to the new share button
//            popover.sourceView = shareButton
//            popover.sourceRect = shareButton.bounds
//            popover.permittedArrowDirections = .up // Adjust arrow direction
//        }
//
//        present(activityViewController, animated: true)
//    }
//
//    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//        // Tap on PDF view toggles fullscreen
//        toggleFullScreen()
//    }
//
//    @objc private func toggleFullScreen() {
//        isFullScreen.toggle()
//       // setNeedsStatusBarAppearanceUpdate() // Update status bar visibility if managing it
//
//        let targetThumbnailWidth: CGFloat = isFullScreen ? 0 : thumbnailWidth
//        let targetPdfLeadingConstant: CGFloat = isFullScreen ? 0 : thumbnailWidth // Should match thumbnail area
//        let targetAlpha: CGFloat = isFullScreen ? 0 : 1 // Fade out controls
//
//        // Animate changes
//        view.layoutIfNeeded() // Ensure current layout is stable before animating
//        UIView.animate(withDuration: 0.3, animations: {
//            // Animate constraints
//            self.thumbnailWidthConstraint?.constant = targetThumbnailWidth
//            // Adjust PDF view's leading constraint - IMPORTANT: Activate/Deactivate or change constant
//            // If just changing constant, ensure the constraint connects to the correct anchor initially (e.g., view.leadingAnchor if thumbnail hidden)
//            // Simpler approach: Modify the constant of the constraint connecting pdfView to thumbnailView's trailing OR view's leading.
//            // Let's assume pdfViewLeadingConstraint always connects pdfView.leading to thumbnailView.trailing
//            // This might require more complex constraint management.
//
//            // --- Easier Constraint Animation ---
//            // Deactivate the constraint pinning pdfView to thumbnailView
//             self.pdfViewLeadingConstraint?.isActive = false
//
//            if self.isFullScreen {
//                 // Create and activate new constraint pinning pdfView to the screen edge
//                self.pdfViewLeadingConstraint = self.pdfView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
//             } else {
//                 // Create and activate new constraint pinning pdfView back to the thumbnail view
//                 self.pdfViewLeadingConstraint = self.pdfView.leadingAnchor.constraint(equalTo: self.thumbnailView.trailingAnchor)
//             }
//            self.pdfViewLeadingConstraint?.isActive = true
//             // --- End Easier Constraint Animation ---
//
//
//            // Fade controls
//            self.topControlsContainer.alpha = targetAlpha
//            self.thumbnailView.alpha = targetAlpha // Also fade thumbnail smoothly
//
//            // Trigger layout update within animation block
//            self.view.layoutIfNeeded()
//        }) { completed in
//             // Optional: You might fully hide views after animation for performance
//             // self.thumbnailView.isHidden = self.isFullScreen
//            // self.topControlsContainer.isHidden = self.isFullScreen
//        }
//    }
//
//
//    @objc private func handleMemoryWarning() {
//        // ... (same as before)
//    }
//
//    // MARK: - Helper Methods
//    private func cleanupResources() {
//        // ... (same as before)
//    }
//
//    private func isViewVisible() -> Bool {
//        return isViewLoaded && view.window != nil
//    }
//
//    private func showErrorAlert(message: String) {
//        // ... (same as before)
//    }
//
//    // MARK: - PDF Delegate
//    private func pdfViewWillClick(onLink sender: PDFView, with url: URL) -> Bool {
//        // ... (same as before)
//        return false
//    }
//}

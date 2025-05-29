//
//  ARDisplayView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

import ARKit
import UIKit

//class ARDisplayView: UIView {
//
//    // MARK: - Properties
//    var arView: ARSCNView!
//    private var logLabel: UILabel!
//    private let configuration = ARWorldTrackingConfiguration()
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//        setupViews()
//        setupLayout()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Setup
//    private func setupViews() {
//
//        // TODO --- Add Basic Lighting (Because autoenablesDefaultLighting is false) ---
//
//        // Initialize ARSCNView with optimized settings
//        arView = ARSCNView()
//        arView.translatesAutoresizingMaskIntoConstraints = false
//        arView.automaticallyUpdatesLighting = false
//        arView.autoenablesDefaultLighting = false  // Disable default lighting
//        arView.preferredFramesPerSecond = 30  // Lower frame rate
//        arView.scene.isPaused = true  // Start paused
//        addSubview(arView)
//
//        // Initialize log label
//        logLabel = UILabel()
//        logLabel.translatesAutoresizingMaskIntoConstraints = false
//        logLabel.textColor = .white
//        logLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        logLabel.numberOfLines = 0
//        logLabel.textAlignment = .center
//        logLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        logLabel.layer.cornerRadius = 8
//        logLabel.layer.masksToBounds = true
//        logLabel.alpha = 0
//        addSubview(logLabel)
//    }
//
//    private func setupLayout() {
//        NSLayoutConstraint.activate([
//            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            arView.topAnchor.constraint(equalTo: topAnchor),
//            arView.bottomAnchor.constraint(equalTo: bottomAnchor),
//
//            logLabel.topAnchor.constraint(
//                equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
//            logLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            logLabel.widthAnchor.constraint(
//                lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
//        ])
//    }
//}
//
//// MARK: - Session Handling
//extension ARDisplayView {
//    
//    func setupSession() {
//        guard ARWorldTrackingConfiguration.isSupported else {
//            showLog("❌ ARKit is not supported.")
//            return
//        }
//
//        let configuration = ARWorldTrackingConfiguration()
//
//        if #available(iOS 12.0, *) {
//            configuration.environmentTexturing = .automatic
//        } else {
//            // Fallback on earlier versions
//        }
//
//        checkCameraPermissions { [weak self] granted in
//            guard let self = self, granted else { return }
//
//            // Configure AR session
//            self.configuration.planeDetection = [.horizontal, .vertical]
//            self.configuration.environmentTexturing = .none
//            self.configuration.worldAlignment = .gravity
//            self.configuration.frameSemantics = []
//
//            // Make sure scene is not paused
//            self.arView.scene.isPaused = false
//
//            // Run with clear reset options
//            self.arView.session.run(
//                self.configuration,
//                options: [.resetTracking, .removeExistingAnchors])
//
//            // Add a slight delay before showing success message
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.showLog("✅ AR Session started.")
//            }
//        }
//    }
//
//    func stopSession() {
//        arView.scene.isPaused = true
//        arView.session.pause()
//        showLog("🛑 AR Session stopped.")
//    }
//
//    // Add resource cleanup method
//    func cleanupResources() {
//        // Remove all nodes added to the scene except the camera and lights
//        arView.scene.rootNode.childNodes.forEach { node in
//            if node.light == nil && node.camera == nil {
//                node.removeFromParentNode()
//            }
//        }
//        // cleanup here (textures, etc.)
//    }
//
//    func checkCameraPermissions(completion: @escaping (Bool) -> Void) {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            completion(true)
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    completion(granted)
//                }
//            }
//        case .denied, .restricted:
//            showLog("⚠️ Camera access denied", duration: 5.0)
//            completion(false)
//        @unknown default:
//            completion(false)
//        }
//    }
//}
//
//// MARK: - Logging Utility
//
//extension ARDisplayView {
//    func showLog(_ message: String, duration: TimeInterval = 2.5) {
//        logLabel.text = message
//        logLabel.alpha = 1
//
//        UIView.animate(
//            withDuration: 0.3, delay: duration, options: [.curveEaseOut]
//        ) { [weak self] in
//            self?.logLabel.alpha = 0
//        }
//    }
//}
//
//// MARK: - ARSCNView
//
//extension ARSCNView {
//    func getRaycastQuery() -> ARRaycastQuery? {
//        guard session.currentFrame != nil else { return nil }
//
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        return raycastQuery(
//            from: center, allowing: .estimatedPlane, alignment: .any)
//    }
//
//    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
//        return session.raycast(query)
//    }
//}
//

//import ARKit
//import UIKit
//
//class ARDisplayView: UIView {
//
//    // MARK: - Properties
//    var arView: ARSCNView!
//    private var logLabel: UILabel!
//    private let configuration = ARWorldTrackingConfiguration()
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//        setupViews()
//        setupLayout()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - View Setup
//    private func setupViews() {
//
//        // Initialize ARSCNView with performance-friendly settings
//        arView = ARSCNView()
//        arView.translatesAutoresizingMaskIntoConstraints = false
//        arView.automaticallyUpdatesLighting = false
//        arView.autoenablesDefaultLighting  = false
//        arView.preferredFramesPerSecond    = 30
//        arView.scene.isPaused              = true   // will un-pause on startSession()
//        addSubview(arView)
//
//        // HUD / log label
//        logLabel = UILabel()
//        logLabel.translatesAutoresizingMaskIntoConstraints = false
//        logLabel.textColor       = .white
//        logLabel.font            = .systemFont(ofSize: 12, weight: .medium)
//        logLabel.numberOfLines   = 0
//        logLabel.textAlignment   = .center
//        logLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//        logLabel.layer.cornerRadius = 8
//        logLabel.layer.masksToBounds = true
//        logLabel.alpha = 0
//        addSubview(logLabel)
//    }
//
//    private func setupLayout() {
//        NSLayoutConstraint.activate([
//            arView.leadingAnchor .constraint(equalTo: leadingAnchor),
//            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            arView.topAnchor     .constraint(equalTo: topAnchor),
//            arView.bottomAnchor  .constraint(equalTo: bottomAnchor),
//
//            logLabel.topAnchor   .constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
//            logLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            logLabel.widthAnchor .constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9)
//        ])
//    }
//}
//
//// MARK: - Session Handling
//extension ARDisplayView {
//
//    /// Call **once** when the AR scene is first shown.
//    func startSession() {
//        guard ARWorldTrackingConfiguration.isSupported else {
//            showLog("❌ ARKit not supported.")
//            return
//        }
//
//        configureTrackingOptions()
//        checkCameraPermissions { [weak self] granted in
//            guard let self = self, granted else { return }
//            self.runSession(options: [.resetTracking, .removeExistingAnchors])
//            self.showLog("✅ AR Session started.")
//            print("DEBUG: AR Session started.")
//        }
//    }
//
//    /// Call when the app returns from background – keeps anchors & world map.
//    func resumeSession() {
//        runSession(options: [])   // no reset
//    }
//
//    /// Call when app goes to background.
//    func pauseSession() {
//        arView.session.pause()
//        arView.scene.isPaused = true
//    }
//
//    // MARK: - Private helpers
//    private func configureTrackingOptions() {
//        configuration.planeDetection        = [.horizontal, .vertical]
//        configuration.environmentTexturing  = .none
//        configuration.worldAlignment        = .gravity
//        configuration.frameSemantics        = []
//    }
//
//    private func runSession(options: ARSession.RunOptions) {
//        arView.scene.isPaused = false
//        arView.session.run(configuration, options: options)
//    }
//}
//
//// MARK: - Resource & Permission helpers
//extension ARDisplayView {
//
//    /// Remove all non-camera / non-light nodes
//    func cleanupResources() {
//        arView.scene.rootNode.childNodes.forEach { node in
//            if node.light == nil && node.camera == nil {
//                node.removeFromParentNode()
//            }
//        }
//    }
//
//    private func checkCameraPermissions(_ completion: @escaping (Bool) -> Void) {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:          completion(true)
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async { completion(granted) }
//            }
//        default:
//            showLog("⚠️ Camera access denied", duration: 5.0)
//            completion(false)
//        }
//    }
//}
//
//// MARK: - Logging utility
//extension ARDisplayView {
//
//    func showLog(_ message: String, duration: TimeInterval = 2.5) {
//        logLabel.text  = message
//        logLabel.alpha = 1
//
//        UIView.animate(withDuration: 0.3,
//                       delay: duration,
//                       options: [.curveEaseOut]) { [weak self] in
//            self?.logLabel.alpha = 0
//        }
//    }
//}
//
//// MARK: - ARSCNView convenience
//extension ARSCNView {
//    func getRaycastQuery() -> ARRaycastQuery? {
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        return raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
//    }
//    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] { session.raycast(query) }
//}



import ARKit
import UIKit

// =============================================================
//  MARK: – ARDisplayView
// =============================================================
class ARDisplayView: UIView {

    // -------------------------------
    //  PUBLIC PROPERTIES
    // -------------------------------
    var arView: ARSCNView!

    private var logLabel: UILabel!

    private let configuration = ARWorldTrackingConfiguration()

    // -------------------------------
    //  INITIALISATION
    // -------------------------------
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // -------------------------------
    //  PRIVATE HELPERS
    // -------------------------------
    private func setupViews() {
        arView = ARSCNView()
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.automaticallyUpdatesLighting = false
        arView.autoenablesDefaultLighting  = false
        arView.preferredFramesPerSecond    = 30
        arView.scene.isPaused              = true
        addSubview(arView)

        logLabel = UILabel()
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        logLabel.textColor       = .white
        logLabel.font            = .systemFont(ofSize: 12, weight: .medium)
        logLabel.numberOfLines   = 0
        logLabel.textAlignment   = .center
        logLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        logLabel.layer.cornerRadius = 8
        logLabel.layer.masksToBounds = true
        logLabel.alpha = 0
        addSubview(logLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            arView.leadingAnchor .constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.topAnchor     .constraint(equalTo: topAnchor),
            arView.bottomAnchor  .constraint(equalTo: bottomAnchor),

            logLabel.topAnchor   .constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            logLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            logLabel.widthAnchor .constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9)
        ])
    }
}

// =============================================================
//  MARK: – Session Handling
// =============================================================
extension ARDisplayView {

    func startSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            showLog("❌ ARKit not supported.")
            return
        }

        configureTrackingOptions()
        checkCameraPermissions { [weak self] granted in
            guard let self = self, granted else { return }
            self.runSession(options: [.resetTracking, .removeExistingAnchors])
            self.showLog("✅ AR Session started.")
            #if DEBUG
            print("DEBUG: AR Session started.")
            #endif
        }
    }

    func resumeSession() {
        runSession(options: [])
    }

    func pauseSession() {
        arView.session.pause()
        arView.scene.isPaused = true
    }

    // -------------------------------
    //  PRIVATE HELPERS
    // -------------------------------
    private func configureTrackingOptions() {
        configuration.planeDetection        = [.horizontal, .vertical]
        configuration.environmentTexturing  = .none
        configuration.worldAlignment        = .gravity
        configuration.frameSemantics        = []
    }

    private func runSession(options: ARSession.RunOptions) {
        arView.scene.isPaused = false
        arView.session.run(configuration, options: options)
    }
}

// =============================================================
//  MARK: – Resource & Permission Helpers
// =============================================================
extension ARDisplayView {

    func cleanupResources() {
        #if DEBUG
        print("DEBUG: Cleaning up non-camera/light nodes…")
        #endif
        arView.scene.rootNode.childNodes.forEach { node in
            if node.light == nil && node.camera == nil {
                node.removeFromParentNode()
            }
        }
    }

    // -------------------------------
    //  PRIVATE HELPERS
    // -------------------------------
    private func checkCameraPermissions(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            showLog("⚠️ Camera access denied", duration: 5.0)
            completion(false)
        }
    }
}

// =============================================================
//  MARK: – Logging Utility
// =============================================================
extension ARDisplayView {
    
    func showLog(_ message: String, duration: TimeInterval = 2.5) {
        logLabel.text  = message
        logLabel.alpha = 1

        UIView.animate(withDuration: 0.3,
                       delay: duration,
                       options: [.curveEaseOut]) { [weak self] in
            self?.logLabel.alpha = 0
        }
    }
}

// =============================================================
//  MARK: – ARSCNView Convenience
// =============================================================
extension ARSCNView {

    func getRaycastQuery() -> ARRaycastQuery? {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return raycastQuery(from: center, allowing: .estimatedPlane, alignment: .any)
    }

    func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
        session.raycast(query)
    }
}

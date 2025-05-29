//
//  ARViewController+ARSessionDelegate.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 28.04.25.
//

/*
     Abstract:
         This extension makes ARViewController conform to ARSessionDelegate.
         It manages session errors, interruptions, relocalization, and camera tracking state
         changes to ensure a smooth AR experience.
*/

import ARKit
import os.log

extension ARViewController: ARSessionDelegate {

    func session(_ session: ARSession, didFailWithError error: Error) {
        os_log("AR Session Error: %{public}@", log: .default, type: .error, error.localizedDescription)
        DispatchQueue.main.async { [weak self] in
            self?.arDisplayView.showLog("❌ Session Error", duration: 3.0)
            self?.handleSessionFailure(with: error)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        os_log("AR Session Interrupted", log: .default, type: .info)
        DispatchQueue.main.async { [weak self] in
            self?.arDisplayView.showLog("⏸️ Session Paused", duration: 2.0)
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        os_log("AR Session Interruption Ended", log: .default, type: .info)
        DispatchQueue.main.async { [weak self] in
            self?.arDisplayView.showLog("▶️ Session Resumed", duration: 2.0)
            self?.arDisplayView.resumeSession()      // ← use new helper
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        let statusMessage: String
        switch camera.trackingState {
        case .normal: statusMessage = "✅ Tracking Normal"
        case .limited(let reason):
            switch reason {
            case .initializing:          statusMessage = "⏳ Initializing AR"
            case .excessiveMotion:       statusMessage = "🔄 Slow Down Movement"
            case .insufficientFeatures:  statusMessage = "📱 Point at Surface"
            case .relocalizing:          statusMessage = "🔄 Recovering Session"
            @unknown default:            statusMessage = "⚠️ Limited Tracking"
            }
        case .notAvailable: statusMessage = "❌ Tracking Unavailable"
        @unknown default:   statusMessage = "⚠️ Unknown Tracking State"
        }
        DispatchQueue.main.async { [weak self] in
            self?.arDisplayView.showLog(statusMessage, duration: 2.0)
        }
    }

    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool { true }

    private func handleSessionFailure(with error: Error) {
        if let arError = error as? ARError {
            switch arError.code {
            case .cameraUnauthorized:
                os_log("Camera access denied", log: .default, type: .error)
            case .sensorUnavailable, .sensorFailed:
                os_log("AR sensors unavailable", log: .default, type: .error)
            default: break
            }
        }
    }
}

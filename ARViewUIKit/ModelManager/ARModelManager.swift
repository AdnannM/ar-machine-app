//
//  Untitled.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 09.05.25.
//

import ARKit
import Combine
import SceneKit
import OSLog

// =============================================================
//  MARK: – ARModelManager
// =============================================================
final class ARModelManager {

    // -------------------------------
    //  PRIVATE DEPENDENCIES
    // -------------------------------
    private weak var arView: ARSCNView?
    private weak var arDisplayView: ARDisplayView?
    private var focusSquare: SCNNode?

    var highlightedParts: [SCNNode: Bool] = [:]

    // -------------------------------
    //  PROGRESS PUBLISHER
    // -------------------------------
    private let loadingProgressSubject = PassthroughSubject<
        (String, Float), Never
    >()
    var loadingProgressPublisher: AnyPublisher<(String, Float), Never> {
        loadingProgressSubject.eraseToAnyPublisher()
    }

    // -------------------------------
    //  INITIALISATION
    // -------------------------------
    init(arView: ARSCNView, arDisplayView: ARDisplayView, focusSquare: SCNNode?)
    {
        self.arView = arView
        self.arDisplayView = arDisplayView
        self.focusSquare = focusSquare
        setupBasicLighting()
    }

    // -------------------------------
    //  LOAD MODEL (ASYNC)
    // -------------------------------
    @MainActor                // keep UI calls on the main actor
    func loadModel(named modelName: String, title: String) async throws -> SCNNode {

        // ── 1. Resolve the file URL ────────────────────────────────────────────────
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "usdz") else {
            arDisplayView?.showLog("❌ Model \(modelName) not found.")
            throw CocoaError(.fileNoSuchFile)
        }

        // ── 2. Kick-off progress & log ─────────────────────────────────────────────
        loadingProgressSubject.send((title, 0.0))
        Logger(subsystem: "ARModelManager", category: "ModelLoading")
            .debug("DEBUG: Started loading “\(modelName).usdz”")

        // ── 3. Perform the heavy work in a cooperative background task ────────────
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: CancellationError())
                    return
                }

                // 3-a. Instantiate the reference node
                guard let refNode = SCNReferenceNode(url: url) else {
                    continuation.resume(throwing: CocoaError(.coderInvalidValue))
                    return
                }

                // 3-b. Simulated incremental progress (replace with real progress later)
                for step in 1...4 {
                    try await Task.sleep(nanoseconds: 100_000_000)      // 0.1 s
                    let pct = Float(step) * 0.2                          // 20 % per tick
                    await MainActor.run { [weak self] in
                        self?.loadingProgressSubject.send((title, pct))
                    }
                }

                // 3-c. Load scene content (blocking SceneKit call)
                refNode.load()

                // 3-d. Finalise on the main actor
                await MainActor.run { [weak self] in
                    refNode.name = modelName
                    self?.loadingProgressSubject.send((title, 1.0))
                    Logger(subsystem: "ARModelManager", category: "ModelLoading")
                        .debug("DEBUG: Finished loading “\(modelName).usdz”")
                    continuation.resume(returning: refNode)
                }
            }
        }
    }

    

    // -------------------------------
    //  PLACE MODEL
    // -------------------------------
    /// Attempts to place the node on a detected surface, falling back to
    /// directly in front of the camera.
    func placeModel(_ modelNode: SCNNode, title: String) -> Bool {
        guard let arView = arView else { return false }

        // Define scale based on model type
        let isObjectModel = ["Arrow", "Pin", "Warning"].contains(title)
        let standardScale: SCNVector3

        if isObjectModel {
            // Objects need larger scale
            standardScale = SCNVector3(0.03, 0.03, 0.03)
            print(standardScale)
        } else {
            // Machines use smaller scale
            standardScale = SCNVector3(0.002, 0.002, 0.003)
        }

        // Try to place using raycast
        if let raycastQuery = arView.getRaycastQuery(),
            let result = arView.castRay(for: raycastQuery).first
        {
            modelNode.transform = SCNMatrix4(result.worldTransform)
            modelNode.scale = standardScale  // Use standardized scale

            arView.scene.rootNode.addChildNode(modelNode)
            arDisplayView?.showLog("✅ \(title) placed on surface.")
            focusSquare?.isHidden = true

            // Debug output
            print("DEBUG: 📏 \(title) placed with scale: \(standardScale)")
            return true
        }

        // Fallback: position in front of camera
        if let defaultPosition = getPositionInFrontOfCamera(distance: 0.3) {
            modelNode.position = defaultPosition
            modelNode.scale = standardScale  // Use standardized scale

            if let pov = arView.pointOfView {
                modelNode.eulerAngles.y = pov.eulerAngles.y
            }

            arView.scene.rootNode.addChildNode(modelNode)
            arDisplayView?.showLog("✅ \(title) placed in front.")
            focusSquare?.isHidden = true

            // Debug output
            print("DEBUG: 📏 \(title) placed with scale: \(standardScale)")
            return true
        }

        arDisplayView?.showLog("❌ Could not determine placement for \(title).")
        return false
    }

    // -------------------------------
    //  CLEAN‑UP
    // -------------------------------
    func cleanupResources() {
        guard let arView = arView else { return }

        // Remove all child nodes except for lighting nodes
        for node in arView.scene.rootNode.childNodes {
            if node.light == nil && node != focusSquare {
                node.removeFromParentNode()
            }
        }

        focusSquare?.isHidden = false
    }

    // -------------------------------
    //  LIGHTING
    // -------------------------------
    private func setupBasicLighting() {
        guard let arView = arView else { return }

        // Omni-directional light
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .omni
        omniLightNode.light!.color = UIColor.white
        omniLightNode.light!.intensity = 1000
        omniLightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        arView.scene.rootNode.addChildNode(omniLightNode)

        // Ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.light!.intensity = 200
        arView.scene.rootNode.addChildNode(ambientLightNode)

        print("DEBUG: 💡 Basic lighting has been set up.")
    }

    // -------------------------------
    //  CAMERA UTILITIES
    // -------------------------------
    private func getPositionInFrontOfCamera(distance: Float = 1) -> SCNVector3?
    {
        guard let arView = arView,
            let currentFrame = arView.session.currentFrame
        else {
            return nil
        }

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -distance
        let transform = currentFrame.camera.transform * translation
        return SCNVector3(
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

// =============================================================
//  MARK: – Utils
// =============================================================
extension ARModelManager {
    // -------------------------------
    //  ADVANCED CLEAN‑UP
    // -------------------------------
    /// Enhanced cleanup that returns removed nodes
    func cleanupResourcesAndReturnRemoved() -> [SCNNode] {
        guard let arView = arView else { return [] }

        var removedNodes: [SCNNode] = []

        // Remove all child nodes except for lighting nodes and focus square
        for node in arView.scene.rootNode.childNodes {
            if node.light == nil && node != focusSquare {
                removedNodes.append(node)
                node.removeFromParentNode()
            }
        }

        focusSquare?.isHidden = false
        return removedNodes
    }

    // -------------------------------
    //  PARTS & HIGHLIGHTING
    // -------------------------------
    /// Gets all parts from a model node with enhanced metadata
    func getModelParts(from rootNode: SCNNode) -> [SCNNode] {
        var parts: [SCNNode] = []

        func traverse(node: SCNNode) {
            // Only include nodes with names or geometry
            if let name = node.name, !name.isEmpty {
                parts.append(node)
            } else if node.geometry != nil {
                // Give unnamed geometry nodes a default name
                node.name = "Part_\(parts.count + 1)"
                parts.append(node)
            }

            for child in node.childNodes {
                traverse(node: child)
            }
        }

        traverse(node: rootNode)
        return parts
    }

    /// Highlights a set of nodes with the specified color
    func highlightNodes(_ nodes: Set<SCNNode>, with color: UIColor) {
        for node in nodes {
            node.geometry?.firstMaterial?.emission.contents = color
        }
    }

    /// Resets highlights for a set of nodes
    func resetHighlights(for nodes: Set<SCNNode>) {
        for node in nodes {
            node.geometry?.firstMaterial?.emission.contents = UIColor.black
        }
    }

    /// Batch updates for performance
    func performBatchUpdate(_ updates: () -> Void) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        updates()
        SCNTransaction.commit()
    }
}
extension ARModelManager {
    // -------------------------------
    //  RESET POSITION
    // -------------------------------
    /// Resets the position of a model either to a detected plane or in front of the camera
    func resetModelPosition(_ node: SCNNode) {
        guard let arView = arView else { return }

        // Option 1: Reset to center of detected plane
        if let raycastQuery = arView.getRaycastQuery(),
            let result = arView.castRay(for: raycastQuery).first
        {

            // Animate the position change
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3

            let transform = result.worldTransform
            node.position = SCNVector3(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )

            SCNTransaction.commit()

            arDisplayView?.showLog("🔄 Position reset to surface.")
            return
        }

        // Option 2: Fallback - Reset to camera space if no plane found
        if let defaultPosition = getPositionInFrontOfCamera(distance: 0.3) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3

            node.position = defaultPosition

            // Also reset orientation to match camera
            if let pov = arView.pointOfView {
                node.eulerAngles.y = pov.eulerAngles.y
            }

            SCNTransaction.commit()

            arDisplayView?.showLog("🔄 Position reset to front of camera.")
            return
        }

        arDisplayView?.showLog("❌ Could not reset position.")
    }
}

// =============================================================
//  MARK: – Debug
// =============================================================
extension ARModelManager {
    func printModelHierarchy(from node: SCNNode, prefix: String = "") {
        print("DEBUG: \(prefix)📦 Node: \(node.name ?? "Unnamed")")

        // Print local and world position
        let localPos = node.position
        let worldPos = node.worldPosition
        print(
            "DEBUG: \(prefix)📍 Local Position:  x: \(localPos.x), y: \(localPos.y), z: \(localPos.z)"
        )
        print(
            "DEBUG: \(prefix)🌍 World Position:  x: \(worldPos.x), y: \(worldPos.y), z: \(worldPos.z)"
        )

        // Scale
        let scale = node.scale
        print(
            "DEBUG: \(prefix)📐 Scale:           x: \(scale.x), y: \(scale.y), z: \(scale.z)"
        )

        // Rotation (Euler Angles)
        let rot = node.eulerAngles
        print(
            "DEBUG: \(prefix)🧭 Rotation:        x: \(rot.x), y: \(rot.y), z: \(rot.z) (radians)"
        )

        // Bounding Box
        let (minBB, maxBB) = node.boundingBox
        print(
            "DEBUG: \(prefix)📦 Bounding Box:   min: (\(minBB.x), \(minBB.y), \(minBB.z)), max: (\(maxBB.x), \(maxBB.y), \(maxBB.z))"
        )

        // Parent info
        if let parent = node.parent {
            print(
                "DEBUG: \(prefix)🔗 Parent:         \(parent.name ?? "Unnamed")")
        }

        // Unique identifier (for tracking duplicates)
        print(
            "DEBUG: \(prefix)🆔 Node Identifier: \(Unmanaged.passUnretained(node).toOpaque())"
        )

        // Geometry & materials
        if let geometry = node.geometry {
            print(
                "DEBUG: \(prefix)🎭 Geometry:       \(geometry.name ?? "UnnamedGeometry")"
            )
            print("DEBUG: \(prefix)🔷 Geometry Type:  \(type(of: geometry))")
            print(
                "DEBUG: \(prefix)🧊 Geometry Elements: \(geometry.elements.count)"
            )

            for (index, material) in geometry.materials.enumerated() {
                print(
                    "DEBUG: \(prefix)  🎨 Material \(index + 1): \(material.name ?? "UnnamedMaterial")"
                )

                // Diffuse Color
                if let diffuse = material.diffuse.contents as? UIColor {
                    var r: CGFloat = 0
                    var g: CGFloat = 0
                    var b: CGFloat = 0
                    var a: CGFloat = 0
                    diffuse.getRed(&r, green: &g, blue: &b, alpha: &a)
                    print(
                        "DEBUG: \(prefix)    🎨 Diffuse Color: R: \(r), G: \(g), B: \(b), A: \(a)"
                    )
                } else {
                    print(
                        "DEBUG: \(prefix)    🎨 Diffuse: \(type(of: material.diffuse.contents))"
                    )
                }

                // Metalness
                if let metalness = material.metalness.contents as? CGFloat {
                    print("DEBUG: \(prefix)    🧲 Metalness: \(metalness)")
                }

                // Roughness
                if let roughness = material.roughness.contents as? CGFloat {
                    print("DEBUG: \(prefix)    🔧 Roughness: \(roughness)")
                }

                // Transparency
                print(
                    "DEBUG: \(prefix)    🌫 Transparency: \(material.transparency)"
                )
            }
        }

        print("\(prefix)────────────────────────────")

        // Recurse into children
        for child in node.childNodes {
            printModelHierarchy(from: child, prefix: prefix + "  ")
        }
    }
}

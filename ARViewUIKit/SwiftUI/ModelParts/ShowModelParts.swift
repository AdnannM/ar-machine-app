//
//  ShowModelParts.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.05.25.
//

import SwiftUI
import SceneKit
import Combine

#warning("------------------------------------")
/*
  TODO: - Clean code and write documentation add add this to new file
*/
#warning("------------------------------------")

// MARK: - ViewModel for AR Parts Management
@MainActor
final class ARPartsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentModelParts: [SCNNode] = []
    @Published var selectedParts: Set<SCNNode> = []
    @Published var isLoading: Bool = false
    @Published var logMessage: String = ""
    
    private var partColors: [SCNNode: UIColor] = [:]
    
    private let availableColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPink,
        .systemTeal, .systemPurple, .systemIndigo, .brown, .magenta
    ]
    
    // MARK: - Private Properties
    private let modelManager: ARModelManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasSelectedParts: Bool {
        !selectedParts.isEmpty
    }
    
    var selectedPartsCount: Int {
        selectedParts.count
    }
    
    var areAllPartsSelected: Bool {
        selectedParts.count == currentModelParts.count && !currentModelParts.isEmpty
    }
    
    // MARK: - Initialization
    init(modelManager: ARModelManager) {
        self.modelManager = modelManager
    }
    
    // MARK: - Public Methods
    
    /// Toggles selection for a single part
    func togglePartSelection(_ part: SCNNode) {
        if selectedParts.contains(part) {
            selectedParts.remove(part)
        } else {
            selectedParts.insert(part)
            if partColors[part] == nil {
                partColors[part] = availableColors.randomElement() ?? .yellow
            }
        }
        updatePartsHighlight()
    }

    
    /// Toggles selection for all parts
    func toggleSelectAll() {
        if areAllPartsSelected {
            selectedParts.removeAll()
        } else {
            selectedParts = Set(currentModelParts)
        }
        updatePartsHighlight()
    }
    
    /// Highlights selected parts temporarily
    func highlightSelectedParts() {
        guard !selectedParts.isEmpty else { return }
        
        // Flash yellow highlight
        for part in selectedParts {
            part.geometry?.firstMaterial?.emission.contents = UIColor.yellow
        }
        
        logMessage = "✨ Highlighted \(selectedParts.count) selected parts"
        
        // Restore selection highlight after delay
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            await MainActor.run {
                self.updatePartsHighlight()
            }
        }
    }
    
    /// Removes selected parts from the scene
    func removeSelectedParts() {
        let count = selectedParts.count
        
        // Remove from scene
        for part in selectedParts {
            part.removeFromParentNode()
        }
        
        // Update model parts list
        currentModelParts.removeAll { selectedParts.contains($0) }
        
        // Clear selection
        selectedParts.removeAll()
        
        logMessage = "🧹 Removed \(count) selected parts."
    }
    
    /// Loads model parts from a node
    func loadModelParts(from modelNode: SCNNode) {
        currentModelParts = modelManager.getModelParts(from: modelNode)

        let baseColor = UIColor.systemGray
        partColors.removeAll()

        for part in currentModelParts {
            if let material = part.geometry?.firstMaterial {
                material.diffuse.contents = baseColor
                material.emission.contents = UIColor.black
            }
        }

        selectedParts.removeAll()
        updatePartsHighlight()
        logMessage = "📦 Loaded \(currentModelParts.count) parts"
    }

    
    /// Clears all parts and selections
    func clearAll() {
        let removedNodes = modelManager.cleanupResourcesAndReturnRemoved()
        
        // Update selections based on what was removed
        selectedParts = selectedParts.filter { node in
            !removedNodes.contains(node)
        }
        
        currentModelParts = currentModelParts.filter { node in
            !removedNodes.contains(node)
        }
        
        logMessage = "🧹 Cleared all parts from scene."
    }
    
    // MARK: - Private Methods
    
    /// Updates the visual highlight state of all parts
    private func updatePartsHighlight() {
        for part in currentModelParts {
            if let material = part.geometry?.firstMaterial {
                if selectedParts.contains(part) {
                    material.emission.contents = partColors[part] ?? UIColor.blue
                } else {
                    material.emission.contents = UIColor.black
                }
            }
        }

        if !selectedParts.isEmpty {
            logMessage = "🔷 \(selectedParts.count) parts selected"
        }
    }
}



import SwiftUI
import SceneKit

struct ShowModelPartsView: View {
    @ObservedObject var viewModel: ARPartsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.currentModelParts.isEmpty {
                    EmptyStateView()
                } else {
                    PartsListView(viewModel: viewModel)
                }
            }
            .navigationTitle("Model Parts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if viewModel.hasSelectedParts {
                            Button(action: {
                                viewModel.removeSelectedParts()
                                if viewModel.currentModelParts.isEmpty {
                                    dismiss()
                                }
                            }) {
                                Label("Remove", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Button(action: { viewModel.toggleSelectAll() }) {
                            Label(
                                viewModel.areAllPartsSelected ? "Deselect All" : "Select All",
                                systemImage: viewModel.areAllPartsSelected ? "checkmark.square" : "square"
                            )
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.hasSelectedParts {
                    BottomActionBar(viewModel: viewModel, dismiss: { dismiss() })
                }
            }
        }
    }
}

// MARK: - Subviews

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No parts available")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


private struct BottomActionBar: View {
    @ObservedObject var viewModel: ARPartsViewModel
    var dismiss: () -> Void  // Pass from parent
    
    var body: some View {
        HStack {
            Text("\(viewModel.selectedPartsCount) selected")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                viewModel.highlightSelectedParts()
                dismiss() // Dismiss after highlighting
            }) {
                Label("Highlight", systemImage: "sparkles")
                    .font(.footnote)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
}

struct PartsListView: View {
    @ObservedObject var viewModel: ARPartsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.currentModelParts, id: \.self) { node in
                    PartRowView(
                        node: node,
                        isSelected: viewModel.selectedParts.contains(node),
                        onTap: { viewModel.togglePartSelection(node) }
                    )
                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedParts)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}


// MARK: - Part Row View

/// A row view that displays information about a single part
struct PartRowView: View {
    let node: SCNNode
    let isSelected: Bool
    let onTap: () -> Void
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
            
            if showDetails {
                PartDetailsExpandedView(node: node)
                    .transition(.opacity)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 12)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: showDetails)
    }
    
    private var mainContent: some View {
        HStack(alignment: .top, spacing: 12) {
            checkboxButton
            partInformation
            Spacer()
            rightSideElements
        }
        .padding(.horizontal, 8)
        .contentShape(Rectangle()) // Makes the whole row tappable
    }
    
    // MARK: - Subviews
    
    private var checkboxButton: some View {
        Button(action: onTap) {
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .foregroundColor(isSelected ? .accentColor : Color.primary.opacity(0.6))
                .font(.system(size: 22))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var partInformation: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Part name
            Text(formatPartName(node.name ?? "Unnamed Part"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            // Quick stats
            quickStatsRow
            
            // Location
            locationSummary
        }
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Material/Geometry info
            if let materialName = node.geometry?.firstMaterial?.name, !materialName.isEmpty {
                Label(formatPartName(materialName), systemImage: "cube.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else if let geometryName = node.geometry?.name, !geometryName.isEmpty {
                Label(formatPartName(geometryName), systemImage: "cube")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            // Size badge
            if let size = getPartSize(node) {
                Text(size)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.secondary.opacity(0.2)))
            }
        }
    }
    
    private var locationSummary: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
            Text(getLocationSummary(node))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private var rightSideElements: some View {
        VStack(alignment: .trailing, spacing: 8) {
            MaterialColorIndicator(node: node)
            
            Button(action: toggleDetails) {
                Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.accentColor.opacity(0.08) : Color.secondary.opacity(0.06))
    }
    
    // MARK: - Helper Methods
    
    private func toggleDetails() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showDetails.toggle()
        }
    }
    
    private func formatPartName(_ name: String) -> String {
        let cleanedName = name
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "mat_", with: "Material ")
            .replacingOccurrences(of: "sgm", with: "SGM")
        
        return cleanedName
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    private func getPartSize(_ node: SCNNode) -> String? {
        let boundingBox = node.presentation.boundingBox
        
        let width = abs(boundingBox.max.x - boundingBox.min.x)
        let height = abs(boundingBox.max.y - boundingBox.min.y)
        let depth = abs(boundingBox.max.z - boundingBox.min.z)
        
        guard width > 0 || height > 0 || depth > 0 else { return nil }
        
        return String(format: "%.0fx%.0fx%.0f", width, height, depth)
    }
    
    private func getLocationSummary(_ node: SCNNode) -> String {
        let pos = node.position
        return String(format: "X: %.1f Y: %.1f Z: %.1f", pos.x, pos.y, pos.z)
    }
}

// MARK: - Part Details Expanded View

/// An expanded view showing detailed information about a part
struct PartDetailsExpandedView: View {
    let node: SCNNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 10) {
                transformSection
                dimensionsSection
                materialSection
                geometrySection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
    
    // MARK: - Detail Sections
    
    private var transformSection: some View {
        DetailSection(title: "Transform", icon: "move.3d") {
            DetailRow(label: "Position", value: formatVector(node.position))
            DetailRow(label: "Rotation", value: formatRotation(node.eulerAngles))
            DetailRow(label: "Scale", value: formatVector(node.scale))
        }
    }
    
    private var dimensionsSection: some View {
        let boundingBox = node.presentation.boundingBox
        return DetailSection(title: "Dimensions", icon: "cube.transparent") {
            DetailRow(label: "Size", value: getDimensionString(boundingBox))
            DetailRow(label: "Center", value: getCenterString(boundingBox))
        }
    }
    
    @ViewBuilder
    private var materialSection: some View {
        if let material = node.geometry?.firstMaterial {
            DetailSection(title: "Material Properties", icon: "paintbrush.fill") {
                DetailRow(label: "Metalness", value: "\(Int(material.metalness.floatValue * 100))%")
                DetailRow(label: "Roughness", value: "\(Int(material.roughness.floatValue * 100))%")
                
                if let diffuseColor = material.diffuse.contents as? UIColor {
                    HStack {
                        Text("Diffuse Color")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                        ColorSwatchView(color: diffuseColor)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var geometrySection: some View {
        if let geometry = node.geometry {
            DetailSection(title: "Geometry", icon: "cube") {
                DetailRow(label: "Type", value: String(describing: type(of: geometry)))
                DetailRow(label: "Elements", value: "\(geometry.elements.count)")
                DetailRow(label: "Materials", value: "\(geometry.materials.count)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatVector(_ vector: SCNVector3) -> String {
        String(format: "%.2f, %.2f, %.2f", vector.x, vector.y, vector.z)
    }
    
    private func formatRotation(_ rotation: SCNVector3) -> String {
        let degrees = (rotation.x * 180 / .pi, rotation.y * 180 / .pi, rotation.z * 180 / .pi)
        return String(format: "%.1f°, %.1f°, %.1f°", degrees.0, degrees.1, degrees.2)
    }
    
    private func getDimensionString(_ boundingBox: (min: SCNVector3, max: SCNVector3)) -> String {
        let size = (
            width: abs(boundingBox.max.x - boundingBox.min.x),
            height: abs(boundingBox.max.y - boundingBox.min.y),
            depth: abs(boundingBox.max.z - boundingBox.min.z)
        )
        return String(format: "W: %.1f, H: %.1f, D: %.1f", size.width, size.height, size.depth)
    }
    
    private func getCenterString(_ boundingBox: (min: SCNVector3, max: SCNVector3)) -> String {
        let center = SCNVector3(
            x: (boundingBox.min.x + boundingBox.max.x) / 2,
            y: (boundingBox.min.y + boundingBox.max.y) / 2,
            z: (boundingBox.min.z + boundingBox.max.z) / 2
        )
        return formatVector(center)
    }
}

// MARK: - Detail Section

/// A reusable section view for displaying grouped detail information
struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                content
            }
            .padding(.leading, 20)
        }
    }
}

// MARK: - Detail Row

/// A row view for displaying label-value pairs
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Material Color Indicator

/// A view that displays the material color of a node
struct MaterialColorIndicator: View {
    let node: SCNNode
    
    var body: some View {
        if let material = node.geometry?.firstMaterial,
           let color = material.diffuse.contents as? UIColor {
            colorSwatch(color: color)
        } else {
            noColorSwatch
        }
    }
    
    private func colorSwatch(color: UIColor) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(color))
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
            
            Text("Color")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
    
    private var noColorSwatch: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Text("N/A")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                )
            
            Text("Color")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Color Swatch View

/// A view that displays a color swatch with its hex value
struct ColorSwatchView: View {
    let color: UIColor
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(color))
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
            
            Text(hexString(from: color))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
    
    private func hexString(from color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Extensions

extension SCNMaterialProperty {
    /// Converts the contents to a float value
    var floatValue: Float {
        return (contents as? NSNumber)?.floatValue ?? 0.0
    }
}

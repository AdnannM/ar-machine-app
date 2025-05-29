//
//  ARViewController.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 12.04.25.
//

//import ARKit
//import Combine
//import UIKit
//import os.log
//import SwiftUI
//
//final class ARViewController: UIViewController {
//
//    // MARK: - Properties
//    var isShowingCameraButtons = false
//    private var isRecording: Bool = false
//    var isSHowingConrolButtons = false
//    private var videoOutputURL: URL?
//    let updateQueue = DispatchQueue(
//        label: "com.muratovic.adnann.ARViewUIKit" // TODO: - Replace with compay ID
//    )
//
//    var isMenuOpened = false
//    var arDisplayView = ARDisplayView()
//    var pdfViewCenterYConstraint: NSLayoutConstraint!
//    let viewModel = PhotosVideoViewModel()
//    var cancellables = Set<AnyCancellable>()
//    let coachingOverlay = ARCoachingOverlayView()
//
//    var focusSquare = FocusSquare()
//
//    var modelManager: ARModelManager!
//    private var loadingView: ARLoadingView!
//    private var isLoadingModel = false
//
//    var currentlyManipulatedNode: SCNNode?
//    var initialScaleForPinch: SCNVector3?
//    var initialNodePosition: SCNVector3?
//
//    var initialYaw: Float = 0
//
//    private var arrowPrototype: SCNNode?        // loaded once, then cloned
//    private var activeArrowNode: SCNNode?       // the arrow now in scene
//    private var trackedPartNode: SCNNode?       // current selected part
//
//    // MULTI-ARROW SUPPORT
//    private var arrows = [SCNNode: SCNNode]()    // part  ➜  arrow
//    private var bounceActions = [SCNNode: SCNAction]()   // cache per-size
//
//
//    // ViewModel
//    private var partsViewModel: ARPartsViewModel!
//
//    // MARK: - View
//
//    /// Menu Button
//    lazy var menuButton: UIButton = {
//        let customImage = UIImage(named: "menu") ?? UIImage()
//        let button = UIButton.createIconButton(image: customImage)
//        button.addTarget(
//            self, action: #selector(toggleMenu), for: .touchUpInside)
//        return button
//    }()
//
//    /// Right Buttons
//    lazy var rightBarButton: RightBarButtons = {
//        let button = RightBarButtons()
//        button.alpha = 0.0
//        button.isHidden = true
//        button.layer.cornerRadius = 12
//        button.delegate = self
//        button.backgroundColor = .clear
//        return button
//    }()
//
//
//    /// Machine View
//    lazy var addMachineView: Add3DModelView = {
//        // Use the new initializer, passing the specific viewModel and title
//        let view = Add3DModelView(
//            viewModel: machineViewModel, title: "Import 3D Machine")
//        view.isHidden = true
//        return view
//    }()
//
//    /// Arrow View
//    lazy var addObjectView: Add3DModelView = {
//        // Use the new initializer, passing the specific viewModel and title
//        let view = Add3DModelView(
//            viewModel: objectViewModel, title: "Import 3D Object")
//        view.isHidden = true
//        return view
//    }()
//
//    /// Camera button Photo / Video
//    lazy var cameraButton: CameraButtons = {
//        let buttons = CameraButtons()
//        buttons.alpha = 0.0
//        buttons.isHidden = true
//        buttons.delegate = self
//        return buttons
//    }()
//
//    /// Controll buttons for 3d Model
//    lazy var controlButton: ControlButtons = {
//        let buttons = ControlButtons()
//        buttons.alpha = 0.0
//        buttons.isHidden = true
//        return buttons
//    }()
//
//    /// PDF View
//    lazy var pdfView: PdfView = {
//        let view = PdfView()
//        view.isHidden = true
//        view.delegate = self
//        return view
//    }()
//
//    lazy var showPartsButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        let image = UIImage(systemName: "hand.tap.fill") // pick your preferred symbol
//        button.setImage(image, for: .normal)
//
//        // Make it circular and big
//        button.backgroundColor = .systemBlue
//        button.tintColor = .white
//        button.layer.cornerRadius = 40 // half of width/height for circular shape
//        button.layer.masksToBounds = true
//        button.isHidden = true
//
//        // Add shadow (optional)
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOpacity = 0.3
//        button.layer.shadowOffset = CGSize(width: 2, height: 2)
//        button.layer.shadowRadius = 4
//
//        button.addTarget(self, action: #selector(didTapShowPartsButton), for: .primaryActionTriggered)
//
//        return button
//    }()
//
//
//    // MARK: -View Model
//
//    private lazy var machineViewModel: Add3DModelViewModel = {
//        // Use the new initializer with.machine type
//        let vm = Add3DModelViewModel(type: .machine)
//        vm.delegate = self
//        return vm
//    }()
//
//    private lazy var objectViewModel: Add3DModelViewModel = {
//        // Use the new initializer with.object type
//        let vm = Add3DModelViewModel(type: .object)
//        vm.delegate = self
//        return vm
//    }()
//
//    // MARK: - ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setup()
//        layout()
//
//        // Set delegates
//        arDisplayView.arView.delegate = self
//        arDisplayView.arView.session.delegate = self
//
//        // Configure for media capture will setup bindings
//        configureForMediaCapture()
//
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(appWillResignActive),
//            name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(
//            self, selector: #selector(appDidBecomeActive),
//            name: UIApplication.didBecomeActiveNotification, object: nil)
//
//        // Set up loading view first
//        setupLoadingView()
//
//        // Initialize the view model (this creates partsViewModel)
//        setupViewModel()
//
//        // Subscribe to loading progress updates (after modelManager is initialized)
//        modelManager.loadingProgressPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] title, progress in
//                self?.loadingView.updateProgress(title: title, progress: progress)
//
//                // When loading completes, hide the loading view
//                if progress >= 1.0 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        self?.loadingView.hideLoading()
//                        self?.isLoadingModel = false
//                    }
//                }
//            }
//            .store(in: &cancellables)
//
//        // Setup gestures for AR interactions
//        setupGestures()
//
//        // Setup bindings after view model is initialized
//        setupBindings()
//
//        loadArrowPrototype()
//
//        partsViewModel.$selectedParts
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] newSet in
//                guard let self = self else { return }
//
//                // current parts that already have arrows
//                let current = Set(arrows.keys)          // ⬅️ convert to Set first
//
//                // 1) arrows to add
//                let toAdd = newSet.subtracting(current)
//                for part in toAdd { self.attachArrow(to: part) }
//
//                // 2) arrows to remove
//                let toRemove = current.subtracting(newSet)
//                for part in toRemove { self.detachArrow(from: part) }
//            }
//            .store(in: &cancellables)
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Consider moving heavy setup to background thread if possible
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            // Prepare heavy resources
//            DispatchQueue.main.async {
//                self?.arDisplayView.isHidden = false
//                self?.arDisplayView.startSession()
//                self?.setupCoachingOverlay()
//                self?.setupFocusSquare()
//            }
//        }
//
//        if viewModel.isRecording {
//            viewModel.toggleRecording()
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
//        UIApplication.shared.isIdleTimerDisabled = true
//
//        // Force layout if needed
//        arDisplayView.arView.setNeedsLayout()
//        arDisplayView.arView.layoutIfNeeded()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        arDisplayView.cleanupResources()
//        arDisplayView.arView.delegate = nil
//        arDisplayView.arView.session.delegate = nil
//
//        cancellables.removeAll()
//    }
//
//    // Add memory warning handler
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        arDisplayView.cleanupResources()  // Clean up resources on memory warning
//    }
//
//    // MARK: - Deinit
//
//    deinit {
//        os_log(
//            "ARViewController deinit - Removing observers", log: .default,
//            type: .info)
//        NotificationCenter.default.removeObserver(
//            self, name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.removeObserver(
//            self, name: UIApplication.didBecomeActiveNotification, object: nil)
//        // Your existing cleanup
//        cancellables.removeAll()
//    }
//
//    // MARK: - Loading View Setup
//    private func setupLoadingView() {
//        // Initialize loading view with the same frame as the main view
//        loadingView = ARLoadingView(frame: view.bounds)
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loadingView)
//
//        // Ensure loading view covers the entire screen with proper constraints
//        NSLayoutConstraint.activate([
//            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
//            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // Set initial state
//        loadingView.isHidden = true
//    }
//
//    private func setupViewModel() {
//        // Initialize the model manager and view model
//        modelManager = ARModelManager(
//            arView: arDisplayView.arView,
//            arDisplayView: arDisplayView,
//            focusSquare: focusSquare  // Pass the FocusSquare instance
//        )
//        partsViewModel = ARPartsViewModel(modelManager: modelManager)
//
//    }
//
//    private func setupBindings() {
//        // Observe view model changes
//        partsViewModel.$logMessage
//            .sink { [weak self] message in
//                if !message.isEmpty {
//                    self?.arDisplayView.showLog(message)
//                }
//            }
//            .store(in: &cancellables)
//
//        partsViewModel.$currentModelParts
//            .sink { [weak self] parts in
//                self?.showPartsButton.isHidden = parts.isEmpty
//            }
//            .store(in: &cancellables)
//    }
//
//    /// Loads Arrow.usdz once and keeps it for cloning.
//    private func loadArrowPrototype() {
//        guard arrowPrototype == nil,
//              let url = Bundle.main.url(forResource: "Arrow", withExtension: "usdz") else {
//            print("🚫  Arrow.usdz NOT found in bundle!")
//            return
//        }
//        print("✅  Arrow model URL:", url.lastPathComponent)          // <-- add
//
//        guard let ref = SCNReferenceNode(url: url) else {
//            print("🚫  SCNReferenceNode could not be created.")
//            return
//        }
//
//        ref.load()
//        ref.name = "ArrowPrototype"
//        // Ensure a sensible real-world size (~3 cm long)
//        ref.scale = SCNVector3(0.03, 0.03, 0.03)
//        arrowPrototype = ref
//    }
//
//    // MARK: - Arrow helpers  (multi-arrow, vertical bounce)
//    private func attachArrow(to part: SCNNode) {
//        guard arrows[part] == nil, let proto = arrowPrototype else { return }
//
//        let arrow = proto.clone()
//        arrow.name = "IndicatorArrow"
//
//        // ── anchor: top-centre + 20 % of height
//        let (minB, maxB) = part.boundingBox
//        let h = maxB.y - minB.y
//        arrow.position = SCNVector3(
//            (minB.x + maxB.x) * 0.5,
//            maxB.y + h * 0.2,
//            (minB.z + maxB.z) * 0.5
//        )
//
//        // ── scale ≈30 % of largest dimension
//        let maxDim = max(h, maxB.x - minB.x, maxB.z - minB.z)
//        let s = Float(maxDim) * 0.3
//        arrow.scale = SCNVector3(s, s, s)
//
//        // ───────────────────────────────────────────────
//        // REMOVE billboard constraint  ➜  no rotation
//        // ───────────────────────────────────────────────
//
//        // ── pure vertical bounce (15 % of height)
//        let dy     = h * 0.15
//        let up     = SCNAction.moveBy(x: 0, y: CGFloat(dy), z: 0, duration: 0.5)
//        up.timingMode = .easeInEaseOut
//        let bounce = SCNAction.repeatForever(.sequence([up, up.reversed()]))
//        arrow.runAction(bounce)
//
//        // ── attach & register
//        part.addChildNode(arrow)
//        arrows[part] = arrow
//    }
//
//
//    private func detachArrow(from part: SCNNode) {
//        arrows[part]?.removeFromParentNode()
//        arrows[part] = nil
//        bounceActions[part] = nil
//    }
//
//    /// Call when *all* parts are cleared
//    private func removeAllArrows() {
//        for (_, arrow) in arrows { arrow.removeFromParentNode() }
//        arrows.removeAll()
//        bounceActions.removeAll()
//    }
//
//
//    private func hideArrow() {
//        activeArrowNode?.removeFromParentNode()
//        activeArrowNode = nil
//    }
//}
//
//// MARK: - Setup UI
//
//extension ARViewController {
//    private func setup() {
//
//        arDisplayView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(arDisplayView)
//
//        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(coachingOverlay)
//
//        view.addSubview(menuButton)
//
//        rightBarButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(rightBarButton)
//
//        /// Camera Button
//        cameraButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(cameraButton)
//
//        /// Control Buttons
//        controlButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(controlButton)
//
//        /// 3D Model VIew
//        addMachineView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(addMachineView)
//
//        addObjectView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(addObjectView)
//
//        /// Pdf View
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pdfView)
//
//        view.addSubview(showPartsButton)
//    }
//}
//
//// MARK: - Add3DModelViewDelegate
//extension ARViewController: Add3DModelViewDelegate {
//
//    private enum ViewKind { case machine, object }
//
//    // -------------------------------
//    //  CLEAR / CLOSE
//    // -------------------------------
//
//    func clearButtonTapped(from view: Add3DModelView) {
//        let kind: ViewKind = (view == addMachineView) ? .machine : .object
//
//        switch kind {
//        case .machine:
//            partsViewModel.clearAll()
//            removeAllArrows()
//            hideModelView(view)
//
//        case .object:
//            modelManager.cleanupResources()
//            arDisplayView.showLog("🧹 Objects cleared from scene.")
//        }
//
//        currentlyManipulatedNode = nil
//        initialScaleForPinch      = nil
//
//        updatePartsButtonVisibility()
//    }
//
//    func closeButtonTapped(from view: Add3DModelView) {
//        hideModelView(view)
//    }
//
//    // -------------------------------
//    //  SELECT / LOAD / PLACE
//    // -------------------------------
//
//    func modelSelected(_ model: MachineModel, from view: Add3DModelView) {
//
//        guard !isLoadingModel else {
//            arDisplayView.showLog("⏳ Already loading a model, please wait…")
//            return
//        }
//        isLoadingModel = true
//        defer { isLoadingModel = false }        // always clears the busy flag
//
//        let kind: ViewKind = (view == addObjectView) ? .object : .machine
//        hideModelView(view)
//        if isMenuOpened { toggleMenu() }
//
//        Task { [weak self] in
//            guard let self else { return }
//
//            do {  // 1️⃣ Load
//                let node = try await modelManager.loadModel(named: model.id,
//                                                            title: model.title)
//                currentlyManipulatedNode = node
//
//                // 2️⃣ Place
//                guard modelManager.placeModel(node, title: model.id) else {
//                    arDisplayView.showLog("❌ Could not determine placement.")
//                    currentlyManipulatedNode = nil
//                    return
//                }
//
//                arDisplayView.showLog("✅ \(model.title) placed.")
//                modelManager.printModelHierarchy(from: node)   // DEBUG
//
//                // 3️⃣ Post-placement UI
//                switch kind {
//                case .machine:
//                    partsViewModel.isLoading = true
//                    partsViewModel.loadModelParts(from: node)
//                    partsViewModel.isLoading = false
//                    rightBarButton.isHidden  = true
//
//                case .object:
//                    rightBarButton.isHidden  = false
//                }
//
//                updatePartsButtonVisibility()
//
//            } catch {
//                arDisplayView.showLog("❌ Failed to load \(model.title): \(error.localizedDescription)")
//                currentlyManipulatedNode = nil
//            }
//        }
//    }
//
//    // -------------------------------
//    //  Helpers
//    // -------------------------------
//
//    /// Hide Parts button only if *no* machine parts remain
//    private func updatePartsButtonVisibility() {
//        showPartsButton.isHidden = partsViewModel.currentModelParts.isEmpty
//    }
//}
//
//
//extension ARViewController {
//    @objc private func didTapShowPartsButton() {
//        let showPartsView = ShowModelPartsView(viewModel: partsViewModel)
//        let hostingController = UIHostingController(rootView: showPartsView)
//        presentAsSheet(hostingController, detents: [.large()])
//    }
//
//    // Helper method for presentation
//    private func presentAsSheet(_ viewController: UIViewController, detents: [UISheetPresentationController.Detent]) {
//        if let sheet = viewController.sheetPresentationController {
//            sheet.detents = detents
//            sheet.prefersGrabberVisible = true
//        }
//        present(viewController, animated: true)
//    }
//
//    private func hideModelView(_ view: UIView) {
//        // Implementation for hiding model view
//        view.isHidden = true
//    }
//}

//  ARViewController.swift
//  Refactored & cleaned‑up version
//
//  Created by ChatGPT on 22 May 2025.
//

import ARKit
import Combine
import SwiftUI
import UIKit
import os.log

// =============================================================
//  MARK: – ARViewController
// =============================================================
final class ARViewController: UIViewController {

    // -------------------------------
    //  MARK: Properties
    // -------------------------------
    // UI & State
    var isMenuOpened = false
    var isShowingCameraButtons = false
    var isSHowingConrolButtons = false
    private var isRecording = false
    private var isLoadingModel = false
    
    var pdfViewCenterYConstraint: NSLayoutConstraint!

    // Paths / URLs
    private var videoOutputURL: URL?

    // Concurrency / Combine
    let updateQueue = DispatchQueue(
        label: "com.muratovic.adnann.ARViewUIKit")
    var cancellables = Set<AnyCancellable>()

    // AR & Scene
    var arDisplayView = ARDisplayView()
    let coachingOverlay = ARCoachingOverlayView()
    var focusSquare = FocusSquare()
    var modelManager: ARModelManager!

    // Loading overlay
    private var loadingView: ARLoadingView!

    // Selection / Manipulation
    var currentlyManipulatedNode: SCNNode?
    var initialScaleForPinch: SCNVector3?
    var initialNodePosition: SCNVector3?
    var initialYaw: Float = 0

    // Arrow helpers
    var arrowPrototype: SCNNode?
    var activeArrowNode: SCNNode?
    private var trackedPartNode: SCNNode?
    var arrows = [SCNNode: SCNNode]()
    var bounceActions = [SCNNode: SCNAction]()

    // View‑models
    let viewModel = PhotosVideoViewModel()
    private var partsViewModel: ARPartsViewModel!
    
    weak var arrowDelegate: ArrowLoaderDelegate?
    
    // -------------------------------
    //  MARK: View‑Model helpers
    // -------------------------------
    private lazy var machineViewModel: Add3DModelViewModel = {
        let vm = Add3DModelViewModel(type: .machine)
        vm.delegate = self
        return vm
    }()

    private lazy var objectViewModel: Add3DModelViewModel = {
        let vm = Add3DModelViewModel(type: .object)
        vm.delegate = self
        return vm
    }()

    // -------------------------------
    //  MARK: UI Elements
    // -------------------------------
    lazy var menuButton: UIButton = {
        let img = UIImage(named: "menu") ?? UIImage()
        let button = UIButton.createIconButton(image: img)
        button.addTarget(
            self, action: #selector(toggleMenu), for: .touchUpInside)
        return button
    }()

    lazy var rightBarButton: RightBarButtons = {
        let btn = RightBarButtons()
        btn.alpha = 0
        btn.isHidden = true
        btn.layer.cornerRadius = 12
        btn.delegate = self
        btn.backgroundColor = .clear
        return btn
    }()

    lazy var addMachineView: Add3DModelView = {
        let view = Add3DModelView(
            viewModel: machineViewModel, title: "Import 3D Machine")
        view.isHidden = true
        return view
    }()

    lazy var addObjectView: Add3DModelView = {
        let view = Add3DModelView(
            viewModel: objectViewModel, title: "Import 3D Object")
        view.isHidden = true
        return view
    }()

    lazy var cameraButton: CameraButtons = {
        let btn = CameraButtons()
        btn.alpha = 0
        btn.isHidden = true
        btn.delegate = self
        return btn
    }()

    lazy var controlButton: ControlButtons = {
        let btn = ControlButtons()
        btn.alpha = 0
        btn.isHidden = true
        return btn
    }()

    lazy var pdfView: PdfView = {
        let view = PdfView()
        view.isHidden = true
        view.delegate = self
        return view
    }()

    lazy var showPartsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "hand.tap.fill"), for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 40
        btn.layer.masksToBounds = true
        btn.isHidden = true
        // Shadow
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowRadius = 4
        btn.addTarget(
            self, action: #selector(didTapShowPartsButton),
            for: .primaryActionTriggered)
        return btn
    }()

    // =============================================================
    //  MARK: – Lifecycle
    // =============================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrowDelegate = self
        
        configureView()
        configureObservers()
        initializeManagers()
        bindViewModel()
        initializeArrow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
        resumeRecordingIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arDisplayView.cleanupResources()
        arDisplayView.arView.delegate = nil
        arDisplayView.arView.session.delegate = nil
        cancellables.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        arDisplayView.cleanupResources()
    }

    deinit {
        os_log(
            "ARViewController deinit – observers removed", log: .default,
            type: .info)
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
    }
}

// =============================================================
//  MARK: – Lifecycle Helpers
// =============================================================
extension ARViewController {

    /// High‑level view configuration (UI layout, delegates, gestures…)
    fileprivate func configureView() {
        setupUIHierarchy()
        layoutUI()
        setupARDelegates()
        configureForMediaCapture()  // existing helper
        setupLoadingView()
        setupGestures()
    }

    /// Attach session / renderer delegates once.
    fileprivate func setupARDelegates() {
        arDisplayView.arView.delegate = self
        arDisplayView.arView.session.delegate = self
    }

    /// Build UI tree (was `setup()`).
    fileprivate func setupUIHierarchy() {
        arDisplayView.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        rightBarButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        controlButton.translatesAutoresizingMaskIntoConstraints = false
        addMachineView.translatesAutoresizingMaskIntoConstraints = false
        addObjectView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        // Order matters – add subviews then constraints
        [
            arDisplayView, coachingOverlay, menuButton, rightBarButton,
            cameraButton, controlButton, addMachineView, addObjectView,
            pdfView, showPartsButton,
        ].forEach(view.addSubview(_:))
    }

    /// Keep original `layout()` call (assumes user had Auto Layout code there).
    fileprivate func layoutUI() { layout() }

    /// Bind for app foreground / background notifications.
    fileprivate func configureObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    /// Heavy managers that rely on `arDisplayView`.
    fileprivate func initializeManagers() {
        modelManager = ARModelManager(
            arView: arDisplayView.arView,
            arDisplayView: arDisplayView,
            focusSquare: focusSquare)
        partsViewModel = ARPartsViewModel(modelManager: modelManager)
        observeLoadingProgress()
    }

    /// Resume video recording if the user left mid‑record.
    fileprivate func resumeRecordingIfNeeded() {
        if viewModel.isRecording { viewModel.toggleRecording() }
    }

    /// Start / restart AR session + overlays.
    fileprivate func startARSession() {
        arDisplayView.isHidden = false
        arDisplayView.startSession()
        setupCoachingOverlay()
        setupFocusSquare()
    }
}

// =============================================================
//  MARK: – Combine Bindings
// =============================================================
extension ARViewController {

    /// Central place for all Combine subscriptions.
    fileprivate func bindViewModel() {
        bindPartsViewModel()
        bindSelectedParts()
    }

    /// Bind logging & parts count.
    fileprivate func bindPartsViewModel() {
        partsViewModel.$logMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.arDisplayView.showLog($0) }
            .store(in: &cancellables)

        partsViewModel.$currentModelParts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.showPartsButton.isHidden = $0.isEmpty }
            .store(in: &cancellables)
    }

    /// Observe the arrow‑highlight selection set.
    fileprivate func bindSelectedParts() {
        partsViewModel.$selectedParts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSet in
                guard let self else { return }
                let current = Set(arrows.keys)
                let toAdd = newSet.subtracting(current)
                let toRemove = current.subtracting(newSet)
                toAdd.forEach { self.attachArrow(to: $0) }
                toRemove.forEach { self.detachArrow(from: $0) }
            }
            .store(in: &cancellables)
    }

    /// Observe progress from `ARModelManager`.
    fileprivate func observeLoadingProgress() {
        modelManager.loadingProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title, progress in
                self?.loadingView.updateProgress(
                    title: title, progress: progress)
                guard progress >= 1 else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.loadingView.hideLoading()
                    self?.isLoadingModel = false
                }
            }
            .store(in: &cancellables)
    }
}

// =============================================================
//  MARK: – Loading View
// =============================================================
extension ARViewController {
    fileprivate func setupLoadingView() {
        loadingView = ARLoadingView(frame: view.bounds)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        loadingView.isHidden = true
    }
}


// =============================================================
//  MARK: – Add3DModelViewDelegate
// =============================================================
extension ARViewController: Add3DModelViewDelegate {

    private enum ViewKind { case machine, object }

    // -------------------------------
    //  CLEAR / CLOSE
    // -------------------------------
    func clearButtonTapped(from view: Add3DModelView) {
        let kind: ViewKind = (view == addMachineView) ? .machine : .object
        switch kind {
        case .machine:
            partsViewModel.clearAll()
            removeAllArrows()
            hideModelView(view)
        case .object:
            modelManager.cleanupResources()
            arDisplayView.showLog("🧹 Objects cleared from scene.")
        }
        currentlyManipulatedNode = nil
        initialScaleForPinch = nil
        updatePartsButtonVisibility()
    }

    func closeButtonTapped(from view: Add3DModelView) {
        hideModelView(view)
    }

    // -------------------------------
    //  SELECT / LOAD / PLACE
    // -------------------------------
    func modelSelected(_ model: MachineModel, from view: Add3DModelView) {
        guard !isLoadingModel else {
            arDisplayView.showLog("⏳ Already loading a model, please wait…")
            return
        }
        isLoadingModel = true
        let kind: ViewKind = (view == addObjectView) ? .object : .machine
        hideModelView(view)
        if isMenuOpened { toggleMenu() }

        Task { [weak self] in
            guard let self else { return }
            defer { isLoadingModel = false }
            do {
                // 1️⃣ Load model
                let node = try await modelManager.loadModel(
                    named: model.id, title: model.title)
                currentlyManipulatedNode = node

                // 2️⃣ Place model
                guard modelManager.placeModel(node, title: model.id) else {
                    arDisplayView.showLog("❌ Could not determine placement.")
                    currentlyManipulatedNode = nil
                    return
                }

                arDisplayView.showLog("✅ \(model.title) placed.")
                modelManager.printModelHierarchy(from: node)  // DEBUG

                // 3️⃣ Post‑placement UI adjustments
                switch kind {
                case .machine:
                    partsViewModel.isLoading = true
                    partsViewModel.loadModelParts(from: node)
                    partsViewModel.isLoading = false
                    rightBarButton.isHidden = true
                case .object:
                    rightBarButton.isHidden = false
                }
                updatePartsButtonVisibility()
            } catch {
                arDisplayView.showLog(
                    "❌ Failed to load \(model.title): \(error.localizedDescription)"
                )
                currentlyManipulatedNode = nil
            }
        }
    }

    // -------------------------------
    //  Helpers
    // -------------------------------
    func updatePartsButtonVisibility() {
        showPartsButton.isHidden = partsViewModel.currentModelParts.isEmpty
    }
}

// =============================================================
//  MARK: – UI Actions / Helpers
// =============================================================
extension ARViewController {

    @objc fileprivate func didTapShowPartsButton() {
        let sheet = UIHostingController(
            rootView: ShowModelPartsView(viewModel: partsViewModel))
        if let pres = sheet.sheetPresentationController {
            pres.detents = [.large()]
            pres.prefersGrabberVisible = true
        }
        present(sheet, animated: true)
    }

    fileprivate func hideModelView(_ view: UIView) { view.isHidden = true }
}

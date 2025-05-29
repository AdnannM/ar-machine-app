//
//  ARLoadingView.swift
//  ARViewUIKit
//
//  Created by Adnann Muratovic on 09.05.25.
//

import UIKit

/// A custom loading view with animated progress ring and pulse effects
/// Used for displaying loading states in AR applications
class ARLoadingView: UIView {

    // MARK: - UI Components
    private let containerView = UIView()
    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .dark))

    // Progress Ring Layers
    private let progressBackgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    // Text Labels
    private let titleLabel = UILabel()
    private let percentageLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Loading Animation Dots
    private let dotsContainer = UIView()
    private let dot1 = UIView()
    private let dot2 = UIView()
    private let dot3 = UIView()

    // MARK: - Properties

    /// Controls the visibility and animation state of the loading view
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                showLoadingAnimation()
            } else {
                hideLoadingAnimation()
            }
        }
    }

    // Configuration Constants
    private let progressRingRadius: CGFloat = 45
    private let containerWidth: CGFloat = 280
    private let containerHeight: CGFloat = 200
    private let dotSize: CGFloat = 6

    // State Properties
    private var currentProgress: Float = 0

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        setupBlurBackground()
        setupContainer()
        setupProgressRing()
        setupLabels()
        setupLoadingDots()
        setupConstraints()

        // Set initial state
        isHidden = true
        alpha = 0
    }

    private func setupBlurBackground() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }

    private func setupContainer() {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.1).cgColor

        // Add glow effect
        containerView.layer.shadowColor = UIColor.systemBlue.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 15

        addSubview(containerView)
    }

    // MARK: - Public Methods

    /// Updates the loading view with current progress
    /// - Parameters:
    ///   - title: The title to display (e.g., "3D Model")
    ///   - progress: Progress value from 0.0 to 1.0
    func updateProgress(title: String, progress: Float) {
        currentProgress = progress

        // Update labels
        titleLabel.text = "Loading \(title)..."
        percentageLabel.text = "\(Int(progress * 100))%"

        // Update subtitle based on progress
        switch progress {
        case 0..<0.3:
            subtitleLabel.text = "Initializing..."
        case 0.3..<0.6:
            subtitleLabel.text = "Processing model..."
        case 0.6..<0.9:
            subtitleLabel.text = "Almost there..."
        default:
            subtitleLabel.text = "Finalizing..."
        }

        // Show if not already visible
        if !isLoading {
            isLoading = true
        }

        // Animate progress ring
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        progressLayer.strokeEnd = CGFloat(progress)
        CATransaction.commit()

        // Add completion animation
        if progress >= 1.0 {
            addCompletionAnimation()
        }
    }

    /// Hides the loading view with animation
    func hideLoading() {
        isLoading = false
    }
}

// MARK: - Progress Ring Setup

extension ARLoadingView {

    fileprivate func setupProgressRing() {
        let center = CGPoint(x: 0, y: 0)
        let circularPath = createCircularPath(
            center: center, radius: progressRingRadius)

        // Configure background ring
        configureProgressBackgroundLayer(with: circularPath)

        // Configure progress ring
        configureProgressLayer(with: circularPath)

        // Add gradient effect
        addGradientLayer()
    }

    fileprivate func createCircularPath(center: CGPoint, radius: CGFloat)
        -> UIBezierPath
    {
        UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
    }

    fileprivate func configureProgressBackgroundLayer(with path: UIBezierPath) {
        progressBackgroundLayer.path = path.cgPath
        progressBackgroundLayer.strokeColor =
            UIColor.white.withAlphaComponent(0.1).cgColor
        progressBackgroundLayer.lineWidth = 6
        progressBackgroundLayer.fillColor = UIColor.clear.cgColor
        progressBackgroundLayer.lineCap = .round
        progressBackgroundLayer.position = CGPoint(x: containerWidth / 2, y: 70)
        progressBackgroundLayer.bounds = CGRect(
            x: -progressRingRadius - 10, y: -progressRingRadius - 10,
            width: (progressRingRadius + 10) * 2,
            height: (progressRingRadius + 10) * 2)

        containerView.layer.addSublayer(progressBackgroundLayer)
    }

    fileprivate func configureProgressLayer(with path: UIBezierPath) {
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 6
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        progressLayer.position = CGPoint(x: containerWidth / 2, y: 70)
        progressLayer.bounds = CGRect(
            x: -progressRingRadius - 10, y: -progressRingRadius - 10,
            width: (progressRingRadius + 10) * 2,
            height: (progressRingRadius + 10) * 2)
    }

    fileprivate func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(
            x: 0, y: 0, width: containerWidth, height: 140)
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.cyan.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.mask = progressLayer

        containerView.layer.addSublayer(gradientLayer)
    }
}

// MARK: - UI Elements Setup

extension ARLoadingView {

    fileprivate func setupLabels() {
        configureTitleLabel()
        configurePercentageLabel()
        configureSubtitleLabel()
    }

    fileprivate func configureTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.text = "Loading 3D Model"
        containerView.addSubview(titleLabel)
    }

    fileprivate func configurePercentageLabel() {
        percentageLabel.textColor = .white
        percentageLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        percentageLabel.textAlignment = .center
        percentageLabel.text = "0%"
        containerView.addSubview(percentageLabel)
    }

    fileprivate func configureSubtitleLabel() {
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Please wait..."
        containerView.addSubview(subtitleLabel)
    }

    fileprivate func setupLoadingDots() {
        [dot1, dot2, dot3].forEach { dot in
            dot.backgroundColor = UIColor.systemBlue
            dot.layer.cornerRadius = dotSize / 2
            dotsContainer.addSubview(dot)
        }
        containerView.addSubview(dotsContainer)
    }
}

// MARK: - Layout

extension ARLoadingView {

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        disableAutoresizingMaskForViews([
            titleLabel, percentageLabel, subtitleLabel,
            dotsContainer, dot1, dot2, dot3,
        ])

        NSLayoutConstraint.activate(
            [
                // Container view
                containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
                containerView.widthAnchor.constraint(
                    equalToConstant: containerWidth),
                containerView.heightAnchor.constraint(
                    equalToConstant: containerHeight),

                // Percentage label (center of progress ring)
                percentageLabel.centerXAnchor.constraint(
                    equalTo: containerView.centerXAnchor),
                percentageLabel.centerYAnchor.constraint(
                    equalTo: containerView.topAnchor, constant: 70),

                // Title label
                titleLabel.topAnchor.constraint(
                    equalTo: containerView.topAnchor, constant: 130),
                titleLabel.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor, constant: -20),

                // Subtitle label
                subtitleLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor, constant: 5),
                subtitleLabel.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor, constant: 20),
                subtitleLabel.trailingAnchor.constraint(
                    equalTo: containerView.trailingAnchor, constant: -20),

                // Dots container
                dotsContainer.bottomAnchor.constraint(
                    equalTo: containerView.bottomAnchor, constant: -15),
                dotsContainer.centerXAnchor.constraint(
                    equalTo: containerView.centerXAnchor),
                dotsContainer.widthAnchor.constraint(equalToConstant: 40),
                dotsContainer.heightAnchor.constraint(equalToConstant: dotSize),
            ] + createDotsConstraints())
    }

    private func createDotsConstraints() -> [NSLayoutConstraint] {
        [
            // Dot 1
            dot1.leadingAnchor.constraint(equalTo: dotsContainer.leadingAnchor),
            dot1.centerYAnchor.constraint(equalTo: dotsContainer.centerYAnchor),
            dot1.widthAnchor.constraint(equalToConstant: dotSize),
            dot1.heightAnchor.constraint(equalToConstant: dotSize),

            // Dot 2
            dot2.centerXAnchor.constraint(equalTo: dotsContainer.centerXAnchor),
            dot2.centerYAnchor.constraint(equalTo: dotsContainer.centerYAnchor),
            dot2.widthAnchor.constraint(equalToConstant: dotSize),
            dot2.heightAnchor.constraint(equalToConstant: dotSize),

            // Dot 3
            dot3.trailingAnchor.constraint(
                equalTo: dotsContainer.trailingAnchor),
            dot3.centerYAnchor.constraint(equalTo: dotsContainer.centerYAnchor),
            dot3.widthAnchor.constraint(equalToConstant: dotSize),
            dot3.heightAnchor.constraint(equalToConstant: dotSize),
        ]
    }

    private func disableAutoresizingMaskForViews(_ views: [UIView]) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}

// MARK: - Animations

extension ARLoadingView {

    fileprivate func showLoadingAnimation() {
        isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = CGAffineTransform(
                scaleX: 1.0, y: 1.0)
        }

        animateDots()
        addPulseAnimation()
    }

    fileprivate func hideLoadingAnimation() {
        UIView.animate(
            withDuration: 0.3, delay: 0, options: .curveEaseIn,
            animations: {
                self.alpha = 0
                self.containerView.transform = CGAffineTransform(
                    scaleX: 0.9, y: 0.9)
            }
        ) { _ in
            self.isHidden = true
            self.resetProgress()
        }
    }

    fileprivate func animateDots() {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [0.3, 1.0, 0.3]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 1.2
        animation.repeatCount = .infinity

        dot1.layer.add(animation, forKey: "dotAnimation")

        animation.beginTime = CACurrentMediaTime() + 0.4
        dot2.layer.add(animation, forKey: "dotAnimation")

        animation.beginTime = CACurrentMediaTime() + 0.8
        dot3.layer.add(animation, forKey: "dotAnimation")
    }

    fileprivate func addPulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.6
        pulseAnimation.duration = 1.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(
            name: .easeInEaseOut)

        containerView.layer.add(pulseAnimation, forKey: "pulse")
    }

    fileprivate func addCompletionAnimation() {
        // Flash effect
        let flash = CABasicAnimation(keyPath: "strokeColor")
        flash.fromValue = UIColor.systemBlue.cgColor
        flash.toValue = UIColor.systemGreen.cgColor
        flash.duration = 0.3
        flash.autoreverses = true

        progressLayer.add(flash, forKey: "completion")

        // Scale animation
        UIView.animate(withDuration: 0.2) {
            self.percentageLabel.transform = CGAffineTransform(
                scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.percentageLabel.transform = .identity
            }
        }

        // Update subtitle
        subtitleLabel.text = "Complete! ✨"
    }

    fileprivate func resetProgress() {
        currentProgress = 0
        progressLayer.strokeEnd = 0
        percentageLabel.text = "0%"
        titleLabel.text = "Loading 3D Model"
        subtitleLabel.text = "Please wait..."
        containerView.transform = .identity
    }
}

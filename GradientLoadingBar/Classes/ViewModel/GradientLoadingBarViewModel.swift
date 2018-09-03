//
//  GradientLoadingBarViewModel.swift
//  GradientLoadingBar
//
//  Created by Felix Mau on 26.12.17.
//

import Foundation
import Observable

/// The `GradientLoadingBarViewModel` class is responsible for the visibility state of the gradient view.
class GradientLoadingBarViewModel {
    // MARK: - Types

    ///
    struct AnimatedVisibilityUpdate: Equatable {
        ///
        static let zero = AnimatedVisibilityUpdate(duration: 0.0, alpha: 0.0, isHidden: true)

        /// The duration for the visibility update.
        let duration: TimeInterval

        /// New alpha value.
        let alpha: CGFloat

        /// Boolean flag, whether the view should be hidden after the animation is finished.
        let isHidden: Bool
    }

    // MARK: - Public properties

    /// Boolean flag determinating whether gradient view is currently visible.
    let isVisible: Observable<AnimatedVisibilityUpdate> = Observable(.zero)

    /// Boolean flag determinating whether gradient view is currently visible.
    let superview: Observable<UIView?> = Observable(nil)

    // MARK: - Private properties

    /// Configuration with durations for each animation.
    private let durations: Durations

    // MARK: - Dependencies

    private let sharedApplication: UIApplicationProtocol
    private let notificationCenter: NotificationCenter

    // MARK: - Constructor

    init(superview: UIView?,
         durations: Durations,
         sharedApplication: UIApplicationProtocol = UIApplication.shared,
         notificationCenter: NotificationCenter = .default) {
        self.durations = durations
        self.sharedApplication = sharedApplication
        self.notificationCenter = notificationCenter

        if let superview = superview {
            self.superview.value = superview
        } else {
            // If the initializer is called from `appDelegate`, the key window is not available yet.
            // Therefore we setup an observer to inform the listeners when it's ready.
            notificationCenter.addObserver(self,
                                           selector: #selector(didReceiveUiWindowDidBecomeKeyNotification(_:)),
                                           name: .UIWindowDidBecomeKey,
                                           object: nil)
        }
    }

    // MARK: - Private methods

    @objc private func didReceiveUiWindowDidBecomeKeyNotification(_: Notification) {
        guard let keyWindow = sharedApplication.keyWindow else { return }

        // Prevent informing the listeners multiple times.
        notificationCenter.removeObserver(self)

        //
        superview.value = keyWindow
    }

    // MARK: - Public methods

    /// Fades in the gradient loading bar.
    func show() {
        isVisible.value = AnimatedVisibilityUpdate(duration: durations.fadeIn,
                                                   alpha: 1.0,
                                                   isHidden: false)
    }

    /// Fades out the gradient loading bar.
    func hide() {
        isVisible.value = AnimatedVisibilityUpdate(duration: durations.fadeOut,
                                                   alpha: 0.0,
                                                   isHidden: true)
    }

    /// Toggle visiblity of gradient loading bar.
    func toggle() {
        if isVisible.value.isHidden {
            show()
        } else {
            hide()
        }
    }
}

// MARK: - Helper

/// This allows mocking `UIApplication` in tests.
protocol UIApplicationProtocol {
    var keyWindow: UIWindow? { get }
}

extension UIApplication: UIApplicationProtocol {}

//
//  LottieView.swift
//  BookSearch
//
//  Created by Krishnappa, Harsha on 14/08/2024.
//

import SwiftUI
import Lottie

/// A  view that integrates Lottie animations using `UIViewRepresentable`.
/// This view requires the Lottie framework to be included in the project.
struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    /// The name of the Lottie animation file to be loaded, Stored in bundle as .json file
    let filename: String
    /// This property is configured with the specified animation file and added to the view hierarchy.
    let animationView = LottieAnimationView()
    /// A Boolean value indicating whether the animation is paused.
    let isPaused: Bool
    
    /// Creates and configures the `UIView` that hosts the `LottieAnimationView`.
    /// - Parameter context: The context in which the view is created.
    /// - Returns: A `UIView` instance containing the `LottieAnimationView`.
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        
        let animation = LottieAnimation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        return view
    }
    
    /// This method handles pausing or playing the animation based on the `isPaused` property.
    ///
    /// - Parameters:
    ///   - uiView: The `UIView` instance to be updated.
    ///   - context: The context in which the view is updated.
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        if isPaused {
            context.coordinator.parent.animationView.pause()
        } else {
            context.coordinator.parent.animationView.play()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: LottieView
        
        init(_ parent: LottieView) {
            self.parent = parent
        }
    }
}

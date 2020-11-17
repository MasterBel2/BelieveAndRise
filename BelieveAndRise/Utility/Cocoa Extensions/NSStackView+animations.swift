//
//  NSStackView+animations.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 31/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

extension NSStackView {

    /// Inserts subviews at the specified indexes, with an animation.
    ///
    /// This method will set all hidden views to visible to ensure that calculations are correct.
    ///
    /// - note: Requires `newViews.count == newIndexes.count`
    func animateInsertion(ofArrangedSubviews newViews: [NSView], at newIndexes: [Int], completionHandler: (() -> Void)? = nil) {
        guard newViews.count == newIndexes.count else {
            fatalError("View/index count does not match.")
        }
        newViews.forEach({ $0.isHidden = false })

        // Cache initial view data

        let initialStackViewFrame = frame
        let preexistingViews = arrangedSubviews
        let preexistingViewsFrames = preexistingViews.map({ $0.frame })

        // Update to final state

        newViews.join(with: newIndexes).forEach(self.insertArrangedSubview(_:at:))
        layoutSubtreeIfNeeded()

        // Cache final view data

        let finalStackViewFrame = frame
        let finalViews = arrangedSubviews
        let finalFrames = finalViews.map({ $0.frame })

        // Free views for independant animation

        finalViews.forEach({
            removeArrangedSubview($0)
        })

        // Set initial stack view state

        let widthConstraint = widthAnchor.constraint(equalToConstant: initialStackViewFrame.width)
        let heightConstraint = heightAnchor.constraint(equalToConstant: initialStackViewFrame.height)
        widthConstraint.isActive = true
        heightConstraint.isActive = true

        // Reset to initial state
        newViews.forEach({$0.alphaValue = 0})
        preexistingViews.join(with: preexistingViewsFrames).forEach({ $0.frame = $1 })
        newViews.join(with: newIndexes).enumerated().forEach({
            $0.element.0.frame = preexistingViews[$0.element.1 - ($0.offset + 1)].frame
        })

        subviews.forEach({ ($0 as? NSControl)?.isEnabled = false })

        // Animate!

        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = true
            finalViews.join(with: finalFrames).forEach({ $0.animator().frame = $1 })
            newViews.forEach({$0.animator().alphaValue = 1})
            widthConstraint.animator().constant = finalStackViewFrame.width
            heightConstraint.animator().constant = finalStackViewFrame.height
        }, completionHandler: {
            // Cleanup
            finalViews.forEach({
                self.addArrangedSubview($0)
            })
            widthConstraint.isActive = false
            heightConstraint.isActive = false
            self.subviews.forEach({ ($0 as? NSControl)?.isEnabled = true })
            completionHandler?()
        })
    }

    /// Removes and hides the arranged subviews at the given indexes, with an animation.
    func animateRemoval(ofViewsAt indexes: [Int], completionHandler: (() -> Void)? = nil) {
        animateRemoval(ofArrangedSubviews: indexes.map({ arrangedSubviews[$0] }), completionHandler: completionHandler)
    }

    /// Removes and hides the arranged subviews, with an animation.
    ///
    /// Views will remain as hidden subviews of the stackview after being removed from the `arrangedSubviews` array.
    func animateRemoval(ofArrangedSubviews views: [NSView], completionHandler: (() -> Void)? = nil) {

        // Cache initial view data

        let initialStackViewFrame = frame
        let initialFrames = arrangedSubviews.map({ $0.frame })
        let initialViews = arrangedSubviews

        // Update to final state

        views.forEach(removeArrangedSubview(_:))
        layoutSubtreeIfNeeded()

        // Cache final view data

        let finalFrames = arrangedSubviews.map({ $0.frame })
        let finalViews = arrangedSubviews
        let finalStackViewFrame = frame

        // Set initial subview state

        views.forEach({ $0.alphaValue = 1 })
        finalViews.forEach({ removeArrangedSubview($0) })
        initialViews.join(with: initialFrames).forEach({ $0.frame = $1 })

        // Set initial stack view

        let widthConstraint = widthAnchor.constraint(equalToConstant: initialStackViewFrame.width)
        let heightConstraint = heightAnchor.constraint(equalToConstant: initialStackViewFrame.height)
        widthConstraint.isActive = true
        heightConstraint.isActive = true

        subviews.forEach({ ($0 as? NSControl)?.isEnabled = false })

        // Animate!

        NSAnimationContext.runAnimationGroup({ context in
            finalViews.join(with: finalFrames).forEach({ $0.animator().frame = $1 })
            views.forEach({ $0.animator().alphaValue = 0 })
            widthConstraint.animator().constant = finalStackViewFrame.width
            heightConstraint.animator().constant = finalStackViewFrame.height
        }, completionHandler: {
            // Cleanup
            finalViews.forEach({ self.addArrangedSubview($0) })
            widthConstraint.isActive = false
            heightConstraint.isActive = false
            views.forEach({ $0.isHidden = true })
            self.subviews.forEach({ ($0 as? NSControl)?.isEnabled = true })
            completionHandler?()
        })
    }
}

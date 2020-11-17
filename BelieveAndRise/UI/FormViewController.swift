//
//  FormViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 31/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

class FormViewController: NSViewController {
    @IBOutlet var titleField: NSTextField!
    @IBOutlet var nextButton: NSButton!
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var buttonStackView: NSStackView!
    @IBOutlet var structureStackView: NSStackView!
    @IBOutlet var contentContainerView: NSView!

    override var nibName: NSNib.Name? {
        return "FormViewController"
    }

    var pages: [FormPageViewController]!
    var currentPage: FormPageViewController {
        return pages[currentPageIndex]
    }


    var currentPageIndex = 0 {
        didSet {
            guard (0..<pages.count).contains(currentPageIndex) else {
                fatalError("[formViewController] Could not find page \(currentPageIndex).")
            }
            pageDidChange()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Removes the placeholder view that's there just to make the NIB load
        contentContainerView.subviews[0].removeFromSuperview()

        addCurrentPage()
    }

    @IBAction func cancelButton(_ sender: Any) {
    }

    @IBAction func nextPage(_ sender: Any) {
        currentPageIndex += 1
    }

    @discardableResult
    private func addCurrentPage() -> NSView {
        let newView = pages[currentPageIndex].view
        newView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(newView)
        setConstraints()

        return newView
    }

    private func setConstraints() {
        let topConstraint = contentContainerView.topAnchor.constraint(equalTo: currentPage.view.topAnchor)
        let bottomConstraint = contentContainerView.bottomAnchor.constraint(equalTo: currentPage.view.bottomAnchor)
        let leftConstraint = contentContainerView.rightAnchor.constraint(equalTo: currentPage.view.rightAnchor)
        let rightConstraint = contentContainerView.leftAnchor.constraint(equalTo: currentPage.view.leftAnchor)
        topConstraint.isActive = true
        leftConstraint.isActive = true
        rightConstraint.isActive = true
        bottomConstraint.isActive = true
        contentContainerViewTopConstraint = topConstraint
        contentContainerViewBottomConstraint = bottomConstraint
        contentContainerViewLeftConstraint = leftConstraint
        contentContainerViewRightConstraint = rightConstraint
    }

    private func invalidateConstraints() {
        contentContainerViewTopConstraint?.isActive = false
        contentContainerViewRightConstraint?.isActive = false
        contentContainerViewLeftConstraint?.isActive = false
        contentContainerViewBottomConstraint?.isActive = false
    }

    private var contentContainerViewTopConstraint: NSLayoutConstraint?
    private var contentContainerViewRightConstraint: NSLayoutConstraint?
    private var contentContainerViewLeftConstraint: NSLayoutConstraint?
    private var contentContainerViewBottomConstraint: NSLayoutConstraint?

    private func pageDidChange() {

        // Note that view of the view controller should be loaded first to provide any view controller setup that happens in the viewDidLoad.
        // Yeah, we shouldn't have to worry about that…

        let oldView = contentContainerView.subviews[0]
        let newView = addCurrentPage()
        newView.frame.origin = newView.frame.origin.applying(CGAffineTransform(translationX: newView.frame.width, y: 0))
        NSAnimationContext.runAnimationGroup({ context in
            oldView.frame.origin = oldView.frame.origin.applying(CGAffineTransform(translationX: -oldView.frame.width, y: 0))
            newView.frame.origin = .zero
            contentContainerView.frame = newView.frame
        }, completionHandler: {
            oldView.removeFromSuperview()
            self.setConstraints()
        })

        if nextButton.isHidden, currentPage.requiresNextButton {
            buttonStackView.animateInsertion(ofArrangedSubviews: [nextButton], at: [1])
        } else if !nextButton.isHidden, !currentPage.requiresNextButton {
            buttonStackView.animateRemoval(ofArrangedSubviews: [nextButton])
        }

        if let title = pages[currentPageIndex].title {
            if titleField.isHidden {
                titleField.stringValue = title
                structureStackView.animateInsertion(ofArrangedSubviews: [titleField], at: [1])
            }
            titleField.animator().stringValue = title
        } else if !titleField.isHidden {
            structureStackView.animateRemoval(ofArrangedSubviews: [titleField])
        }
    }

//    func addPage(_ page: FormPageViewController) {
//        page.form = self
//    }
//
//    func removePage(at index: Int) {
//        let page = pages[index]
//        page.form = nil
//        pages.remove(at: index)
//    }
}

class FormPageViewController: NSViewController {
    weak var form: FormViewController?
    var requiresNextButton: Bool {
        return true
    }
}

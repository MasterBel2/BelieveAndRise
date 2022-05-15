//
//  DialogSheet.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 17/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/**
 An input dialogue sheet template intended to be subclassed.

 This class is intended only to be used as a sheet, calling `dismiss(_:)` to dismiss itself when its task is complete.

 Subclasses should provide input controls and an operation to be executed when the user is finished editing. Input controls should be added to the `controlsToDisable` array
 */
class DialogSheet: NSViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
        controlsToDisable.append(doneButton)
        controlsToDisable.append(cancelButton)
    }

    // MARK: - Interface

    /// The button associated with triggering the sheet's associated operation.
    @IBOutlet weak var doneButton: NSButton!
    /// The button associated with abandoning editing and dismissing the sheet.
    @IBOutlet weak var cancelButton: NSButton!
    /// An indeterminate progress indicator that will indicate that the operation is taking place, and the sheet is waiting for a response.
    @IBOutlet weak var spinner: NSProgressIndicator!

    /// Controls that should be disabled while the operation is taking place, and reenabled when editing resumes.
    var controlsToDisable: [NSControl] = []

    // MARK: - Actions

    /// Abandons the user's edits and dismisses the sheet.
    @IBAction private func cancelOperations(_ sender: Any?) {
        didCancelOperation?(self)
    }

    /// Submits the user's edits.
    @IBAction private func submitOperation(_ sender: Any) {
        guard let operation = operation else {
            fatalError("Failed to submit operation: no operation defined for \(self)")
        }
        if operation(self) {
            displayChangesPending()
        } else {
            operationDidSucceed()
        }
    }

    // MARK: - API

    typealias Operation = (DialogSheet) -> Bool
    /// The operation that will be initiated when the user is done editing and wishes to submit their changes. Operations should return `true` if they are asynchronous and require a pending state to be displayed before the operation complets.
    ///
    /// Since the sheet is designed around gathering input for an operation, there are no checks for the existence of the operation block (hence the force unwrap). It is assumed that the block will be provided immidiately after initialisation.
    ///
    /// The operation is called in `submitOperation(_:)`.
    var operation: Operation!
    /// Allows cleanup relating to 
    var didCancelOperation: ((DialogSheet) -> Void)?

    /// Indicates that the operation has completed with an error.
    ///
    /// The view controller will display a message to explain why the error has failed, and reenables the UI to allow the user to continue editing until their changes may be sumbitted without causing an error.
    func operationDidFailWithError(_ errorMessage: String) {
        // TODO: Error message must be displayed here.
        print("\(self): Operation failed with error: \(errorMessage)")
        reenableEditing()
    }

    /// Indicates the operation has completed succesfully and the sheet may be dismissed.
    func operationDidSucceed() {}

    // MARK: - Private helpers

    /// Disables the interface and presents a spinner to indicate work in progress.
    private func displayChangesPending() {
        controlsToDisable.forEach({$0.isEnabled = false})
        spinner.isHidden = false
        spinner.startAnimation(self)
    }

    /// Reenables the interface, and hides the spinner to allow the user to continue editing.
    private func reenableEditing() {
        controlsToDisable.forEach({$0.isEnabled = true})
        spinner.stopAnimation(self)
        spinner.isHidden = true
    }
}

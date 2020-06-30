//
//  SingleTextInputDialogSheet.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 19/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/**
 A dialog sheet with a single text input.
 */
final class SingleTextInputDialogSheet: DialogSheet {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldTitleField.stringValue = textFieldTitle
        controlsToDisable.append(textField)
    }

    // MARK: - Interface

    /// A static text field that displays the title of the editable text field.
    @IBOutlet var textFieldTitleField: NSTextField!
    /// The text input field.
    @IBOutlet var textField: NSTextField!

    // MARK: - Properties

    /// The title string to display above the text field.
    var textFieldTitle: String = "Title" {
        didSet {
            if isViewLoaded {
                textFieldTitleField.stringValue = textFieldTitle
            }
        }
    }
}

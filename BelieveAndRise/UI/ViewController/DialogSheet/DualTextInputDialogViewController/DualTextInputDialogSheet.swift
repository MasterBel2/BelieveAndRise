//
//  DualTextInputDialogSheet.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 19/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/**
 A dialog sheet with a single text input and a single secure text input.
 */
final class DualTextInputDialogSheet: DialogSheet {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        secureTextFieldTitleField.stringValue = secureTextFieldTitle
        textFieldTitleField.stringValue = textFieldTitle
        textField.placeholderString = textFieldPlaceholder
        controlsToDisable.append(textField)
        controlsToDisable.append(secureTextField)
    }

    // MARK: - Interface

    /// A static text field that displays the title of the editable text field.
    @IBOutlet var textFieldTitleField: NSTextField!
    /// The text input field.
    @IBOutlet var textField: NSTextField!

    /// A static text field that displays the title of the editable secure text field.
    @IBOutlet var secureTextFieldTitleField: NSTextField!
    /// The secure text input field.
    @IBOutlet var secureTextField: NSSecureTextField!

    // MARK: - Properties

    /// The placeholder text to be displayed in `textField`.
    var textFieldPlaceholder: String? {
        didSet {
            if isViewLoaded {
                textField.placeholderString = textFieldPlaceholder
            }
        }
    }

    /// The title string to display above the text field.
    var textFieldTitle: String = "Username" {
        didSet {
            if isViewLoaded {
                textFieldTitleField.stringValue = textFieldTitle
            }
        }
    }

    /// The title string to display above the secure text field.
    var secureTextFieldTitle: String = "Password" {
        didSet {
            if isViewLoaded {
                secureTextFieldTitleField.stringValue = secureTextFieldTitle
            }
        }
    }
}

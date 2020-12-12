//
//  AccountViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

/// A view controller for presenting account metadata.
final class AccountViewController: NSViewController {

    @IBOutlet var accountNameField: NSTextField!
    @IBOutlet var emailField: NSTextField!
    @IBOutlet var statisticsField: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var editAccountNameButton: NSButton!
    @IBOutlet var editEmailAddressButton: NSButton!

	/// The controller for account information.
    weak var accountInfoController: AccountInfoController?

	/// Information about the uer's account.
	///
	/// Asynchronously loaded.
    var accountData: AccountData? {
        didSet {
            guard let accountData = accountData else {
                return
            }

            emailField.stringValue = accountData.email
            statisticsField.stringValue = "\(accountData.ingameHours) hours played"

            if let registrationDate = accountData.registrationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let dateString = dateFormatter.string(from: registrationDate)
                statisticsField.stringValue += " since \(dateString)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = false
        spinner.startAnimation(self)

        emailField.isHidden = true
        statisticsField.isHidden = true
        editAccountNameButton.isHidden = true
        editEmailAddressButton.isHidden = true

        if let username = accountInfoController?.user?.profile.fullUsername {
            display(accountName: username)
        }
        accountInfoController?.retrieveAccountData(completionBlock: display(accountData:))
    }

	/// Presents a sheet for editing the user's account name.
    @IBAction func editAccountName(_ sender: Any) {
        let viewController = DualTextInputDialogSheet()
        viewController.textFieldTitle = "New username:"
        viewController.textFieldPlaceholder = accountNameField.stringValue
        viewController.secureTextFieldTitle = "Confirm password:"
        viewController.operation = { [weak self] _ -> Bool in
            self?.accountInfoController?.renameAccount(
                to: viewController.textField.stringValue,
                password: viewController.secureTextField.stringValue,
                completionBlock: { result in
                    // We'll be logged out, so no need to update the interface
                    // (TODO: Actually maybe we should throw up an alert? Hmm.)
                    print(result)
                }
            )
            return true
        }
        presentAsSheet(viewController)
    }

	/// Presents a sheet for editing the user's email.
    @IBAction func editEmail(_ sender: Any) {
        let viewController = DualTextInputDialogSheet()
        viewController.textFieldTitle = "New email:"
        viewController.textFieldPlaceholder = accountData?.email
        viewController.secureTextFieldTitle = "Confirm password:"

        viewController.operation = { [weak self, weak viewController] _ -> Bool in
            guard let self = self,
                let viewController = viewController else {
                    return false
            }
            let newEmail = viewController.textField.stringValue
            let passwordToConfirm = viewController.secureTextField.stringValue
            self.accountInfoController?.requestVerficationCodeForChangingEmail(
                to: newEmail,
                password: viewController.secureTextField.stringValue,
                completionBlock: { errorMessage in
                    if let errorMessage = errorMessage {
                        viewController.operationDidFailWithError(errorMessage)
                    } else {
                        viewController.operationDidSucceed()
                        self.confirmEmail(newEmail, confirmedPassword: passwordToConfirm)
                    }
                }
            )
            return true
        }

        presentAsSheet(viewController)
    }

	/// Presents a sheet to receive an email verification code.
    private func confirmEmail(_ newEmail: String, confirmedPassword: String) {
        let viewController = SingleTextInputDialogSheet()
        viewController.textFieldTitle = "Confirmation code: (emailed to \(newEmail))"
        viewController.operation = { [weak self, weak viewController] _ -> Bool in
            guard let self = self,
                let viewController = viewController else {
                    return false
            }
            self.accountInfoController?.changeEmail(
                to: newEmail,
                password: confirmedPassword,
                verificationCode: viewController.textField.stringValue,
                completionBlock: { response in
                    if let response = response {
                        viewController.operationDidFailWithError(response)
                    } else {
                        viewController.operationDidSucceed()
                    }
                }
            )
            return true
        }
        presentAsSheet(viewController)
    }

	/// Presents a sheet to change a user's password.
    @IBAction func changePassword(_ sender: Any) {
        // TODO
    }

    // MARK: - Updating interface data

    private func display(accountName: String) {
        accountNameField.stringValue = accountName
        editAccountNameButton.isHidden = false
    }

    /// Hides the spinner and shows the data fields with the given data.
    private func display(accountData: AccountData) {
        // Update the presentation
        spinner.stopAnimation(self)
        spinner.isHidden = true

        emailField.isHidden = false
        editEmailAddressButton.isHidden = false
        statisticsField.isHidden = false

        // Update the data

        self.accountData = accountData
    }
}

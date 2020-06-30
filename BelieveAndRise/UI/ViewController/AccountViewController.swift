//
//  AccountViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of account metadata.
struct AccountData {
	/// The user's email address.
    let email: String
	/// The number of hours the server has recorded as the user's status has indicated that they are ingame.
    let ingameHours: Int
	/// The date the user's account was registered.
    let registrationDate: Date
}

/// Performs operations associated with modifying account information.
protocol AccountInfoDelegate: AnyObject {
	/// Attempts to change the user's email to the new email address.
    func changeEmail(to newEmailAddress: String, password: String, verificationCode: String, completionBlock: @escaping (String?) -> ())
	/// Requests a verification code to be sent to the new email address, before changing email address.
    func requestVerficationCodeForChangingEmail(to newEmailAddress: String, password: String, completionBlock: @escaping (String?) -> ())
	/// Attempts to change the user's username to the new value..
    func renameAccount(to newAccountName: String, password: String, completionBlock: @escaping (String?) -> ())
	/// Attempts to change the user's password to the new value.
    func changePassword(from oldPassword: String, to newPassword: String, completionBlock: @escaping (String?) -> ())
}

/// Displays the user's account infromation.
protocol AccountInfoDisplay {
    /// Presents the account name to the user.
    func display(accountName: String)
	/// Presents account metadata to the user.
    func display(accountData: AccountData)
}

/// A view controller for presenting account metadata.
final class AccountViewController: NSViewController, AccountInfoDisplay {

    @IBOutlet var accountNameField: NSTextField!
    @IBOutlet var emailField: NSTextField!
    @IBOutlet var statisticsField: NSTextField!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var editAccountNameButton: NSButton!
    @IBOutlet var editEmailAddressButton: NSButton!

	/// The controller for account information.
    weak var accountInfoController: AccountInfoController?
	/// The account view controller's delegate.
    weak var delegate: AccountInfoDelegate?

	/// Information about the uer's account.
	///
	/// Asynchronously loaded.
    var accountData: AccountData? {
        didSet {
            guard let accountData = accountData else {
                return
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: accountData.registrationDate)

            emailField.stringValue = accountData.email
            statisticsField.stringValue = "\(accountData.ingameHours) hours played since \(dateString)"
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
            self?.delegate?.renameAccount(
                to: viewController.textField.stringValue,
                password: viewController.secureTextField.stringValue,
                completionBlock: { _ in }
            )
            return false
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
            self.delegate?.requestVerficationCodeForChangingEmail(
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
            self.delegate?.changeEmail(
                to: newEmail,
                password: confirmedPassword,
                verificationCode: viewController.textField.stringValue,
                completionBlock: { response in
                    if let response = response {
                        viewController.operationDidFailWithError(response)
                    } else {
                        viewController.operationDidSucceed()
                    }
            })
            return true
        }
        presentAsSheet(viewController)
    }

	/// Presents a sheet to change a user's password.
    @IBAction func changePassword(_ sender: Any) {
        // TODO
    }

    // MARK: - Updating interface data

    func display(accountName: String) {
        accountNameField.stringValue = accountName
        editAccountNameButton.isHidden = false
    }

    /// Hides the spinner and shows the data fields with the given data.
    func display(accountData: AccountData) {
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

//
//  UserAuthenticationViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

/// A controller for the user authentication process.
final class UserAuthenticationViewController: DialogSheet {

    weak var unauthenticatedSession: UnauthenticatedSession?

    // MARK: - Interface connections

    @IBOutlet var contentStackView: NSStackView!
    @IBOutlet var toggleModeButton: NSButton!
    @IBOutlet var emailRow: NSView!
    @IBOutlet var confirmPasswordRow: NSView!

    @IBOutlet var usernameField: NSTextField!
    @IBOutlet var emailField: NSTextField!
    @IBOutlet var passwordField: NSSecureTextField!
    @IBOutlet var confirmPasswordField: NSSecureTextField!

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        contentStackView.removeArrangedSubview(emailRow)
        emailRow.isHidden = true
        contentStackView.removeArrangedSubview(confirmPasswordRow)
        confirmPasswordRow.isHidden = true
        prefillUsernameAndPassword()

        controlsToDisable += [usernameField, emailField, passwordField, confirmPasswordField, toggleModeButton]

        operation = { [weak self] _ -> Bool in
            guard let self = self else {
                return false
            }
            do {
                return self.inRegisterMode ? try self.submitRegister() : self.submitLogin()
            } catch {
                print(error)
                return false
            }
        }
    }

    func prefillUsernameAndPassword() {
        if let lastCredentialsPair = unauthenticatedSession?.lastCredentialsPair {
            usernameField.stringValue = lastCredentialsPair.username
            passwordField.stringValue = lastCredentialsPair.password
        }
    }

    // MARK: - Mode

    private var inRegisterMode: Bool = false
    @IBAction func toggleMode(_ sender: Any) {
        if inRegisterMode {
            contentStackView.animateRemoval(ofArrangedSubviews: [emailRow, confirmPasswordRow])
        } else {
            contentStackView.animateInsertion(ofArrangedSubviews: [emailRow, confirmPasswordRow], at: [1, 3])
        }
        NSAnimationContext.runAnimationGroup({ context in
            toggleModeButton.animator().title = inRegisterMode ? "Register" : "Login"
        }, completionHandler: {
            self.inRegisterMode = !self.inRegisterMode
        })
    }

    private func submitLogin() -> Bool {
        unauthenticatedSession?.submitLogin(
            username: usernameField.stringValue,
            password: passwordField.stringValue,
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                executeOnMainSync {
                    switch result {
                    case .success(_):
                        self.dismiss(self)
                    case .failure(let error):
                        self.operationDidFailWithError(error.description)
                    }
                }
            }
        )
        return true
    }

    private func submitRegister() throws -> Bool {
        let password = passwordField.stringValue
        if password != confirmPasswordField.stringValue {
            operationDidFailWithError("Passwords do not match!")
            return false
        }

        unauthenticatedSession?.submitRegister(
            username: usernameField.stringValue,
            email: try EmailAddress.decode(from: emailField.stringValue),
            password: password,
            completionHandler: { [weak self] maybeError in
                guard let self = self else { return }
                executeOnMainSync {
                    if let error = maybeError {
                        self.operationDidFailWithError(error)
                    } else {
                        self.dismiss(self)
                    }
                }
            }
        )
        return true
    }
}

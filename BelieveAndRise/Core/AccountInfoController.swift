//
//  AccountInfoController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Manages information about a user's account.
final class AccountInfoController: AccountInfoDelegate {

    // MARK: - Depedencies

    /// The client associated with the account.
    weak var client: Client?

    // MARK: - Data

    /// The logged-in user which the metadata describes.
    var user: User? {
        return client?.connectedAccount
    }

    /// A cached value for email. Wiped on present.
    private var email: String?
    /// A cached value for ingame hours. Wiped on present.
    private var ingameHours: Int?
    /// A cached value for registration date. Wiped on present. (Wiping)
    private var registrationDate: Date?

    /// A block to execute when account data has been retrieved and is ready to present.
    private var completionBlock: ((AccountData) -> ())?

    // MARK: - Updating data

    /// Records the registration date of the user for presentation.
    func setRegistrationDate(_ registrationDate: Date?) {
        self.registrationDate = registrationDate
        presentIfReady()
    }

    /// Records the ingame hours of the user for presentation.
    func setIngameHours(_ ingameHours: Int) {
        self.ingameHours = ingameHours
        presentIfReady()
    }

    /// Records the email of the user for presentation.
    func setEmail(_ email: String) {
        self.email = email
        presentIfReady()
    }

    /// Wipes the cached information.
    func invalidate() {
        email = nil
        ingameHours = nil
        registrationDate = nil
    }

    // MARK: - Private helpers

    /// Presents cached data and wipes the cache.
    private func presentIfReady() {
        if let email = email,
            let ingameHours = ingameHours {
            let accountData = AccountData(email: email, ingameHours: ingameHours, registrationDate: registrationDate)
            completionBlock?(accountData)
            invalidate()
        }
    }

    // MARK: - AccountDataSource

    func retrieveAccountData(completionBlock: @escaping (AccountData) -> ()) {
        self.completionBlock = completionBlock
        client?.server?.send(CSGetUserInfoCommand())
        presentIfReady()
    }

    // MARK: - AccountInfoDelegate

    func requestVerficationCodeForChangingEmail(to newEmailAddress: String, password: String, completionBlock: @escaping (String?) -> ()) {
        guard client?.featureAvailability?.requiresVerificationCodeForChangeEmail == true else {
            changeEmailWithoutVerification(to: newEmailAddress, password: password, completionBlock: completionBlock)
            return
        }

        if password == client?.userAuthenticationController.password {
            client?.server?.send(CSChangeEmailRequestCommand(newEmail: newEmailAddress)) { response in
                if let _ = response as? SCChangeEmailRequestAcceptedCommand {
                    completionBlock(nil)
                } else if let failureResponse = response as? SCChangeEmailRequestDeniedCommand {
                    completionBlock(failureResponse.errorMessage)
                } else {
                    completionBlock("A server error occurred!")
                }
            }
        } else {
            completionBlock("Incorrect password.")
        }
    }

    func changeEmail(to newEmailAddress: String, password: String, verificationCode: String, completionBlock: @escaping (String?) -> ()) {
        if password == client?.userAuthenticationController.password {
            client?.server?.send(CSChangeEmailWithVerificationCommand(newEmail: newEmailAddress, verificationCode: verificationCode)) { [weak self] response in
                if let _ = response as? SCChangeEmailAcceptedCommand {
                    completionBlock(nil)
                    self?.client?.server?.send(CSGetUserInfoCommand())
                } else if let failureResponse = response as? SCChangeEmailDeniedCommand {
                    completionBlock(failureResponse.errorMessage)
                } else {
                    completionBlock("A server error occurred!")
                }
            }
        } else {
            completionBlock("Incorrect password.")
        }
    }
    func changeEmailWithoutVerification(to newEmailAddress: String, password: String, completionBlock: @escaping (String?) -> ()) {
        if password == client?.userAuthenticationController.password {
            client?.server?.send(CSChangeEmailWithoutVerificationCommand(newEmail: newEmailAddress)) { [weak self] response in
                if let _ = response as? SCChangeEmailAcceptedCommand {
                    completionBlock(nil)
                    self?.client?.server?.send(CSGetUserInfoCommand())
                } else if let failureResponse = response as? SCChangeEmailDeniedCommand {
                    completionBlock(failureResponse.errorMessage)
                } else {
                    completionBlock("A server error occurred!")
                }
            }
        } else {
            completionBlock("Incorrect password.")
        }
    }

    func renameAccount(to newAccountName: String, password: String, completionBlock: @escaping (String?) -> ()) {
        if password == client?.userAuthenticationController.password {
            client?.server?.send(CSRenameAccountCommand(newUsername: newAccountName))
            completionBlock(nil)
        }
    }

    func changePassword(from oldPassword: String, to newPassword: String, completionBlock: @escaping (String?) -> ()) {
        if oldPassword == client?.userAuthenticationController.password {
            client?.server?.send(CSChangePasswordCommand(oldPassword: oldPassword, newPassword: newPassword))
            completionBlock(nil)
        }
    }
}

//
//  UserAuthenticationViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol UserAuthenticationViewControllerDelegate: AnyObject {
    func submitLogin(for userAuthenticationViewController: UserAuthenticationViewController)
}

/// A controller for the user authentication process.
final class UserAuthenticationViewController: NSViewController {

    // MARK: - Outlets

    @IBOutlet weak var contentStackView: NSStackView!
    @IBOutlet weak var loginButton: NSButton!

    /// A function called in viewDidLoad() which allows operations accessing the view to be delayed until
    /// after the view has loaded.
    private var configureViewsAfterViewLoaded: (() -> Void)?

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Allows configuration to be postponed until after view has loaded.
        configureViewsAfterViewLoaded?()
    }

    // MARK: - Dependencies

    /// The user authentication view controller's delegate.
    weak var delegate: UserAuthenticationViewControllerDelegate?

    // MARK: - Configuration

    /// Configures the view to present data already in the request
    func configureFor(_ input: IncompleteAuthenticateUserRequest) {
        let configureViews = { [weak self] in
            guard let self = self else {
                return
            }
            let textField = NSTextField()
            textField.placeholderString = "Username"
            textField.stringValue = input.username ?? ""
            self.contentStackView.addArrangedSubview(textField)

            let textField2 = NSSecureTextField()
            textField2.placeholderString = "Password"
            textField2.stringValue = input.password ?? ""

            self.contentStackView.addArrangedSubview(textField2)

            textField.nextKeyView = textField2
            // User will want to start entering information at the first ivew
            textField.becomeFirstResponder()
        }

        // Cannot access view's properties until after the view has loaded; if the view hasn't loaded yet,
        // we'll wait until viewDidLoad to configure the views.
        isViewLoaded ? configureViews() : (self.configureViewsAfterViewLoaded = configureViews)
    }

    // MARK: - Actions

    ///
    @IBAction func login(_ sender: Any) {
        delegate?.submitLogin(for: self)
    }
}

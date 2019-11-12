//
//  ChatViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

class ChatViewController: NSViewController {

    @IBOutlet var stackView: NSStackView!

    let chatBarController = ChatBarController()
    let logViewController = ListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(logViewController)
        stackView.addArrangedSubview(logViewController.view)

        addChild(chatBarController)
        stackView.addArrangedSubview(chatBarController.view)
    }
}

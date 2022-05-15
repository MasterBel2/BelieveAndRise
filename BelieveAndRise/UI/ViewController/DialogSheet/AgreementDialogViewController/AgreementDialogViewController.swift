//
//  AgreementDialogViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/5/2022.
//  Copyright © 2022 MasterBel2. All rights reserved.
//

import Cocoa

class AgreementDialogViewController: DialogSheet {

    override func viewDidLoad() {
        controlsToDisable.append(confirmationCodeField)
        agreementView.string = agreement
    }

    var agreement: String = "" {
        didSet {
            if isViewLoaded {
                agreementView.string = agreement
            }
        }
    }

    @IBOutlet weak var agreementView: NSTextView!
    @IBOutlet weak var confirmationCodeField: NSTextField!
}

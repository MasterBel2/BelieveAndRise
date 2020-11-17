//
//  TextViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

final class TextViewController: NSViewController {

    @IBOutlet var textView: NSTextView!

    private var text: String = ""

    override func viewDidLoad() {
        textView.string = text
    }

    func addLine(_ line: String) {
        executeOnMain(target: self) {
            $0.text.append(line)
            if $0.isViewLoaded {
                $0.textView.string = $0.text
            }
        }
    }
}

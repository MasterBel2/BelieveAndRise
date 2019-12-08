//
//  DownloadItemView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol DownloadItemViewDelegate: AnyObject {
    func showDownload(_ id: Int)
    func pauseDownload(_ id: Int)
    func resumeDownload(_ id: Int)
}

final class DownloadItemView: NSView, NibLoadable {

    // MARK: - Properties

    var id: Int!

    // MARK: - Interface

    @IBOutlet var downloadNameLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var button: NSButton!

    var state: State = .done {
        didSet {
            switch state {
            case .done:
                button.image = NSImage(named: "NSRevealFreestandingTemplate")
                button.contentTintColor = nil
                button.action = #selector(showDownload)
                progressIndicator.isHidden = true
            case .paused:
                button.image = NSImage(named: "NSRefreshFreestandingTemplate")
                button.contentTintColor = .systemOrange
                button.action = #selector(resumeDownload)
                progressIndicator.isHidden = true
            case .loading, .inProgress:
                button.image = NSImage(named: "NSStopProgressFreestandingTemplate")
                button.contentTintColor = nil
                button.action = #selector(pauseDownload)
                progressIndicator.isHidden = false
            }
        }
    }

    @objc private func showDownload() {
        delegate?.showDownload(id)
    }

    @objc private func pauseDownload() {
        delegate?.pauseDownload(id)
    }

    @objc private func resumeDownload() {
        delegate?.resumeDownload(id)
    }

    enum State {
        case done
        case paused
        case loading
        case inProgress
    }

    // MARK: - Actions

    @IBAction func buttonPressed(_ sender: Any) {
        if state == .done {}
    }

    // MARK: - Delegate

    weak var delegate: DownloadItemViewDelegate?

}

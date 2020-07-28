//
//  DownloadItemView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of functions to be implemented by the download item view's delegate.
protocol DownloadItemViewDelegate: AnyObject {
	/// Instructs the delegate to show the download in its directory.
    func showDownload(_ id: Int)
	/// Instructs the delegate to pause the download.
    func pauseDownload(_ id: Int)
	/// Instructs the delegate to resume the paused download.
    func resumeDownload(_ id: Int)
}

/// A view that displays information about the state of a download.
final class DownloadItemView: NSView, NibLoadable {

    // MARK: - Properties

	/// The unique ID associated with the download.
    var id: Int!

    // MARK: - Lifecycle

    func loadedFromNib() {
        button.sendAction(on: .leftMouseDown)
        button.target = self
    }

    // MARK: - Interface

    @IBOutlet var downloadNameLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var button: NSButton!

	/// The state of the download.
	var state: DownloadInfo.State = .loading {
        didSet {
            switch state {
            case .completed:
                button.image = NSImage(named: "NSRevealFreestandingTemplate")
                button.contentTintColor = nil
                button.action = #selector(showDownload)
                progressIndicator.isHidden = true
            case .paused:
                button.image = NSImage(named: "NSRefreshFreestandingTemplate")
                button.contentTintColor = .systemOrange
                button.action = #selector(resumeDownload)
                progressIndicator.isHidden = true
            case .loading, .progressing:
                button.image = NSImage(named: "NSStopProgressFreestandingTemplate")
                button.contentTintColor = nil
                button.action = #selector(pauseDownload)
                progressIndicator.isHidden = false
			case .failed:
				button.image = NSImage(named: "NSStopProgressFreestandingTemplate")
				button.contentTintColor = .systemOrange
                progressIndicator.isHidden = true
            }
        }
    }

	/// Instructs the delegate to show the download in its directory.
    @objc private func showDownload() {
        delegate?.showDownload(id)
    }

	/// Instructs the delegate to pause the download.
    @objc private func pauseDownload() {
        delegate?.pauseDownload(id)
    }

	/// Instructs the delegate to resume the paused download.
    @objc private func resumeDownload() {
        delegate?.resumeDownload(id)
    }

    // MARK: - Delegate

	/// The download item view's delegate.
    weak var delegate: DownloadItemViewDelegate?

}

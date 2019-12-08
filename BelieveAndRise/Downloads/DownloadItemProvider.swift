//
//  DownloadItemProvider.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class DownloadItemProvider: ItemViewProvider {
    let downloadList: List<DownloadInfo>
    private weak var downloadItemViewDelegate: DownloadItemViewDelegate?

    init(downloadList: List<DownloadInfo>, downloadItemViewDelegate: DownloadItemViewDelegate) {
        self.downloadList = downloadList
        self.downloadItemViewDelegate = downloadItemViewDelegate
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let item = downloadList.items [id] else {
            return nil
        }

        let view = DownloadItemView.loadFromNib()
        view.downloadNameLabel.stringValue = item.name
        view.progressIndicator.isIndeterminate = item.progress == item.target

        if item.isPaused {
            view.state = .paused
        } else if item.isCompleted {
            view.state = .done
        } else if item.progress == 0 {
            view.state = .loading
        } else {
            view.state = .inProgress
        }

        view.id = id
        view.delegate = downloadItemViewDelegate

        return view
    }
}

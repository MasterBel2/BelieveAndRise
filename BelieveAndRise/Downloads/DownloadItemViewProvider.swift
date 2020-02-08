//
//  DownloadItemViewProvider.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Provides view for the list view controller displaying the contents of a list of `DownloadInfo`.
final class DownloadItemViewProvider: ItemViewProvider {
	/// The list whose content is to be displayed.
    let downloadList: List<DownloadInfo>
	/// The delegate to pass forward to the views.
    private weak var downloadItemViewDelegate: DownloadItemViewDelegate?

    init(downloadList: List<DownloadInfo>, downloadItemViewDelegate: DownloadItemViewDelegate) {
        self.downloadList = downloadList
        self.downloadItemViewDelegate = downloadItemViewDelegate
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let item = downloadList.items[id] else {
            return nil
        }

        let view = DownloadItemView.loadFromNib()
        view.downloadNameLabel.stringValue = item.name
        view.progressIndicator.isIndeterminate = item.progress == item.target

		view.state = item.state

        view.id = id
        view.delegate = downloadItemViewDelegate

        return view
    }
}

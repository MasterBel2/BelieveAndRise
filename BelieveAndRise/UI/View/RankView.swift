//
//  RankView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// An image view with a helper function for displaying a user's rank.
final class RankView: NSImageView {
	/// Displays the image associated with the given rank.
    func displayRank(_ rank: Int) {
        let image: NSImage?
        switch rank {
        case 0:
            image = #imageLiteral(resourceName: "Rank 1")
        case 1:
            image = #imageLiteral(resourceName: "Rank 2")
        case 2:
            image = #imageLiteral(resourceName: "Rank 3")
        case 3:
            image = #imageLiteral(resourceName: "Rank 4")
        case 4:
            image = #imageLiteral(resourceName: "Rank 5")
        case 5:
            image = #imageLiteral(resourceName: "Rank 6")
        case 6:
            image = #imageLiteral(resourceName: "Rank 7")
        case 7:
            image = #imageLiteral(resourceName: "Rank 8")
        default:
            image = nil
        }

        self.image = image
    }
}

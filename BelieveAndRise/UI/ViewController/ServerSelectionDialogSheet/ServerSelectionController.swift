//
//  ServerSelectionController.swift
//  BelieveAndRise
//
//  Created by Derek Bel on 31/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol Controller {
	/// Resigns control of the interface, and dismisses associated UI.
	func resign()
	var hasCompletedOperation: Bool { get }
}

final class ServerSelectionController: ServerSelectionViewControllerDelegate {
	
	var server: TASServer?
	
	func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress) {
		let server = TASServer(address: serverAddress)
		let parser = TASServerMessageParser()
		server.delegate = parser
		server.connect()
	}
}

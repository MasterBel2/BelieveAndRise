//
//  TASServer.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A set of methods the TASServer's delegate may implement.
protocol TASServerDelegate: AnyObject {
    func server(_ server: TASServer, didReceive serverCommand: String)
}

/// Handles the socket connection to a TASServer.
///
/// Lobbyserver protocol is described at http://springrts.com/dl/LobbyProtocol
/// See here for an implementation in C++ https://github.com/cleanrock/flobby/tree/master/src/model
final class TASServer: NSObject, SocketDelegate {
	
	// MARK: - Dependencies

    /// The TASServer's delegate object.
	weak var delegate: TASServerDelegate?
	
	// MARK: - Properties

    /// The socket that connects to the remote server.
	let socket: Socket
    /// The delay after which the keepalive "PING" should be sent in order to maintain the server connection.
    /// A delay of 30 seconds is reccomended by TASServer documentation.
    var keepaliveDelay: TimeInterval = 30
	
	// MARK: - Lifecycle

    /// Initialiser for the TASServer object.
    ///
    /// - parameter address: The IP address or domain name of the server.
    /// - parameter port: The port on which the socket should connect.
    init(address: ServerAddress) {
		socket = Socket(address: address)
		super.init()
		
		socket.delegate = self
	}
	
	// MARK: - TASServing

    /// Initiates the socket connection and begins the keepalive loop.
	func connect() {
		socket.connect()
        perform(#selector(TASServer.sendPing), with: nil, afterDelay: 30)
	}

    /// Cancels the keepalive loop and severs the socket connection.
	func disconnect() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(TASServer.sendPing), object: nil)
		socket.disconnect()
	}

    /// Sends an encoded command over the socket and delays the keepalive to avoid sending superfluous messages to the server.
	func send(_ command: ServerCommand) {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(TASServer.sendPing), object: nil)
		socket.send(message: "\(command.description)\n")
		perform(#selector(TASServer.sendPing), with: nil, afterDelay: keepaliveDelay)
	}
	
	// MARK: - SocketDelegate

    /// A message was received over the socket.
	func socket(_ socket: Socket, didReceive message: String) {
		let messages = message.components(separatedBy: "\n")
		for message in messages {
            delegate?.server(self, didReceive: message)
		}
	}

    // MARK: - Helper functions

    /// Sends a keepalive message and queues the next.
    @objc private func sendPing() {
        socket.send(message: "PING\n")
        perform(#selector(TASServer.sendPing), with: nil, afterDelay: keepaliveDelay)
    }
}

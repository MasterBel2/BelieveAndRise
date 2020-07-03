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
	/// Informs the delegate that the server has sent a command.
    func server(_ server: TASServer, didReceive serverCommand: String)
	/// Stores the handler and executes it on the command tagged with the given ID.
    func prepareToDelegateResponseToMessage(identifiedBy id: Int, to handler: ((SCCommand) -> ())?)
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
	private(set) var socket: Socket
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

    /// Terminates the connection to the server, and with it the keepalive loop.
	func disconnect() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(TASServer.sendPing), object: nil)
		socket.disconnect()
	}
	
	/// Closes the connection to one server, and connects to the new address
    func redirect(to serverAddress: ServerAddress) {
        disconnect()
        socket = Socket(address: serverAddress)
        socket.delegate = self
        connect()
	}

	/// The ID of the next message to be sent to the server, corresponding to the number of messages previously sent.
    private var count = 0
    /// Sends an encoded command over the socket and delays the keepalive to avoid sending superfluous messages to the server.
    ///
    /// Command handlers should not contain any strong references to objects in the case a command is never responded to.
    func send(_ command: CSCommand, specificHandler: ((SCCommand) -> ())? = nil) {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(TASServer.sendPing), object: nil)
        delegate?.prepareToDelegateResponseToMessage(identifiedBy: count, to: specificHandler)
		socket.send(message: "#\(count) \(command.description)\n")
		perform(#selector(TASServer.sendPing), with: nil, afterDelay: keepaliveDelay)
        count += 1
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

//
//  Socket.swift
//  OSXSpringLobby
//
//  Created by Belmakor on 30/06/2016.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

protocol SocketDelegate: class {
	func socket(_ socket: Socket, didReceive message: String)
}

final class Socket: NSObject, StreamDelegate {
	
	// MARK: - Properties
	
	weak var delegate: SocketDelegate?
	
	let address: String
	let port: Int
	
	private var inputStream: InputStream?
	private var outputStream: OutputStream?
	
	private var messageBuffer = NSMutableData(capacity: 256)!
	
	private var isConnected: Bool { return inputStream != nil && outputStream != nil }
	
	// MARK: - Lifecycle
	
	init(address: ServerAddress) {
		self.address = address.location
		self.port = address.port
	}
	
	// MARK: - Public API

    /// Instructs the socket to connect to the server
	func connect() {
		guard !isConnected else {
			return
		}
		
		Stream.getStreamsToHost(withName: address, port: port, inputStream: &inputStream, outputStream: &outputStream)
		
		guard let inputStream = inputStream, let outputStream = outputStream else {
			print("Failed to get input & output streams")
			return
		}
		
		inputStream.delegate = self
		outputStream.delegate = self
		
		inputStream.schedule(in: .current, forMode: .default)
		outputStream.schedule(in: .current, forMode: .default)
		
		inputStream.open()
		outputStream.open()
	}

    /// Instructs the socket to disconnect to the server
	func disconnect() {
		guard isConnected else {
			return
		}
		if let input = inputStream {
			input.close()
			input.remove(from: .current, forMode: .default)
			inputStream = nil
		}
		if let output = outputStream {
			output.close()
			output.remove(from: .current, forMode: .default)
			outputStream = nil
		}
	}
	
	func send(message: String) {
		guard let outputStream = outputStream else {
			print("Error: Not Connected")
			return
		}
		guard let data = message.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
			print("Cannot convert message into data to send: invalid format?")
			return
		}
		
		var bytes = Array<UInt8>(repeating: 0, count: data.count)
		(data as NSData).getBytes(&bytes, length: data.count)
		outputStream.write(&bytes, maxLength: data.count)
	}
	
	// MARK: - StreamDelegate
	
	func stream(_ stream: Stream, handle eventCode: Stream.Event) {
		switch eventCode {
			
		case Stream.Event():
			break
			
		case Stream.Event.openCompleted:
			break
			
		case Stream.Event.hasBytesAvailable:
			guard let input = stream as? InputStream else { break }
			
			var byte: UInt8 = 0
			while input.hasBytesAvailable {
				let bytesRead = input.read(&byte, maxLength: 1)
				messageBuffer.append(&byte, length: bytesRead)
			}
			// only inform our delegate of complete messages (must end in newline character)
			if let message = String(data: messageBuffer as Data, encoding: String.Encoding.utf8), message.hasSuffix("\n") {
				delegate?.socket(self, didReceive: message)
				messageBuffer.length = 0
			}
			
		case Stream.Event.hasSpaceAvailable:
			break
			
		case Stream.Event.errorOccurred:
			break
			
		case Stream.Event.endEncountered:
			stream.close()
			stream.remove(from: .current, forMode: .default)
			if stream == inputStream {
				inputStream = nil
			} else if stream == outputStream {
				outputStream = nil
			}
			
		default:
			print(eventCode)
		}
	}
}

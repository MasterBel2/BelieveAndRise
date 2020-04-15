//
//  SpringProcessController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Handles configuring and launching of a single instance of the SpringRTS engine
final class SpringProcessController {
    private(set) var springProcess: Process?
    private let scriptTxtManager = LaunchScriptWriter()

    /// Launches a spring instance with instructions to connect to the specified host.
    func launchSpringAsClient(andConnectTo ip: String, at port: Int, with username: String, and password: String, completionHandler: (() -> Void)?) {
        scriptTxtManager.prepareForLaunchOfSpringAsClient(
            ip: ip,
            port: port,
            username: username,
            scriptPassword: password
        )
        startSpringRTS(completionHandler: completionHandler)
    }

    /// Launches spring.
    private func startSpringRTS(completionHandler: (() -> Void)?) {
        // TODO: --Some sort of cache interface to allow multiple engines to be used
        guard let path = NSWorkspace.shared.fullPath(forApplication: "Spring_103.0.app") else { debugPrint("Non-Fatal Error: could not find Spring_103.0.app"); return }
        guard let bundle = Bundle(path: path) else { debugPrint("Non-Fatal Error: could not create bundle object for SpringRTS"); return }

        let process = Process()
        process.launchPath = bundle.executablePath
        process.arguments = [LaunchScriptWriter.filePath]
        process.terminationHandler = { _ in
            debugPrint("Spring engine exited")
            self.springProcess = nil
            completionHandler?()
        }
        process.launch()
        springProcess = process
    }

    // TODO

//    func launch(_ replay: Replay) {
//        let scriptTxtManager = LaunchScriptWriter()
//        scriptTxtManager.prepareForLaunchOfReplay()
//        startSpringRTS()
//    }

//    func launch(_ game: HostedGame) {
//        let scriptTxtManager = LaunchScriptWriter()
//        scriptTxtManager.prepareForLaunchOfSinglePlayerGame(game)
//        startSpringRTS()
//    }
}

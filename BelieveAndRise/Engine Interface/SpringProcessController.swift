//
//  SpringProcessController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Describes a data object with the necessary information to start Spring.
protocol LaunchScriptConvertible {
    /// Generates a string suitable for launching the engine to a specification.
    func launchScript(shouldRecordDemo: Bool) -> String
}

/// Handles configuring and launching of a single instance of the SpringRTS engine.
final class SpringProcessController {
    private(set) var canLaunchSpring: Bool = true

    let system: System
    let replayController: ReplayController

    var scriptFileURL: URL {
        return system.configDirectory.appendingPathComponent("script.txt")
    }

    init(system: System, replayController: ReplayController) {
        self.system = system
        self.replayController = replayController
    }

    /// Launches a spring instance with instructions to connect to the specified host.
    func launchSpringAsClient(andConnectTo ip: String, at port: Int, with username: String, and password: String, completionHandler: (() -> Void)?) {
        let specification = LaunchScript.ClientSpecification(
            ip: ip,
            port: port,
            username: username,
            scriptPassword: password
        )
        startSpringRTS(specification, shouldRecordDemo: true, completionHandler: completionHandler)
    }

    /// Launches spring.
    func startSpringRTS(_ launchObject: LaunchScriptConvertible, shouldRecordDemo: Bool, completionHandler: (() -> Void)?) {
        guard let scriptData = launchObject.launchScript(shouldRecordDemo: shouldRecordDemo).data(using: .utf8) else {
            completionHandler?()
            return
        }
        let app = "Spring_103.0.app"
        system.write(scriptData, to: scriptFileURL)
        system.launchApplication(app, with: [scriptFileURL.path], completionHandler: { [weak self] in
            completionHandler?()
            if shouldRecordDemo {
                try? self?.replayController.loadReplays()
            }
            self?.canLaunchSpring = true
        })
        canLaunchSpring = false
    }
}

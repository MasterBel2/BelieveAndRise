//
//  ReplayController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Handles loading of replays from the file system.
final class ReplayController {

    init(system: System) {
        self.system = system
    }

    let replays = List<Replay>(title: "Replays", property: { $0.header.gameStartDate })

    let system: System
    let fileManager =  FileManager.default
    let loadQueue = DispatchQueue(label: "com.believeandrise.replaycontroller.load", qos: .background, attributes: .concurrent)
    let updateQueue = DispatchQueue(label: "com.believeandrise.replaycontroller.update", qos: .userInteractive)
    var demoDir: URL {
        return system.configDirectory.appendingPathComponent("demos", isDirectory: true)
    }

    /// Asynchronously loads replays from disk.
    func loadReplays() throws {
        let urls = try fileManager.contentsOfDirectory(at: demoDir, includingPropertiesForKeys: [kCFURLCreationDateKey as URLResourceKey])
        for replayURL in urls {
            if replays.items.contains(where: {$0.value.fileURL == replayURL }) { break }
            loadQueue.async { [weak self] in
                do {
                if let self = self,
                    let data = self.fileManager.contents(atPath: replayURL.path)?.gunzip() {
                    let replay = try Replay(data: data, fileURL: replayURL)
                        // Concurrently updating the list is a sure fire way to corrupt it. So we'll
                        self.updateQueue.async { [weak self] in
                            self?.replays.addItem(replay, with: Int.random(in: Int.min...Int.max))
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}

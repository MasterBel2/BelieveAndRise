//
//  Archive.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

// MARK: - ModArchive

final class ModArchive: Archive {

    private(set) lazy var completeChecksum: UInt32 = { unitsyncWrapper.GetPrimaryModChecksum(archiveIndex) }()

    private(set) lazy var factions: [Faction] = {
        return executeOnVFS {
            return (0..<unitsyncWrapper.GetSideCount()).map({ index in
                return Faction(
                    name: String(cString: unitsyncWrapper.GetSideName(index)),
                    startUnit: String(cString: unitsyncWrapper.GetSideStartUnit(index))
                )
            })
        }
    }()

    // MARK: Overrides

    override func getArchiveName() -> String {
        switch info.first(where: { $0.key == "name" })?.value {
        case .string(let string):
            return string
        default:
            fatalError()
        }
    }

    override func getArchiveDependencyName(at index: CInt) -> String {
        return String(cString: unitsyncWrapper.GetPrimaryModArchiveList(index))
    }

    override func getArchiveDependencyCount() -> CInt {
        return unitsyncWrapper.GetPrimaryModArchiveCount(archiveIndex)
    }

    override func getInfoCount() -> CInt {
        return unitsyncWrapper.GetPrimaryModInfoCount(archiveIndex)
    }

    override func getOptionCount() -> CInt {
        return executeOnVFS {
            return unitsyncWrapper.GetModOptionCount()
        }
    }

    // MARK: Nested Types

    struct Faction {
        let name: String
        let startUnit: String
    }
}

// MARK: - SkirmishAIArchive

final class SkirmishAIArchive: Archive {
    override func getArchiveDependencyCount() -> CInt {
        return 0
    }

    override func getInfoCount() -> CInt {
        return unitsyncWrapper.GetSkirmishAIInfoCount(archiveIndex)
    }

    override func getOptionCount() -> CInt {
        return unitsyncWrapper.GetSkirmishAIOptionCount(archiveIndex)
    }

    override func getArchiveName() -> String {
        switch info.first(where: { $0.key == "name" })?.value {
        case .string(let string):
            return string
        default:
            fatalError()
        }
    }
}

// MARK: - MapArchive

final class MapArchive: Archive {

    // MARK: Properties

    private(set) lazy var heightRange: ClosedRange<Float> = { unitsyncWrapper.GetMapMinHeight(name.utf8CStringArray)...unitsyncWrapper.GetMapMaxHeight(name.utf8CStringArray) }()

    private(set) lazy var width: Int = { Int(unitsyncWrapper.GetMapWidth(archiveIndex)) }()
    private(set) lazy var height: Int = { Int(unitsyncWrapper.GetMapHeight(archiveIndex)) }()
    private(set) lazy var grassMap: InfoMap = { InfoMap<UInt8>(mapArchive: self, name: .grass) }()
    private(set) lazy var heightMap: InfoMap = { InfoMap<UInt16>(mapArchive: self, name: .height) }()
    private(set) lazy var metalMap: InfoMap = { InfoMap<UInt8>(mapArchive: self, name: .metal) }()
    private(set) lazy var typeMap: InfoMap = { InfoMap<UInt8>(mapArchive: self, name: .type) }()
    private(set) lazy var miniMap: Minimap = { Minimap(mapArchive: self) }()
    private(set) lazy var fileName: String = { String(cString: unitsyncWrapper.GetMapFileName(archiveIndex) )}()
    private(set) lazy var completeChecksum: UInt32 = { unitsyncWrapper.GetMapChecksum(archiveIndex) }()

    // MARK: Overrides

    override var checksum: UInt32 {
        return completeChecksum
    }

    override func getOptionCount() -> CInt {
        return unitsyncWrapper.GetMapOptionCount(name.utf8CStringArray)
    }
    override func getArchiveDependencyName(at index: CInt) -> String {
        String(cString: unitsyncWrapper.GetMapArchiveName(index))
    }
    override func getArchiveDependencyCount() -> CInt {
        return unitsyncWrapper.GetMapArchiveCount(name.utf8CStringArray)
    }
    override func getInfoCount() -> CInt {
        unitsyncWrapper.GetMapInfoCount(archiveIndex)
    }

    // MARK: Nested types

    final class InfoMap<PixelType: UnsignedInteger> {
        enum Name: String {
            case grass
            case height
            case metal
            case type
        }

        init(mapArchive: MapArchive, name: Name) {
            unitsyncWrapper = mapArchive.unitsyncWrapper
            mapName = mapArchive.name
            self.name = name
        }

        private let unitsyncWrapper: UnitsyncWrapper
        private let mapName: String
        private let name: Name
        private(set) lazy var size: (width: Int, height: Int) = {
            var cName = name.rawValue.cString(using: .utf8)!
            var height = CInt()
            var width = CInt()
            withUnsafePointer(to: cName[0]) { name in
                _ = unitsyncWrapper.GetInfoMapSize(mapName, name, &width, &height)
            }
            return (width: Int(width), height: Int(height))
        }()

        private(set) lazy var pixels: [PixelType] = {
            var cName = name.rawValue.cString(using: .utf8)!
            var pixels: [PixelType] = Array<PixelType>(repeating: PixelType(), count: size.width * size.height)
            withUnsafePointer(to: cName[0]) { cName in
                withUnsafePointer(to: &pixels) { pixelPointer in
                    pixelPointer.withMemoryRebound(to: UInt8.self, capacity: 1) { bytePointer in
                        _ = unitsyncWrapper.GetInfoMap(mapName, cName, UnsafeMutablePointer(mutating: bytePointer), name == .height ? 2 : 1)
                    }
                }
            }
            return pixels
        }()
    }

    final class Minimap {
        private var mipLevels: [Int : [RGB565Color]] = [:]
        private let mapName: String
        let unitsyncWrapper: UnitsyncWrapper


        init(mapArchive: MapArchive) {
            self.mapName = mapArchive.name
            self.unitsyncWrapper = mapArchive.unitsyncWrapper
        }

        func minimap(for mipLevel: Int) -> [RGB565Color] {
            guard mipLevel < 9 else {
                fatalError("Cannot handle a mip level larger than 8")
            }
            if let data = mipLevels[mipLevel] {
                return data
            }
            let minimapPointer = unitsyncWrapper.GetMinimap(mapName, CInt(mipLevel))
            let factor = 1024 / Int(pow(2, Float(mipLevel)))
            let data = Array(UnsafeBufferPointer(start: minimapPointer, count: factor * factor))
            mipLevels[mipLevel] = data
            return data
        }
    }
}

// MARK: - Superclass

class Archive {
    init(archiveIndex: CInt, archiveName: String, unitsyncWrapper: UnitsyncWrapper) {
        self.unitsyncWrapper = unitsyncWrapper
        self.archiveIndex = archiveIndex
        self.name = archiveName
    }
    init(archiveIndex: CInt, unitsyncWrapper: UnitsyncWrapper) {
        self.unitsyncWrapper = unitsyncWrapper
        self.archiveIndex = archiveIndex
    }

    let unitsyncWrapper: UnitsyncWrapper

    var archiveIndex: CInt
    private(set) lazy var name: String = { getArchiveName() }()
    private(set) lazy var path: String = { String(cString: unitsyncWrapper.GetArchivePath(name.utf8CStringArray)) }()
    private(set) lazy var singleArchiveChecksum: UInt32 = { unitsyncWrapper.GetArchiveChecksum(name.utf8CStringArray) }()

    var checksum: UInt32 { return singleArchiveChecksum }

    private(set) lazy var info = loadInfo()
    private(set) lazy var dependencies = loadDependencies()
    private(set) lazy var options = loadOptions()

    // MARK: - Loading data

    private func loadInfo() -> [Info] {
        return (0..<getInfoCount()).map({ index in
            return Info(
                key: String(cString: unitsyncWrapper.GetInfoKey(index)),
                description: String(cString: unitsyncWrapper.GetInfoDescription(index)),
                value: Info.Value(index: index, wrapper: unitsyncWrapper)
            )
        })
    }

    private func loadOptions() -> [Option] {
        return (0..<getOptionCount()).map({ index in
            Option(
                key: String(cString: unitsyncWrapper.GetOptionKey(index)),
                name: String(cString: unitsyncWrapper.GetOptionName(index)),
                description: String(cString: unitsyncWrapper.GetOptionDesc(index)),
                type: Option.OptionType(rawValue: unitsyncWrapper.GetOptionType(index)),
                section: String(cString: unitsyncWrapper.GetOptionSection(index))
                // More TODO
            )
        })
    }

    private func loadDependencies() -> [Archive] {
        return (0..<getArchiveDependencyCount()).map({ index in
            Archive(
                archiveIndex: index,
                archiveName: getArchiveDependencyName(at: index),
                unitsyncWrapper: unitsyncWrapper
            )
        })
    }

    // MARK: - Private helpers

    fileprivate func executeOnVFS<T>(_ block: () -> T) -> T {
        unitsyncWrapper.AddAllArchives(name.utf8CStringArray)
        let result = block()
        unitsyncWrapper.RemoveAllArchives()
        return result
    }

    // MARK: Overridable

    fileprivate func getArchiveName() -> String { fatalError() }
    fileprivate func getArchiveDependencyName(at index: CInt) -> String { fatalError() }
    fileprivate func getArchiveDependencyCount() -> CInt { fatalError() }
    fileprivate func getInfoCount() -> CInt { fatalError() }
    fileprivate func getOptionCount() -> CInt { fatalError() }

    // MARK: - Nested Types

    struct Info {
        let key: String
        let description: String
        let value: Value?
        enum Value: CustomStringConvertible {
            case string(String)
            case integer(Int)
            case float(Float)
            case boolean(Bool)

            init?(index: CInt, wrapper: UnitsyncWrapper) {
                let typeString = String(cString: wrapper.GetInfoType(index))
                switch typeString.lowercased() {
                case "string":
                    self = .string(String(cString: wrapper.GetInfoValueString(index)))
                case "integer":
                    self = .integer(Int(wrapper.GetInfoValueInteger(index)))
                case "float":
                    self = .float(wrapper.GetInfoValueFloat(index))
                case "bool":
                    self = .boolean(wrapper.GetInfoValueBool(index))
                default:
                    return nil
                }
            }
            var description: String {
                switch self {
                case .string(let string):
                    return string
                case .integer(let int):
                    return String(int)
                case .float(let float):
                    return String(float)
                case .boolean(let bool):
                    return bool ? "1" : "0"
                }
            }
        }
        var fullDescription: String {
            return "\(key) = \(value!.description) ; \(description)"
        }
    }

    struct Option {
        let key: String
        let name: String
        let description: String
        let type: OptionType?
        let section: String

        enum OptionType: CInt {
            case dunno = 1
        }
    }

}

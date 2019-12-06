//
//  UnitsyncWrapper.swift
//  OSXSpringLobby
//
//  Created by Belmakor on 10/12/16.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

/**
 Provides convenience wrappers to the SpringRTS unitsync dynamic library.

 - Note: This class is *not thread safe*. Be sure to invoke all functions via `performBlock` for asynchronous processing, or `performBlockAndWait` for synchronous processing. This class uses a private serial queue to dispatch all operations.
 */
final class UnitsyncWrapper {

    private let handle: DynamicLibraryHandle
    private let queue = DispatchQueue(label: "com.believeandrise.unitsyncwrapper")

    // MARK: - General

    // Un-initialises and re-initialises unitsync
    func refresh() {
        UnInit()
        _ = Init(true, 0)
    }

    /// The version of spring Unitsync was compiled for, combined with the version patchset.
    var springVersion: String {
        return String(cString: GetSpringVersion()) + "." + String(cString: GetSpringVersionPatchset())
    }

    /// Whether the version of spring compiled with unitsync was a release version.
    var isSpringVersionAReleaseVersion: Bool {
        return IsSpringReleaseVersion()
    }

    // MARK: - Maps

    /// The number of maps available to unitsync
    var mapCount: Int { return Int(GetMapCount()) }

    /// Returns the name of the specified map. Maps are generally sorted alphabetially.
    func mapName(at index: Int) -> String {
        return String(cString: GetMapName(CInt(index)))
    }

    /// Returns a description of the specified map.
    ///
    /// Warning: this is not a free function. Only load this value when necessary, and make sure to cache instead of re-fetching, when
    /// possible
    func mapDescription(at index: Int) -> String {
        return String(cString: GetMapDescription(CInt(index)))
    }

    func mapFileName(at index: Int) -> String {
        return String(cString: GetMapFileName(CInt(index)))
    }

    /// Returns a checksum for the specified map file, which can be used to verify its integrity
    ///
    func mapChecksum(at index: Int) -> Int32 {
        return GetMapChecksum(CInt(index))
    }

    /// Returns the width of the specified map.
    func mapWidth(at index: Int) -> Int {
        return Int(GetMapWidth(CInt(index)))
    }

    /// Returns the height of the specified map.
    func mapHeight(at index: Int) -> Int {
        return Int(GetMapHeight(CInt(index)))
    }

    func minimap(forMapAt index: Int, mipLevel: Int) -> [UInt16]? {
        guard mipLevel < 9 else {
            fatalError("Cannot handle a mip level larger than 8")
        }
        let factor = 1024 / Int(pow(2, Float(mipLevel)))

        let namePointer = GetMapName(CInt(index))
        guard let minimapPointer = GetMinimap(namePointer, CInt(mipLevel)) else {
            return nil
        }

        let data = Array(UnsafeBufferPointer(start: minimapPointer, count: factor * factor))

        guard data.count == factor * factor else {
            return nil
        }

        return data
    }

    // MARK: - Games

    var gameCount: Int {
        return Int(GetPrimaryModCount())
    } // Mods in unitsync are actually games


    func gameChecksum(at index: Int) -> Int32 {
        return GetMapChecksum(CInt(index))
    }

    /**
     Retrieves information about the game at the given index.
     */
    func gameInfo(at index: Int) -> [String : InfoValue] {
        var values: [String : InfoValue] = [:]
        performBlockAndWait {
            for infoIndex in 0..<gameInfoCount(at: index) {
                let key = infoKey(at: infoIndex)
                switch infoType(at: infoIndex) {
                case .bool:
                    values[key] = .bool(infoBoolValue(at: infoIndex))
                case .float:
                    values[key] = .float(infoFloatValue(at: infoIndex))
                case .integer:
                    values[key] = .integer(infoIntegerValue(at: infoIndex))
                case .string:
                    values[key] = .string(infoStringValue(at: infoIndex))
                case .none:
                    print("No value for type: \(key)")
                }
            }
        }
        return values
    }

    /**
     Retrieves the number of info items available for this mod.
     - parameter index: The index of the game
     */
    private func gameInfoCount(at index: Int) -> Int {
        return Int(GetPrimaryModInfoCount(CInt(index)))
    }

    /**
     Retrieves an info item's value type
     - parameter index: Index of the associated info item.
     */
    private func infoType(at index: Int) -> InfoType? {
        return InfoType(rawValue: String(cString: GetInfoType(CInt(index))))
    }

    /**
     Retrieves an info item's value type (either "string", "integer", "float", or "bool")
     - parameter index: The index of the key's info item.
     */
    private func infoKey(at index: Int) -> String {
        return String(cString: GetInfoKey(CInt(index)))
    }

    /**
     - parameter index: Index of the value's info item.
     */
    private func infoStringValue(at index: Int) -> String {
        return String(cString: GetInfoValueString(CInt(index)))
    }
    /**
     - parameter index: Index of the value's info item.
     */
    private func infoIntegerValue(at index: Int) -> Int {
        return Int(GetInfoValueInteger(CInt(index)))
    }
    /**
     - parameter index: Index of the value's info item.
     */
    private func infoFloatValue(at index: Int) -> Float {
        return GetInfoValueFloat(CInt(index))
    }
    /**
     - parameter index: Index of the value's info item.
     */
    private func infoBoolValue(at index: Int) -> Bool {
        return Bool(GetInfoValueBool(CInt(index)))
    }

    // MARK: - Types

    enum InfoType: String {
        case string
        case integer
        case float
        case bool
    }

    enum InfoValue {
        case string(String)
        case integer(Int)
        case float(Float)
        case bool(Bool)

        var stringValue: String {
            switch self {
            case .string(let value):
                return String(value)
            case .integer(let value):
                return String(value)
            case .float(let value):
                return String(value)
            case .bool(let value):
                return String(value)
            }
        }
    }

    // MARK: - Lifecycle

    init?(config: UnitsyncConfig) {
        guard let handle = DynamicLibraryHandle(libraryPath: config.unitsyncPath) else {
            return nil
        }

        self.handle = handle

        // resolve the c functions we are going to use

        GetSpringVersion = handle.resolve("GetSpringVersion", type(of: GetSpringVersion))!
        GetSpringVersionPatchset = handle.resolve("GetSpringVersionPatchset", type(of: GetSpringVersionPatchset))!
        IsSpringReleaseVersion = handle.resolve("IsSpringReleaseVersion", type(of: IsSpringReleaseVersion))!

        Init = handle.resolve("Init", type(of: Init))!
        UnInit = handle.resolve("UnInit", type(of: UnInit))!

        GetWritableDataDirectory = handle.resolve("GetWritableDataDirectory", type(of: GetWritableDataDirectory))!
        GetDataDirectoryCount = handle.resolve("GetDataDirectoryCount", type(of: GetDataDirectoryCount))!
        GetDataDirectory = handle.resolve("GetDataDirectory", type(of: GetDataDirectory))!

        ProcessUnits = handle.resolve("ProcessUnits", type(of: ProcessUnits))!
        GetUnitCount = handle.resolve("GetUnitCount", type(of: GetUnitCount))!
        GetUnitName = handle.resolve("GetUnitName", type(of: GetUnitName))!
        GetFullUnitName = handle.resolve("GetFullUnitName", type(of: GetFullUnitName))!

        AddArchive = handle.resolve("AddArchive", type(of: AddArchive))!
        AddAllArchives = handle.resolve("AddAllArchives", type(of: AddAllArchives))!
        RemoveAllArchives = handle.resolve("RemoveAllArchives", type(of: RemoveAllArchives))!
        GetArchiveChecksum = handle.resolve("GetArchiveChecksum", type(of: GetArchiveChecksum))!
        GetArchivePath = handle.resolve("GetArchivePath", type(of: GetArchivePath))!

        GetMapCount = handle.resolve("GetMapCount", type(of: GetMapCount))!
        //        GetMapInfoCount = handle.resolve("GetMapInfoCount", GetMapInfoCount.dynamicType)!
        GetMapName = handle.resolve("GetMapName", type(of: GetMapName))!
        GetMapFileName = handle.resolve("GetMapFileName", type(of: GetMapFileName))!
        GetMapDescription = handle.resolve("GetMapDescription", type(of: GetMapDescription))!
        GetMapAuthor = handle.resolve("GetMapAuthor", type(of: GetMapAuthor))!
        GetMapWidth = handle.resolve("GetMapWidth", type(of: GetMapWidth))!
        GetMapHeight = handle.resolve("GetMapHeight", type(of: GetMapHeight))!
        GetMapTidalStrength = handle.resolve("GetMapTidalStrength", type(of: GetMapTidalStrength))!
        GetMapWindMin = handle.resolve("GetMapWindMin", type(of: GetMapWindMin))!
        GetMapWindMax = handle.resolve("GetMapWindMax", type(of: GetMapWindMax))!
        GetMapGravity = handle.resolve("GetMapGravity", type(of: GetMapGravity))!
        GetMapResourceCount = handle.resolve("GetMapResourceCount", type(of: GetMapResourceCount))!
        GetMapResourceName = handle.resolve("GetMapResourceName", type(of: GetMapResourceName))!
        GetMapResourceMax = handle.resolve("GetMapResourceMax", type(of: GetMapResourceMax))!
        GetMapResourceExtractorRadius = handle.resolve("GetMapResourceExtractorRadius", type(of: GetMapResourceExtractorRadius))!
        GetMapPosCount = handle.resolve("GetMapPosCount", type(of: GetMapPosCount))!
        GetMapPosX = handle.resolve("GetMapPosX", type(of: GetMapPosX))!
        GetMapPosZ = handle.resolve("GetMapPosZ", type(of: GetMapPosZ))!
        GetMapMinHeight = handle.resolve("GetMapMinHeight", type(of: GetMapMinHeight))!
        GetMapMaxHeight = handle.resolve("GetMapMaxHeight", type(of: GetMapMaxHeight))!
        GetMapArchiveCount = handle.resolve("GetMapArchiveCount", type(of: GetMapArchiveCount))!
        GetMapArchiveName = handle.resolve("GetMapArchiveName", type(of: GetMapArchiveName))!
        GetMapChecksum = handle.resolve("GetMapChecksum", type(of: GetMapChecksum))!
        GetMapChecksumFromName = handle.resolve("GetMapChecksumFromName", type(of: GetMapChecksumFromName))!
        GetMinimap = handle.resolve("GetMinimap", type(of: GetMinimap))!
        GetInfoMapSize = handle.resolve("GetInfoMapSize", type(of: GetInfoMapSize))!
        GetInfoMap = handle.resolve("GetInfoMap", type(of: GetInfoMap))!

        GetSkirmishAICount = handle.resolve("GetSkirmishAICount", type(of: GetSkirmishAICount))!
        GetSkirmishAIInfoCount = handle.resolve("GetSkirmishAIInfoCount", type(of: GetSkirmishAIInfoCount))!
        GetInfoKey = handle.resolve("GetInfoKey", type(of: GetInfoKey))!
        GetInfoType = handle.resolve("GetInfoType", type(of: GetInfoType))!
        GetInfoValueString = handle.resolve("GetInfoValueString", type(of: GetInfoValueString))!
        GetInfoValueInteger = handle.resolve("GetInfoValueInteger", type(of: GetInfoValueInteger))!
        GetInfoValueFloat = handle.resolve("GetInfoValueFloat", type(of: GetInfoValueFloat))!
        GetInfoValueBool = handle.resolve("GetInfoValueBool", type(of: GetInfoValueBool))!
        GetInfoDescription = handle.resolve("GetInfoDescription", type(of: GetInfoDescription))!
        GetSkirmishAIOptionCount = handle.resolve("GetSkirmishAIOptionCount", type(of: GetSkirmishAIOptionCount))!

        GetPrimaryModCount = handle.resolve("GetPrimaryModCount", type(of: GetPrimaryModCount))!
        GetPrimaryModInfoCount = handle.resolve("GetPrimaryModInfoCount", type(of: GetPrimaryModInfoCount))!
        GetPrimaryModArchive = handle.resolve("GetPrimaryModArchive", type(of: GetPrimaryModArchive))!
        GetPrimaryModArchiveCount = handle.resolve("GetPrimaryModArchiveCount", type(of: GetPrimaryModArchiveCount))!
        GetPrimaryModArchiveList = handle.resolve("GetPrimaryModArchiveList", type(of: GetPrimaryModArchiveList))!
        GetPrimaryModIndex = handle.resolve("GetPrimaryModIndex", type(of: GetPrimaryModIndex))!
        GetPrimaryModChecksum = handle.resolve("GetPrimaryModChecksum", type(of: GetPrimaryModChecksum))!
        GetPrimaryModChecksumFromName = handle.resolve("GetPrimaryModChecksumFromName", type(of: GetPrimaryModChecksumFromName))!

        GetSideCount = handle.resolve("GetSideCount", type(of: GetSideCount))!
        GetSideName = handle.resolve("GetSideName", type(of: GetSideName))!
        GetSideStartUnit = handle.resolve("GetSideStartUnit", type(of: GetSideStartUnit))!

        _ = Init(false, 0)
    }

    deinit {
        UnInit()
    }

    func performBlock(_ block: @escaping ()->()) {
        queue.async(execute: block)
    }

    func performBlockAndWait(_ block: ()->()) {
        queue.sync(execute: block)
    }

    // MARK: - Wrapper

    // Spring version
    private let GetSpringVersion: @convention(c) () -> UnsafePointer<CChar>
    private let GetSpringVersionPatchset: @convention(c) () -> UnsafePointer<CChar>
    private let IsSpringReleaseVersion: @convention(c)() -> Bool

    // Initialization/Un-init
    /**
    Initializes the unitsync library
    @return Zero on error; non-zero on success
    - parameter isServer indicates whether the caller is hosting or joining a game
    - parameter id unused parameter TODO

    Call this function before calling any other function in unitsync.
    In case unitsync was already initialized, it is uninitialized and then
    reinitialized.

    Calling this function is currently the only way to clear the VFS of the
    files which are mapped into it.  In other words, after using AddArchive() or
    AddAllArchives() you have to call Init when you want to remove the archives
    from the VFS and start with a clean state.

    The config handler will not be reset. It will however, be initialised if it
    was not before (with SetSpringConfigFile()).
    */
    private let Init: @convention(c) (Bool, CInt) -> CInt
    private let UnInit: @convention(c) () -> Void

    private let GetWritableDataDirectory: @convention(c) () -> UnsafePointer<CChar>
    private let GetDataDirectoryCount: @convention(c) () -> CInt
    private let GetDataDirectory: @convention(c) (CInt) -> UnsafePointer<CChar>

    private let ProcessUnits: @convention(c) () -> CInt
    private let GetUnitCount: @convention(c) () -> CInt
    private let GetUnitName: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetFullUnitName: @convention(c) (CInt) -> UnsafePointer<CChar>

    private let AddArchive: @convention(c) (UnsafePointer<CChar>) -> Void
    private let AddAllArchives: @convention(c) (UnsafePointer<CChar>) -> Void
    private let RemoveAllArchives: @convention(c) () -> Void
    private let GetArchiveChecksum: @convention(c) (UnsafePointer<CChar>) -> Int32
    private let GetArchivePath: @convention(c) (UnsafePointer<CChar>) -> UnsafePointer<CChar>

    // Map related functions
    private let GetMapCount: @convention(c) () -> CInt
    //    private let GetMapInfoCount: @convention(c) (CInt) -> CInt
    private let GetMapName: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetMapFileName: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetMapDescription: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetMapAuthor: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetMapWidth: @convention(c) (CInt) -> CInt
    private let GetMapHeight: @convention(c) (CInt) -> CInt
    private let GetMapTidalStrength: @convention(c) (CInt) -> CInt
    private let GetMapWindMin: @convention(c) (CInt) -> CInt
    private let GetMapWindMax: @convention(c) (CInt) -> CInt
    private let GetMapGravity: @convention(c) (CInt) -> CInt
    private let GetMapResourceCount: @convention(c) (CInt) -> CInt
    private let GetMapResourceName: @convention(c) (CInt,CInt) -> UnsafePointer<CChar>
    private let GetMapResourceMax: @convention(c) (CInt,CInt) -> CFloat
    private let GetMapResourceExtractorRadius: @convention(c) (CInt,CInt) -> CInt
    private let GetMapPosCount: @convention(c) (CInt) -> CInt
    private let GetMapPosX: @convention(c) (CInt,CInt) -> CFloat
    private let GetMapPosZ: @convention(c) (CInt,CInt) -> CFloat
    private let GetMapMinHeight: @convention(c) (UnsafePointer<CChar>) -> CFloat
    private let GetMapMaxHeight: @convention(c) (UnsafePointer<CChar>) -> CFloat
    private let GetMapArchiveCount: @convention(c) (UnsafePointer<CChar>) -> CInt
    private let GetMapArchiveName: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetMapChecksum: @convention(c) (CInt) -> Int32
    private let GetMapChecksumFromName: @convention(c) (UnsafePointer<CChar>) -> Int32
    private let GetMinimap: @convention(c) (UnsafePointer<CChar>,CInt) -> UnsafeMutablePointer<UInt16>?
    private let GetInfoMapSize: @convention(c) (UnsafePointer<CChar>,UnsafePointer<CChar>,UnsafePointer<CInt>,UnsafePointer<CInt>) -> CInt
    private let GetInfoMap: @convention(c) (UnsafePointer<CChar>,UnsafePointer<CChar>,UnsafePointer<UInt8>,CInt) -> CInt

    private let GetSkirmishAICount: @convention(c) () -> CInt
    private let GetSkirmishAIInfoCount: @convention(c) (CInt) -> CInt
    private let GetInfoKey: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetInfoType: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetInfoValueString: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetInfoValueInteger: @convention(c) (CInt) -> CInt
    private let GetInfoValueFloat: @convention(c) (CInt) -> CFloat
    private let GetInfoValueBool: @convention(c) (CInt) -> CBool
    private let GetInfoDescription: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetSkirmishAIOptionCount: @convention(c) (CInt) -> CInt

    private let GetPrimaryModCount: @convention(c) () -> CInt
    private let GetPrimaryModInfoCount: @convention(c) (CInt) -> CInt
    private let GetPrimaryModArchive: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetPrimaryModArchiveCount: @convention(c) (CInt) -> CInt
    private let GetPrimaryModArchiveList: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetPrimaryModIndex: @convention(c) (UnsafePointer<CChar>) -> CInt
    private let GetPrimaryModChecksum: @convention(c) (CInt) -> Int32
    private let GetPrimaryModChecksumFromName: @convention(c) (UnsafePointer<CChar>) -> Int32

    private let GetSideCount: @convention(c) () -> CInt
    private let GetSideName: @convention(c) (CInt) -> UnsafePointer<CChar>
    private let GetSideStartUnit: @convention(c) (CInt) -> UnsafePointer<CChar>
}

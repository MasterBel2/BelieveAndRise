//
//  UnitsyncWrapper.swift
//  BelieveAndRise
//
//  Created by Belmakor on 10/12/16.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 Provides convenience wrappers to the SpringRTS unitsync dynamic library.

 See unitsync.log in the spring config directory for extra detail on unitsync errors.

 - Note: This class is *not thread safe*.
 */
final class UnitsyncWrapper {

    /// The handle to the c library.
    private let handle: DynamicLibraryHandle

    // MARK: - Helpers

    /// Un-initialises and re-initialises unitsync.
    func refresh() {
        UnInit()
        _ = Init(true, 0)
    }

    /// The version of spring Unitsync was compiled for, combined with the version patchset.
    var springVersion: String {
        return String(cString: GetSpringVersion()) + "." + String(cString: GetSpringVersionPatchset())
    }

    // MARK: - Lifecycle

    init?(config: UnitsyncConfig) {
        guard let handle = DynamicLibraryHandle(libraryPath: config.unitsyncPath) else {
            return nil
        }

        self.handle = handle

        // resolve the c functions we are going to use

        GetNextError = handle.unsafeResolve("GetNextError")

        // Spring Version

        GetSpringVersion = handle.unsafeResolve("GetSpringVersion")
        GetSpringVersionPatchset = handle.unsafeResolve("GetSpringVersionPatchset")
        IsSpringReleaseVersion = handle.unsafeResolve("IsSpringReleaseVersion")

        // Initialisation/Uninit

        Init = handle.unsafeResolve("Init")
        UnInit = handle.unsafeResolve("UnInit")

        // Data directory

        GetWritableDataDirectory = handle.unsafeResolve("GetWritableDataDirectory")
        GetDataDirectoryCount = handle.unsafeResolve("GetDataDirectoryCount")
        GetDataDirectory = handle.unsafeResolve("GetDataDirectory")

        // Units

        ProcessUnits = handle.unsafeResolve("ProcessUnits")
        GetUnitCount = handle.unsafeResolve("GetUnitCount")
        GetUnitName = handle.unsafeResolve("GetUnitName")
        GetFullUnitName = handle.unsafeResolve("GetFullUnitName")

        // Archives

        AddArchive = handle.unsafeResolve("AddArchive")
        AddAllArchives = handle.unsafeResolve("AddAllArchives")
        RemoveAllArchives = handle.unsafeResolve("RemoveAllArchives")
        GetArchiveChecksum = handle.unsafeResolve("GetArchiveChecksum")
        GetArchivePath = handle.unsafeResolve("GetArchivePath")

        // Maps

        GetMapCount = handle.unsafeResolve("GetMapCount")
        GetMapInfoCount = handle.unsafeResolve("GetMapInfoCount")
        GetMapName = handle.unsafeResolve("GetMapName")
        GetMapFileName = handle.unsafeResolve("GetMapFileName")
        GetMapMinHeight = handle.unsafeResolve("GetMapMinHeight")
        GetMapMaxHeight = handle.unsafeResolve("GetMapMaxHeight")
        GetMapArchiveCount = handle.unsafeResolve("GetMapArchiveCount")
        GetMapArchiveName = handle.unsafeResolve("GetMapArchiveName")
        GetMapChecksum = handle.unsafeResolve("GetMapChecksum")
        GetMapChecksumFromName = handle.unsafeResolve("GetMapChecksumFromName")
        GetMinimap = handle.unsafeResolve("GetMinimap")
        GetInfoMapSize = handle.unsafeResolve("GetInfoMapSize")
        GetInfoMap = handle.unsafeResolve("GetInfoMap")

        // Skirmish AIs

        GetSkirmishAICount = handle.unsafeResolve("GetSkirmishAICount")
        GetSkirmishAIInfoCount = handle.unsafeResolve("GetSkirmishAIInfoCount")
        GetInfoKey = handle.unsafeResolve("GetInfoKey")
        GetInfoType = handle.unsafeResolve("GetInfoType")
        GetInfoValueString = handle.unsafeResolve("GetInfoValueString")
        GetInfoValueInteger = handle.unsafeResolve("GetInfoValueInteger")
        GetInfoValueFloat = handle.unsafeResolve("GetInfoValueFloat")
        GetInfoValueBool = handle.unsafeResolve("GetInfoValueBool")
        GetInfoDescription = handle.unsafeResolve("GetInfoDescription")
        GetSkirmishAIOptionCount = handle.unsafeResolve("GetSkirmishAIOptionCount")

        // Games/Mods

        GetPrimaryModCount = handle.unsafeResolve("GetPrimaryModCount")
        GetPrimaryModInfoCount = handle.unsafeResolve("GetPrimaryModInfoCount")
        GetPrimaryModArchive = handle.unsafeResolve("GetPrimaryModArchive")
        GetPrimaryModArchiveCount = handle.unsafeResolve("GetPrimaryModArchiveCount")
        GetPrimaryModArchiveList = handle.unsafeResolve("GetPrimaryModArchiveList")
        GetPrimaryModIndex = handle.unsafeResolve("GetPrimaryModIndex")
        GetPrimaryModChecksum = handle.unsafeResolve("GetPrimaryModChecksum")
        GetPrimaryModChecksumFromName = handle.unsafeResolve("GetPrimaryModChecksumFromName")

        // Factions

        GetSideCount = handle.unsafeResolve("GetSideCount")
        GetSideName = handle.unsafeResolve("GetSideName")
        GetSideStartUnit = handle.unsafeResolve("GetSideStartUnit")

        // Map/Mod Options

        GetMapOptionCount = handle.unsafeResolve("GetMapOptionCount")
        GetModOptionCount = handle.unsafeResolve("GetModOptionCount")
        GetCustomOptionCount = handle.unsafeResolve("GetCustomOptionCount")
        GetOptionKey = handle.unsafeResolve("GetOptionKey")
        GetOptionScope = handle.unsafeResolve("GetOptionScope")
        GetOptionName = handle.unsafeResolve("GetOptionName")
        GetOptionSection = handle.unsafeResolve("GetOptionSection")
        GetOptionDesc = handle.unsafeResolve("GetOptionDesc")
        GetOptionType = handle.unsafeResolve("GetOptionType")
        GetOptionBoolDef = handle.unsafeResolve("GetOptionBoolDef")
        GetOptionNumberDef = handle.unsafeResolve("GetOptionNumberDef")
        GetOptionNumberMin = handle.unsafeResolve("GetOptionNumberMin")
        GetOptionNumberMax = handle.unsafeResolve("GetOptionNumberMax")
        GetOptionNumberStep = handle.unsafeResolve("GetOptionNumberStep")
        GetOptionStringDef = handle.unsafeResolve("GetOptionStringDef")
        GetOptionStringMaxLen = handle.unsafeResolve("GetOptionStringMaxLen")
        GetOptionListCount = handle.unsafeResolve("GetOptionListCount")
        GetOptionListDef = handle.unsafeResolve("GetOptionListDef")
        GetOptionListItemKey = handle.unsafeResolve("GetOptionListItemKey")
        GetOptionListItemName = handle.unsafeResolve("GetOptionListItemName")
        GetOptionListItemDesc = handle.unsafeResolve("GetOptionListItemDesc")

        // Mod Valid Maps

        GetModValidMapCount = handle.unsafeResolve("GetModValidMapCount")
        GetModValidMap = handle.unsafeResolve("GetModValidMap")

        // VFS

        OpenFileVFS = handle.unsafeResolve("OpenFileVFS")
        CloseFileVFS = handle.unsafeResolve("CloseFileVFS")
        ReadFileVFS = handle.unsafeResolve("ReadFileVFS")
        FileSizeVFS = handle.unsafeResolve("FileSizeVFS")
        InitFindVFS = handle.unsafeResolve("InitFindVFS")
        InitDirListVFS = handle.unsafeResolve("InitDirListVFS")
        InitSubDirsVFS = handle.unsafeResolve("InitSubDirsVFS")
        FindFilesVFS = handle.unsafeResolve("FindFilesVFS")
        OpenArchive = handle.unsafeResolve("OpenArchive")
        CloseArchive = handle.unsafeResolve("CloseArchive")
        FindFilesArchive = handle.unsafeResolve("FindFilesArchive")
        OpenArchiveFile = handle.unsafeResolve("OpenArchiveFile")
        ReadArchiveFile = handle.unsafeResolve("ReadArchiveFile")
        CloseArchiveFile = handle.unsafeResolve("CloseArchiveFile")
        SizeArchiveFile = handle.unsafeResolve("SizeArchiveFile")

        SetSpringConfigFile = handle.unsafeResolve("SetSpringConfigFile")
        GetSpringConfigFile = handle.unsafeResolve("GetSpringConfigFile")
        GetSpringConfigString = handle.unsafeResolve("GetSpringConfigString")
        GetSpringConfigInt = handle.unsafeResolve("GetSpringConfigInt")
        GetSpringConfigFloat = handle.unsafeResolve("GetSpringConfigFloat")
        SetSpringConfigString = handle.unsafeResolve("SetSpringConfigString")
        SetSpringConfigInt = handle.unsafeResolve("SetSpringConfigInt")
        SetSpringConfigFloat = handle.unsafeResolve("SetSpringConfigFloat")
        DeleteSpringConfigKey = handle.unsafeResolve("DeleteSpringConfigKey")

        lpClose = handle.unsafeResolve("lpClose")
        lpOpenFile = handle.unsafeResolve("lpOpenFile")
        lpOpenSource = handle.unsafeResolve("lpOpenSource")
        lpExecute = handle.unsafeResolve("lpExecute")
        lpErrorLog = handle.unsafeResolve("lpErrorLog")
        lpAddTableInt = handle.unsafeResolve("lpAddTableInt")
        lpAddTableStr = handle.unsafeResolve("lpAddTableStr")
        lpEndTable = handle.unsafeResolve("lpEndTable")
        lpAddIntKeyIntVal = handle.unsafeResolve("lpAddIntKeyIntVal")
        lpAddStrKeyIntVal = handle.unsafeResolve("lpAddStrKeyIntVal")
        lpAddIntKeyBoolVal = handle.unsafeResolve("lpAddIntKeyBoolVal")
        lpAddStrKeyBoolVal = handle.unsafeResolve("lpAddStrKeyBoolVal")
        lpAddIntKeyFloatVal = handle.unsafeResolve("lpAddIntKeyFloatVal")
        lpAddStrKeyFloatVal = handle.unsafeResolve("lpAddStrKeyFloatVal")
        lpAddIntKeyStrVal = handle.unsafeResolve("lpAddIntKeyStrVal")
        lpAddStrKeyStrVal = handle.unsafeResolve("lpAddStrKeyStrVal")
        lpRootTable = handle.unsafeResolve("lpRootTable")
        lpRootTableExpr = handle.unsafeResolve("lpRootTableExpr")
        lpSubTableInt = handle.unsafeResolve("lpSubTableInt")
        lpSubTableStr = handle.unsafeResolve("lpSubTableStr")
        lpSubTableExpr = handle.unsafeResolve("lpSubTableExpr")
        lpPopTable = handle.unsafeResolve("lpPopTable")
        lpGetKeyExistsInt = handle.unsafeResolve("lpGetKeyExistsInt")
        lpGetKeyExistsStr = handle.unsafeResolve("lpGetKeyExistsStr")
        lpGetIntKeyType = handle.unsafeResolve("lpGetIntKeyType")
        lpGetStrKeyType = handle.unsafeResolve("lpGetStrKeyType")
        lpGetIntKeyListCount = handle.unsafeResolve("lpGetIntKeyListCount")
        lpGetIntKeyListEntry = handle.unsafeResolve("lpGetIntKeyListEntry")
        lpGetStrKeyListCount = handle.unsafeResolve("lpGetStrKeyListCount")
        lpGetStrKeyListEntry = handle.unsafeResolve("lpGetStrKeyListEntry")
        lpGetIntKeyIntVal = handle.unsafeResolve("lpGetIntKeyIntVal")
        lpGetStrKeyIntVal = handle.unsafeResolve("lpGetStrKeyIntVal")
        lpGetIntKeyBoolVal = handle.unsafeResolve("lpGetIntKeyBoolVal")
        lpGetStrKeyBoolVal = handle.unsafeResolve("lpGetStrKeyBoolVal")
        lpGetIntKeyFloatVal = handle.unsafeResolve("lpGetIntKeyFloatVal")
        lpGetStrKeyFloatVal = handle.unsafeResolve("lpGetStrKeyFloatVal")
        lpGetIntKeyStrVal = handle.unsafeResolve("lpGetIntKeyStrVal")
        lpGetStrKeyStrVal = handle.unsafeResolve("lpGetStrKeyStrVal")

        // Deprecated

        GetMapDescription = handle.unsafeResolve("GetMapDescription")
        GetMapAuthor = handle.unsafeResolve("GetMapAuthor")
        GetMapWidth = handle.unsafeResolve("GetMapWidth")
        GetMapHeight = handle.unsafeResolve("GetMapHeight")
        GetMapTidalStrength = handle.unsafeResolve("GetMapTidalStrength")
        GetMapWindMin = handle.unsafeResolve("GetMapWindMin")
        GetMapWindMax = handle.unsafeResolve("GetMapWindMax")
        GetMapGravity = handle.unsafeResolve("GetMapGravity")
        GetMapResourceCount = handle.unsafeResolve("GetMapResourceCount")
        GetMapResourceName = handle.unsafeResolve("GetMapResourceName")
        GetMapResourceMax = handle.unsafeResolve("GetMapResourceMax")
        GetMapResourceExtractorRadius = handle.unsafeResolve("GetMapResourceExtractorRadius")
        GetMapPosCount = handle.unsafeResolve("GetMapPosCount")
        GetMapPosX = handle.unsafeResolve("GetMapPosX")
        GetMapPosZ = handle.unsafeResolve("GetMapPosZ")

        _ = Init(false, 0)
    }

    deinit {
        UnInit()
    }

    // MARK: - Errors

    /**
     Retrieves the next error in queue of errors and removes this error from the queue

     # Return Value
     An error message, or NULL if there are no more errors in the queue

     Use this method to get a (short) description of errors that occurred in any
     other unitsync methods. Call this in a loop until it returns NULL to get all
     errors.

     The error messages may be varying in detail etc.; nothing is guaranteed about
     them, not even whether they have terminating newline or not.

     # Example (C++)
     ```C++
     const char* err;
     while ((err = GetNextError()) != NULL)
     printf("unitsync error: %s\n", err);
     ```
     */
    let GetNextError: @convention(c) () -> CString

    // MARK: - Spring version

    /**
     Retrieve the synced version of Spring
     this unitsync was compiled with.

     Returns a string specifying the synced part of the version of Spring used to
     build this library with.

     # Before release 83:
     ## Release:
     The version will be of the format "Major.Minor".
     With Major=0.82 and Minor=6, the returned version would be "0.82.6".

     ## Development:
     They use the same format, but major ends with a +, for example "0.82+.5".

     ## Examples:
     - 0.78.0: 1st release of 0.78
     - 0.82.6: 7th release of 0.82
     - 0.82+.5: some test-version from after the 6th release of 0.82
     - 0.82+.0: some dev-version from after the 1st release of 0.82
     (on the main dev branch)

     # After release 83:
     You may check for sync compatibility by using a string equality test with
     the return of this function.
     ## Release:
     Contains only the major version number, for example "83".
     You may combine this with the patch-set to get the full version,
     for example "83.2".
     ## Development:
     The full version, for example "83.0.1-13-g1234567 develop", and therefore
     it would not make sense to append the patch-set in such a case.
     ## Examples:
     - 83: any 83 release, for example 83.0 or 83.1
     this may only be on the the master or hotfix branch
     - 83.0.1-13-g1234567 develop: some dev-version after the 1st release of 83
     on the develop branch
     */
    let GetSpringVersion: @convention(c) () -> UnsafePointer<CChar>
    /**
     Returns the unsynced/patch-set part of the version of Spring
     this unitsync was compiled with.

     # Before release 83:
     You may want to use this together with GetSpringVersion() to form the whole
     version like this:

     ```C++
     GetSpringVersion() + "." + GetSpringVersionPatchset()
     ```

     This will provide you with a version of the format "Major.Minor.Patchset".

     ## Examples:
     - 0.82.6.0 (in this case, the 0 is usually omitted -> 0.82.6)
     - 0.82.6.1 (release)
     - 0.82+.6.1 (dev build)

     # After release 83:
     You should only possibly append this to the main version returned by
     GetSpringVersion(), if it is a release, as otherwise GetSpringVersion()
     already contains the patch-set.
     */
    let GetSpringVersionPatchset: @convention(c) () -> UnsafePointer<CChar>
    /**
     Returns true if the version of Spring this unitsync was compiled
     with is a release version, false if it is a development version.
     */
    let IsSpringReleaseVersion: @convention(c)() -> Bool

    // MARK: - Initialisation/Uninit

    /**
     Initializes the unitsync library

     # Return Value

     Zero on error; non-zero on success

     # Parameters
     - `isServer`: indicates whether the caller is hosting or joining a game
     - `id`: unused

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
    let Init: @convention(c) (Bool, CInt) -> CInt

    /**
     Uninitialize the unitsync library.

     Also resets the config handler.
     */
    let UnInit: @convention(c) () -> Void

    // MARK: - Data Directory

    /**
     Get the main data directory that is used by unitsync and Spring

     # Return Value
     NULL on error; the data directory path on success

     This is the data directory which is used to write logs, screen-shots, demos,
     etc.
     */
    let GetWritableDataDirectory: @convention(c) () -> CString
    /**
     Returns the total number of readable data directories used by unitsync and the engine.

     # Return Value
     Negative integer (< 0) on error; the number of data directories available (>= 0) on success.
     */
    let GetDataDirectoryCount: @convention(c) () -> CInt
    /**
     Get the absolute path to i-th data directory

     # Return Value
     NULL on error; the i-th data directory absolute path on success
     */
    let GetDataDirectory: @convention(c) (CInt) -> CString

    // MARK: - Units

    /**
     Must be called before `GetUnitCount()`, `GetUnitName()`, ...
     Before caling this function, you will first need to load a game's archives into the VFS using `AddArchive()` or `AddAllArchives()`.

     # Return Value
     always 0!
     */
    let ProcessUnits: @convention(c) () -> CInt
    /**
     Get the number of units

     #Return Value
     negative integer (< 0) on error;
     the number of units available (>= 0) on success

     Will return the number of units. Remember to call `ProcessUnits()` beforehand
     until it returns 0. As `ProcessUnits()` is called the number of processed units goes up, and so will the value returned by this function.

     Example:
     ```C++
     while (ProcessUnits() > 0) {}
     int numUnits = GetUnitCount();
     ```
     */
    let GetUnitCount: @convention(c) () -> CInt
    /**
     Get the units internal mod name

     # Parameters
     - `unit`: The units id number

     # Return Value
     The units internal mod name, or NULL on error

     This function returns the units internal mod name. For example it would
     return 'armck' and not 'Arm Construction kbot'.
     */
    let GetUnitName: @convention(c) (CInt) -> CString
    /**
     Get the units human readable name

     # Parameters
     - `unit`: The unit's id number

     # Return Value
     The units human readable name or NULL on error
     *
     This function returns the units human name. For example it would return
     'Arm Construction kbot' and not 'armck'.
     */
    let GetFullUnitName: @convention(c) (CInt) -> CString

    // MARK: - Archives

    /**
     Adds an archive to the VFS (Virtual File System)

     After this, the contents of the archive are available to other unitsync functions, for example:
     `ProcessUnits()`, `OpenFileVFS()`, `ReadFileVFS()`, `FileSizeVFS()`, etc.

     # Parameters
     - `archiveName`:

     Do not forget to call `RemoveAllArchives()` before proceeding with other archives.
     */
    let AddArchive: @convention(c) (CString) -> Void
    /**
     * Adds an archive and all its dependencies to the VFS
     */
    let AddAllArchives: @convention(c) (CString) -> Void
    /**
     Removes all archives from the VFS (Virtual File System)

     After this, the contents of the archives are not available to other unitsync functions anymore, for example:
     `ProcessUnits()`, `OpenFileVFS()`, `ReadFileVFS()`, `FileSizeVFS()`, etc.

     In a lobby-client, this may be used instead of `Init()` when switching mod archive.
     */
    let RemoveAllArchives: @convention(c) () -> Void
    /**
     Get checksum of an archive

     This checksum depends only on the contents from the archive itself, and not
     on the contents from dependencies of this archive (if any).

     # Return Value
     Zero on error; the checksum on success
     */
    let GetArchiveChecksum: @convention(c) (CString) -> UInt32
    /**
     Gets the real path to the archive

     # Return Value
     NULL on error; a path to the archive on success
     */
    let GetArchivePath: @convention(c) (CString) -> CString

    // MARK: - Maps

    /**
     Get the number of maps available.

     Call this before any of the map functions which take a map index as a parameter.
     This function actually performs a relatively costly enumeration of all maps,
     so you should resist from calling it repeatedly in a loop.  Rather use:

     ```C++
     int map_count = GetMapCount();
     for (int index = 0; index < map_count; ++index) {
     printf("map name: %s\n", GetMapName(index));
     }
     ```
     Then:
     ```C++
     for (int index = 0; index < GetMapCount(); ++index) { ... }
     ```

     # Return Value
     negative integer (< 0) on error; the number of maps available (>= 0) on success.
     */
    let GetMapCount: @convention(c) () -> CInt
    /**
     Retrieves the number of info items available for a given Map

     Be sure to call `GetMapCount()` prior to using this function.

     # Parameters
     - `index`: Map index/id

     # Return Value
     negative integer (< 0) on error; the number of info items available (>= 0) on success

     # See also
     - `GetMapCount`
     - `GetInfoKey`
     */
    let GetMapInfoCount: @convention(c) (CInt) -> CInt
    /**
     Get the name of a map

     # Return Value
     NULL on error; the name of the map (e.g. "SmallDivide") on success

     # See Also
     - `GetMapCount`
     */
    let GetMapName: @convention(c) (CInt) -> CString
    /**
     Get the file-name (+ VFS-path) of a map

     # Return Value
     NULL on error; the file-name of the map (e.g. "maps/SmallDivide.smf") on success

     # See Also
     - `GetMapCount`
     */
    let GetMapFileName: @convention(c) (CInt) -> CString
    /**
     The map's minimum height

     Together with maxHeight, this determines the
     range of the map's height values in-game. The
     conversion formula for any raw 16-bit height
     datum `h` is
     ```C++
     minHeight + (h * (maxHeight - minHeight) / 65536.0f)
     ```

     # Parameters
     - `mapName`: name of the map, e.g. "SmallDivide"

     # Return Value
     0.0f on error; the map's minimum height on success

     # See Also
     - `GetMapCount`
     - `GetMapMaxHeight`
     */
    let GetMapMinHeight: @convention(c) (CString) -> CFloat
    /**
     The map's maximum height.

     Together with minHeight, this determines the
     range of the map's height values in-game. See
     `GetMapMinHeight()` for the conversion formula.

     # Parameters
     - `mapName`: name of the map, e.g. "SmallDivide"

     # Return Value
     0.0f on error; the map's maximum height on success

     # See Also
     - `GetMapCount`
     - `GetMapMinHeight`
     */
    let GetMapMaxHeight: @convention(c) (CString) -> CFloat
    /**
     The number of archives a map requires

     Must be called before `GetMapArchiveName()`

     # Parameters
     - `mapName`: name of the map, e.g. "SmallDivide"

     # Return Value
     negative integer (< 0) on error; the number of archives (>= 0) on success

     # See Also
     - `GetMapCount`
     - `GetMapArchiveName()`
     */
    let GetMapArchiveCount: @convention(c) (CString) -> CInt
    /**
     Retrieves an archive a map requires

     # Parameters
     - `index`: the index of the archive

     # Return Value
     NULL on error; the name of the archive on success

     # See Also
     - `GetMapCount`
     */
    let GetMapArchiveName: @convention(c) (CInt) -> CString
    /**
     Get map checksum given a map index

     This checksum depends on Spring internals, and as such should not be expected
     to remain stable between releases.

     (It is meant to check sync between clients in lobby, for example.)

     # Parameters:
     - `index`: the index of the map

     # Return Value
     Zero on error; the checksum on success

     # See Also
     - `GetMapCount`
     */
    let GetMapChecksum: @convention(c) (CInt) -> UInt32
    /**
     Get map checksum given a map name.

     This will not provide the same result as `GetArchiveChecksum`. See `GetMapChecksum`

     # Parameters
     - `mapName` name of the map, e.g. "SmallDivide"

     # Return Value
     Zero on error; the checksum on success

     # See Also
     - `GetMapCount`
     */
    let GetMapChecksumFromName: @convention(c) (CString) -> UInt32
    /**
     Retrieves a minimap image for a map.

     # Parameters:
     - `fileName`: The name of the map, including extension.
     - `mipLevel`: Which mip-level of the minimap to extract from the file. Set mip-level to 0 to get the largest, 1024x1024 minimap.
        Each increment divides the width and height by 2. The maximum mip-level is 8, resulting in a 4x4 image.

     # Return Value
     A pointer to a static memory area containing the minimap as a 16 bit packed RGB-565 (MSB to LSB: 5 bits red, 6 bits green, 5 bits blue) linear bitmap on success;
     NULL on error.

     # Example
     To retrieve a 16 bit packed RGB-565 256x256 (= 1024/2^2) bitmap:
     `GetMinimap("SmallDivide", 2)`

     # See Also
     - `GetMapCount`
     */
    let GetMinimap: @convention(c) (CString, CInt) -> UnsafeMutablePointer<UInt16>?
    /**
     Retrieves dimensions of infomap for a map. See `GetInfoMap`

     # Parameters
     - `mapName`: The name of the map, e.g. "SmallDivide".
     - `name`: Of which infomap to retrieve the dimensions.
     - `width`: This is set to the width of the infomap, or 0 on error.
     - `height`: This is set to the height of the infomap, or 0 on error.

     # Return Value
     negative integer (< 0) on error; the infomap's size (>= 0) on success

     # See Also
     - `GetMapCount`
     */
    let GetInfoMapSize: @convention(c) (CString, CString, UnsafeMutablePointer<CInt>, UnsafeMutablePointer<CInt>) -> CInt
    /**
     Retrieves infomap data of a map.

     This function extracts an infomap from a map. This can currently be one of:
     "height", "metal", "grass", "type". The heightmap is natively in 16 bits per
     pixel, the others are in 8 bits pixel. Using typeHint one can give a hint to
     this function to convert from one format to another. Currently only the
     conversion from 16 bpp to 8 bpp is implemented.

     # Parameters
     - `mapName`: The name of the map, e.g. "SmallDivide".
     - `name`: Which infomap to extract from the file.
     - `data`: Pointer to a memory location with enough room to hold the infomap data.
     - `typeHint`: One of bm_grayscale_8 (or 1) and bm_grayscale_16 (or 2).

     # Return Value
     negative integer (< 0) on error; the infomap's size (> 0) on success

     An error could indicate that the map was not found, the infomap was not found or typeHint could not be honored.

     # See Also
     - `GetMapCount`
     */
    let GetInfoMap: @convention(c) (CString, CString, UnsafeMutablePointer<UInt8>, CInt) -> CInt

    // MARK: - Skirmish AIs

    /**
     Retrieves the number of Skirmish AIs available

     # Return Value
     negative integer (< 0) on error; the number of Skirmish AIs available (>= 0) on success

     # See Also
     - `GetMapCount`
    */
    let GetSkirmishAICount: @convention(c) () -> CInt
    /**
     Retrieves the number of info items available for a given Skirmish AI.

     Be sure to call `GetSkirmishAICount()` prior to using this function.

     # Parameters
     - `index`: Skirmish AI index/id

     # Return Value
     negative integer (< 0) on error; the number of info items available (>= 0) on success.
     */
    let GetSkirmishAIInfoCount: @convention(c) (CInt) -> CInt

    // MARK: - Archive Info
    /**
     Retrieves an info item's key
     The key of an option is either one defined as SKIRMISH_AI_PROPERTY_* in ExternalAI/Interface/SSkirmishAILibrary.h, or a custom one.
     Be sure to call `GetSkirmishAIInfoCount()` prior to using this function.

     # Parameters
     - `index`: info item index/id

     # Return Value
     NULL on error; the info item's key on success
     */
    let GetInfoKey: @convention(c) (CInt) -> CString
    /**
     Retrieves an info item's value type

     # Parameters
     - `index`: info item index/id

     # Return Value
     NULL on error; the info item's value type on success, which will be one of: "string", "integer", "float", "bool"

     # Related Topics:
     - `GetSkirmishAIInfoCount`
     - `GetInfoValueString`
     - `GetInfoValueInteger`
     - `GetInfoValueFloat`
     - `GetInfoValueBool`
     */
    let GetInfoType: @convention(c) (CInt) -> CString
    /**
     Retrieves an info item's value of type string

     Be sure to call `GetSkirmishAIInfoCount()` prior to using this function.

     # Parameters
     - `index`: info item index/id

     # Return Value
     NULL on error; the info item's value on success

     # Related Topics
     - `GetSkirmishAIInfoCount`
     - `GetInfoType`
     */
    let GetInfoValueString: @convention(c) (CInt) -> CString
    /**
     Retrieves an info item's value of type integer

     # Parameters
     - `index`: info item index/id

     # Return Value
     the info item's value; -1 might imply a value of -1 or an error

     # Related Topics:
     - `GetSkirmishAIInfoCount`
     - `GetInfoType`
     *
     * Be sure to call GetSkirmishAIInfoCount() prior to using this function.
     */
    let GetInfoValueInteger: @convention(c) (CInt) -> CInt
    /**
     Retrieves an info item's value of type float

     Be sure to call `GetSkirmishAIInfoCount()` prior to using this function.

     # Parameters
     - `index` info item index/id

     # Return Value
     the info item's value; -1.0f might imply a value of -1.0f or an error

     # See also
     - `GetSkirmishAIInfoCount`
     - `GetInfoType`
     */
    let GetInfoValueFloat: @convention(c) (CInt) -> CFloat
    /**
     Retrieves an info item's value of type bool

     Be sure to call `GetSkirmishAIInfoCount()` prior to using this function.

     # Parameters
     - `index` info item index/id

     # Return Value
     the info item's value; false might imply a value of false or an error

     # See also
     - `GetSkirmishAIInfoCount`
     - `GetInfoType`
     */
    let GetInfoValueBool: @convention(c) (CInt) -> CBool
    /**
     Retrieves an info item's description

     Be sure to call `GetSkirmishAIInfoCount()` prior to using this function.

     # Parameters
     - `index`: info item index/id

     # Return Value
     NULL on error; the info item's description on success

     # See also
     - `GetSkirmishAIInfoCount`
     */
    let GetInfoDescription: @convention(c) (CInt) -> CString

    // MARK: - Games/Mods

    /**
     Retrieves the number of mods available

     # Return Value
     negative integer (< 0) on error; the number of mods available (>= 0) on success

     # See Also
     - `GetMapCount`
     */
    let GetPrimaryModCount: @convention(c) () -> CInt
    /**
     Retrieves the number of info items available for this mod

     # Parameters
     - `index`: The mods index/id

     # Return Value
     negative integer (< 0) on error; the number of info items available (>= 0) on success

     # See Also
     - `GetPrimaryModCount`
     - `GetInfoKey`
     - `GetInfoType`
     - `GetInfoDescription`
     *
     * Be sure you have made a call to `GetPrimaryModCount()` prior to using this.
     */
    let GetPrimaryModInfoCount: @convention(c) (CInt) -> CInt
    /**
     Retrieves the mod's first/primary archive
     Be sure you have made a call to `GetPrimaryModCount()` prior to using this.

     # Parameters:
     - `index`: The mods index/id

     # Return Value
     NULL on error; The mods primary archive on success

     # See Also
     - `GetPrimaryModCount()`
     */
    let GetPrimaryModArchive: @convention(c) (CInt) -> CString
    /**
     Retrieves the number of archives a mod requires

     This is used to get the entire list of archives that a mod requires.
     Call `GetPrimaryModArchiveCount()` with selected mod first to get number of
     archives, and then use `GetPrimaryModArchiveList()` for 0 to count-1 to get the
     name of each archive.  In code:
     ```C++
     int count = GetPrimaryModArchiveCount(mod_index);
     for (int archive = 0; archive < count; ++archive) {
        printf("primary mod archive: %s\n", GetPrimaryModArchiveList(archive));
     }
     ```

     #Parameters
     - `index`: The index of the mod

     # Return Value
     - negative integer (< 0) on error; the number of archives this mod depends on (>= 0) on success
    */
    let GetPrimaryModArchiveCount: @convention(c) (CInt) -> CInt
    /**
     Retrieves the name of the current mod's archive.

     # Parameters
     - `archive`: The archive's index/id.

     # Return Value
     NULL on error; the name of the archive on success

     # See also
     - `GetPrimaryModArchiveCount`
     */
    let GetPrimaryModArchiveList: @convention(c) (CInt) -> CString
    /**
     The reverse of `GetPrimaryModName()`

     # Parameter
     - `name`: The name of the mod

     #Return Value
     negative integer (< 0) on error (game was not found or GetPrimaryModCount() was not called yet); the index of the mod (>= 0) on success
     */
    let GetPrimaryModIndex: @convention(c) (CString) -> CInt
    /**
     Get checksum of mod

     # Parameters
     - `index`: The mods index/id

     # Return Value
     Zero on error; the checksum on success.

     # See Also
     - `GetMapChecksum`
     */
    let GetPrimaryModChecksum: @convention(c) (CInt) -> UInt32
    /**
     Get checksum of mod given the mod's name

     # Parameters
     - `name`: The name of the mod

     # Return Value
     Zero on error; the checksum on success.

     # See Also
     - `GetMapChecksumFromName`
     */
    let GetPrimaryModChecksumFromName: @convention(c) (CString) -> UInt32

    // MARK: Factions

    /**
     Retrieve the number of available sides

     This function parses the mod's side data, and returns the number of sides
     available. Be sure to map the mod into the VFS using `AddArchive()` or
     `AddAllArchives()` prior to using this function.

     # Return Value
     negative integer (< 0) on error; the number of sides (>= 0) on success
     */
    let GetSideCount: @convention(c) () -> CInt
    /**
     Retrieve a side's name

     Be sure you have made a call to `GetSideCount()` prior to using this.

     # Parameters
     - `side`: the index of the side

     # Return Value
     NULL on error; the side's name on success
     */
    let GetSideName: @convention(c) (CInt) -> CString
    /**
     Retrieve a side's default starting unit

     Be sure you have made a call to `GetSideCount()` prior to using this.

     # Return Value
     NULL on error; the side's starting unit name on success
     */
    let GetSideStartUnit: @convention(c) (CInt) -> CString

    // MARK: - Archive options

    /**
     Retrieve the number of map options available

     # Parameters
     - `mapName`: the name of the map, e.g. "SmallDivide"

     # Return Value
     negative integer (< 0) on error; the number of map options available (>= 0) on success
     # See Also
     - `GetOptionKey`
     - `GetOptionName`
     - `GetOptionDesc`
     - `GetOptionType`
     */
    let GetMapOptionCount: @convention(c) (CString) -> CInt
    /**
     Retrieve the number of mod options available

     Be sure to map the mod into the VFS using `AddArchive()` or `AddAllArchives()` prior to using this function.

     # Return Value
     negative integer (< 0) on error; the number of mod options available (>= 0) on success

     # See Also
     - `GetOptionKey`
     - `GetOptionName`
     - `GetOptionDesc`
     - `GetOptionType`
     */
    let GetModOptionCount: @convention(c) () -> CInt
    /**
     Retrieves the number of options available for a given Skirmish AI

     Be sure to call `GetSkirmishAICount()` prior to using this function.

     # Parameters
     - `index`: Skirmish AI index/id

     # Return Value
     negative integer (< 0) on error; the number of Skirmish AI options available (>= 0) on success

     # See Also
     - `GetSkirmishAICount`
     - `GetOptionKey`
     - `GetOptionName`
     - `GetOptionDesc`
     - `GetOptionType`
     */
    let GetSkirmishAIOptionCount: @convention(c) (CInt) -> CInt

    /**
     Returns the number of options available in a specific option file

     # Parameters
     - `fileName` the VFS path to a Lua file containing an options table

     # Return Value
     negative integer (< 0) on error; the number of options available (>= 0) on success

     # See Also
     - `GetOptionKey`
     - `GetOptionName`
     - `GetOptionDesc`
     - `GetOptionType`
     */
    let GetCustomOptionCount: @convention(c) (CString) -> CInt
    /**
     Retrieve an option's key

     For mods, maps or Skimrish AIs, the key of an option is the name it should be given in the start script
     (section [MODOPTIONS], [MAPOPTIONS] or [AI/OPTIONS]).

     Do not use this before having called `Get*OptionCount().`

     # Parameters
     - `optIndex` option index/id

     # Return Value
     NULL on error; the option's key on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionKey: @convention(c) (CInt) -> CString
    /**
     Retrieve an option's scope

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex` option index/id

     # Return Value
     NULL on error; the option's scope on success, one of:
     "global" (default), "player", "team", "allyteam"

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionScope: @convention(c) (CInt) -> CString
    /**
     Retrieve an option's name

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex` option index/id

     # Return Value
     NULL on error; the option's user visible name on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionName: @convention(c) (CInt) -> CString
    /**
     Retrieve an option's section

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     NULL on error; the option's section name on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionSection: @convention(c) (CInt) -> CString
    /**
    Retrieve an option's description
     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     NULL on error; the option's description on success

    - `GetMapOptionCount`
    - `GetModOptionCount`
    - `GetSkirmishAIOptionCount`
    - `GetCustomOptionCount`
    */
    let GetOptionDesc: @convention(c) (CInt) -> CString
    /**
     Retrieve an option's type

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     negative integer (< 0) or opt_error (0) on error; the option's type on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionType: @convention(c) (CInt) -> CInt
    /**
     Retrieve an opt_bool option's default value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     negative integer (< 0) on error; the option's default value (0 or 1) on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionBoolDef: @convention(c) (CInt) -> CInt
    /**
     Retrieve an opt_number option's default value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     the option's default value; -1.0f might imply a value of -1.0f or an error

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionNumberDef: @convention(c) (CInt) -> CFloat
    /**
     Retrieve an opt_number option's minimum value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     -1.0e30 on error; the option's minimum value on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionNumberMin: @convention(c) (CInt) -> CFloat
    /**
     Retrieve an opt_number option's maximum value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value +1.0e30 on error; the option's maximum value on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionNumberMax: @convention(c) (CInt) -> CFloat
    /**
     Retrieve an opt_number option's step value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     the option's step value; -1.0f might imply a value of -1.0f or an error

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionNumberStep: @convention(c) (CInt) -> CFloat
    /**
     Retrieve an opt_string option's default value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     NULL on error; the option's default value on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionStringDef: @convention(c) (CInt) -> CString
    /**
     Retrieve an opt_string option's maximum length

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     negative integer (< 0) on error; the option's maximum length (>= 0) on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionStringMaxLen: @convention(c) (CInt) -> CInt
    /**
     Retrieve an opt_list option's number of available items

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     negative integer (< 0) on error; the option's number of available items (>= 0) on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionListCount: @convention(c) (CInt) -> CInt
    /**
     Retrieve an opt_list option's default value

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id

     # Return Value
     NULL on error; the option's default value (list item key) on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionListDef: @convention(c) (CInt) -> CInt
    /**
     Retrieve an opt_list option item's key

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id
     - `itemIndex`: list item index/id


     # Return value
     NULL on error; the option item's key (list item key) on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionListItemKey: @convention(c) (CInt, CInt) -> CString
    /**
     Retrieve an opt_list option item's name

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id
     - `itemIndex`: list item index/id

     # Return Value
     NULL on error; the option item's name on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionListItemName: @convention(c) (CInt, CInt) -> CString
    /**
     Retrieve an opt_list option item's description

     Do not use this before having called `Get*OptionCount()`.

     # Parameters
     - `optIndex`: option index/id
     - `itemIndex`: list item index/id

     # Return Value
     NULL on error; the option item's description on success

     # See Also
     - `GetMapOptionCount`
     - `GetModOptionCount`
     - `GetSkirmishAIOptionCount`
     - `GetCustomOptionCount`
     */
    let GetOptionListItemDesc: @convention(c) (CInt, CInt) -> CString

    // MARK: - Mod Valid Maps

    /**
     Retrieve the number of valid maps for the current mod.

     Be sure to map the mod into the VFS using `AddArchive()` or `AddAllArchives()` prior to using this function.

     # Return Value
     Negative integer (< 0) on error; the number of valid maps (>= 0) on success.
     A return value of 0 means that any map can be selected.
     */
    let GetModValidMapCount: @convention(c) () -> CInt
    /**
     Retrieve the name of a map valid for the current mod.

     Map names should be complete (including the .smf or .sm3 extension).
     Be sure you have made a call to `GetModValidMapCount()` prior to using this.

     # Return Value
     NULL on error; the name of the map on success
     */
    let GetModValidMap: @convention(c) (CInt) -> CString

    // MARK: - Virtual File System

    /**
     Open a file from the VFS.

     The returned file handle is needed for subsequent calls to `CloseFileVFS()`, `ReadFileVFS()` and `FileSizeVFS()`.
     Map the wanted archives into the VFS with AddArchive() or AddAllArchives() before using this function.

     # Parameters:
     - `name`: the name of the file

     # Return Value
     Zero on error; a non-zero file handle on success.
     */
    let OpenFileVFS: @convention(c) (CString) -> CInt
    /**
     Close a file in the VFS.

     # Parameters
     - `file`: the file handle as returned by `OpenFileVFS()`
     */
    let CloseFileVFS: @convention(c) (CInt) -> Void
    /**
    Read some data from a file in the VFS

     # Parameters
    - `file`: the file handle as returned by OpenFileVFS()
    - `buf`: output buffer, must be at least of size numBytes
    - `numBytes`: how many bytes to read from the file

     # Return Value
     -1 on error; the number of bytes read on success
     (if this is less than length, you reached the end of the file.)
     */
    let ReadFileVFS: @convention(c) (CInt, CString, MutableCString, CInt) -> CInt
    /**
     Retrieve size of a file in the VFS

     # Parameters
     - `file`: the file handle as returned by OpenFileVFS()

     # Return Value
     -1 on error; the size of the file on success
     */
    let FileSizeVFS: @convention(c) (CInt) -> CInt
    /**
     Find files in VFS by glob

     Does not currently support more than one call at a time; a new call to this function destroys data from previous ones.
     Pass the returned handle to FindFilesVFS to get the results.

     # Parameters
     - `pattern`: glob used to search for files, for example "*.png"

     # Return Value
     Handle to the first file found that matches the pattern, or 0 if no file was found or an error occurred

     # See Also
     - `FindFilesVFS`
     */
    let InitFindVFS: @convention(c) (CString) -> CInt
    /**
     Find files in VFS by glob in a sub-directory

     Does not currently support more than one call at a time; a new call to this function destroys data from previous ones.
     Pass the returned handle to FindFilesVFS to get the results.

     # Parameters
     - `path`: sub-directory to search in
     - `pattern`: glob used to search for files, for example "*.png"
     - `modes`: which archives to search, see System/FileSystem/VFSModes.h

     # Return Value
     handle to the first file found that matches the pattern, or 0 if no file was found or an error occurred

     # See Also
     - `FindFilesVFS`
     */
    let InitDirListVFS: @convention(c) (CString, CString, CString) -> CInt
    /**
     Find directories in VFS by glob in a sub-directory.

     Does not currently support more than one call at a time; a new call to this function destroys data from previous ones.
     Pass the returned handle to FindFilesVFS to get the results.

     # Parameters
     - `path`: sub-directory to search in
     - `pattern`: glob used to search for directories, for example "iLove*"
     - `modes`: which archives to search, see System/FileSystem/VFSModes.h

     # Return Value
     handle to the first file found that matches the pattern, or 0 if no file was found or an error occurred

     # See Also
     - `FindFilesVFS`
     */
    let InitSubDirsVFS: @convention(c) (CString, CString, CString) -> CInt
    /**
     Find the next file.
     On first call, pass a handle from any of the `Init*VFS()` functions.
     On subsequent calls, pass the return value of this function.

     # Parameters
     - `file`: the file handle as returned by any of the `Init*VFS()` functions or
     *   this one.
     - `nameBuf`: out-param to contain the VFS file-path
     - `size`: should be set to the size of nameBuf

     # Return Value
     new file handle or 0 on error

     # See Also
     - `InitFindVFS`
     - `InitDirListVFS`
     - `InitSubDirsVFS`
     */
    let FindFilesVFS: @convention(c) (CInt, MutableCString, MutableCInt) -> CInt
    /**
     Open an archive

     # Parameter
     - `name`: the name of the archive (*.sdz, *.sd7, ...)

     # Return Value
     Zero on error; a non-zero archive handle on success.

     # See Also
     - `OpenArchiveType`
     */
    let OpenArchive: @convention(c) (CString) -> CInt
    /**
     Close an archive in the VFS

     # Parameters
     - `archive` the archive handle as returned by `OpenArchive()`
     */
    let CloseArchive: @convention(c) (CInt) -> Void
    /**
     Browse through files in a VFS archive

     # Parameters
     - `archive`: the archive handle as returned by `OpenArchive()`
     - `file`: the index of the file in the archive to fetch info for
     - `nameBuf`: out-param, will contain the name of the file on success
     - `size`: in&out-param, has to contain the size of nameBuf on input, will contain the file-size as output on success

     # Return Value
     Zero on error; a non-zero file handle on success.
     */
    let FindFilesArchive: @convention(c) (CInt, CInt, MutableCString, MutableCInt) -> CInt
    /**
     Open an archive member.

     The returned file handle is needed for subsequent calls to
     `ReadArchiveFile()`, `CloseArchiveFile()` and `SizeArchiveFile()`.

     # Parameters
     - `archive`: the archive handle as returned by `OpenArchive()`
     - `name`: the name of the file

     # Return Value
     negative integer (< 0) on error; the file-ID/-handle within the archive (>= 0) on success
     */
    let OpenArchiveFile: @convention(c) (CInt, CString) -> CInt
    /**
     Read some data from an archive member

     # Parameters
     - `archive`: the archive handle as returned by OpenArchive()
     - `file`: the file handle as returned by OpenArchiveFile()
     - `buffer`: output buffer, must be at least numBytes bytes
     - `numBytes`: how many bytes to read from the file

     # Return Value
     -1 on error; the number of bytes read on success (if this is less than numBytes you reached the end of the file.)
     */
    let ReadArchiveFile: @convention(c) (CInt, CInt, CData, CInt) -> CInt
    /**
     Close an archive member

     # Parameters
     - `archive`: the archive handle as returned by OpenArchive()
     - `file`: the file handle as returned by OpenArchiveFile()
     */
    let CloseArchiveFile: @convention(c) (CInt, CInt) -> Void
    /**
     Retrieve size of an archive member

     # Parameters
     - `archive`: the archive handle as returned by OpenArchive()
     - `file`: the file handle as returned by OpenArchiveFile()

     # Return Value
     -1 on error; the size of the file on success
     */
    let SizeArchiveFile: @convention(c) (CInt, CInt) -> CInt

    // MARK: - Spring Config

    /**
     (Re-)Loads the global config-handler

     # Parameters
     - `fileNameAsAbsolutePath`: the config file to be used, if NULL, the default one is used

     # See Also
     - `GetSpringConfigFile`
     */
    let SetSpringConfigFile: @convention(c) (CString) -> Void
    /**
     Returns the path to the config-file path

     # Return Value
     the absolute path to the config-file in use by the config-handler

     # See Also
     - `SetSpringConfigFile`
     */
    let GetSpringConfigFile: @convention(c) () -> CString
    /**
     Get string from Spring configuration

     # Parameters
     - `name`: name of key to get
     - `defValue`: default string value to use if the key is not found, may not be NULL

     # Return Value
     string value
     */
    let GetSpringConfigString: @convention(c) (CString, CString) -> CString
    /**
     Get integer from Spring configuration

     # Parameters
     - `name`: name of key to get
     - `defValue`: default integer value to use if the key is not found, may not be NULL

     # Return Value
     integer value
     */
    let GetSpringConfigInt: @convention(c) (CString, CInt) -> CInt
    /**
     Get float from Spring configuration

     # Parameters
     - `name`: name of key to get
     - `defValue`: default float value to use if the key is not found, may not be NULL

     # Return Value
     float value
     */
    let GetSpringConfigFloat: @convention(c) (CString, CFloat) -> CFloat
    /**
     Set string in Spring configuration

     # Parameters
     - `name`: name of key to set
     - `value`: string value to set
     */
    let SetSpringConfigString: @convention(c) (CString, CString) -> Void
    /**
     Set integer in Spring configuration

     # Parameters
     - `name`: name of key to set
     - `value`: integer value to set
     */
    let SetSpringConfigInt: @convention(c) (CString, CInt) -> Void
    /**
     Set float in Spring configuration

     # Parameters
     - `name`: name of key to set
     - `value`: float value to set
     */
    let SetSpringConfigFloat: @convention(c) (CString, CFloat) -> Void
    /**
     Deletes configkey in Spring configuration.

     # Parameters:
     - `name`: name of key to delete
     */
    let DeleteSpringConfigKey: @convention(c) (CString) -> Void

    // MARK: - Lua Parser API

    private let lpClose: @convention(c) () -> Void
    private let lpOpenFile: @convention(c) (CString, CString, CString) -> CInt
    private let lpOpenSource: @convention(c) (CString, CString) -> CInt
    private let lpExecute: @convention(c) () -> CInt
    private let lpErrorLog: @convention(c) () -> CString

    private let lpAddTableInt: @convention(c) (CInt, CInt) -> Void
    private let lpAddTableStr: @convention(c) (CString, CInt) -> Void
    private let lpEndTable: @convention(c) () -> Void
    private let lpAddIntKeyIntVal: @convention(c) (CInt, CInt) -> Void
    private let lpAddStrKeyIntVal: @convention(c) (CString, CInt) -> Void
    private let lpAddIntKeyBoolVal: @convention(c) (CInt, CBool) -> Void
    private let lpAddStrKeyBoolVal: @convention(c) (CString, CBool) -> Void
    private let lpAddIntKeyFloatVal: @convention(c) (CInt, CFloat) -> Void
    private let lpAddStrKeyFloatVal: @convention(c) (CString, CFloat) -> Void
    private let lpAddIntKeyStrVal: @convention(c) (CString, CFloat) -> Void
    private let lpAddStrKeyStrVal: @convention(c) (CString, CString) -> Void

    private let lpRootTable: @convention(c) () -> CInt
    private let lpRootTableExpr: @convention(c) (CString) -> CInt
    private let lpSubTableInt: @convention(c) (CInt) -> CInt
    private let lpSubTableStr: @convention(c) (CString) -> CInt
    private let lpSubTableExpr: @convention(c) (CString) -> CInt
    private let lpPopTable: @convention(c) () -> Void

    private let lpGetKeyExistsInt: @convention(c) (CInt) -> CInt
    private let lpGetKeyExistsStr: @convention(c) (CString) -> CInt

    private let lpGetIntKeyType: @convention(c) (CInt) -> CInt
    private let lpGetStrKeyType: @convention(c) (CString) -> CInt

    private let lpGetIntKeyListCount: @convention(c) () -> CInt
    private let lpGetIntKeyListEntry: @convention(c) (CInt) -> CInt
    private let lpGetStrKeyListCount: @convention(c) () -> CInt
    private let lpGetStrKeyListEntry: @convention(c) (CInt) -> CString

    private let lpGetIntKeyIntVal: @convention(c) (CInt, CInt) -> CInt
    private let lpGetStrKeyIntVal: @convention(c) (CString, CInt) -> CInt
    private let lpGetIntKeyBoolVal: @convention(c) (CInt, CBool) -> CBool
    private let lpGetStrKeyBoolVal: @convention(c) (CString, CBool) -> CBool
    private let lpGetIntKeyFloatVal: @convention(c) (CInt, CFloat) -> CFloat
    private let lpGetStrKeyFloatVal: @convention(c) (CString, CFloat) -> CFloat
    private let lpGetIntKeyStrVal: @convention(c) (CInt, CString) -> CString
    private let lpGetStrKeyStrVal: @convention(c) (CString, CString) -> CString

    // MARK: - Deprecated functions

    // (Not all deprecated functions are included here.)

    let GetMapDescription: @convention(c) (CInt) -> CString
    let GetMapAuthor: @convention(c) (CInt) -> CString
    let GetMapWidth: @convention(c) (CInt) -> CInt
    let GetMapHeight: @convention(c) (CInt) -> CInt
    let GetMapTidalStrength: @convention(c) (CInt) -> CInt
    let GetMapWindMin: @convention(c) (CInt) -> CInt
    let GetMapWindMax: @convention(c) (CInt) -> CInt
    let GetMapGravity: @convention(c) (CInt) -> CInt
    let GetMapResourceCount: @convention(c) (CInt) -> CInt
    let GetMapResourceName: @convention(c) (CInt,CInt) -> CString
    let GetMapResourceMax: @convention(c) (CInt,CInt) -> CFloat
    let GetMapResourceExtractorRadius: @convention(c) (CInt,CInt) -> CInt
    let GetMapPosCount: @convention(c) (CInt) -> CInt
    let GetMapPosX: @convention(c) (CInt,CInt) -> CFloat
    let GetMapPosZ: @convention(c) (CInt,CInt) -> CFloat
}


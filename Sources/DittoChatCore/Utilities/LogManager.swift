//
//  Copyright © 2021 DittoLive Incorporated. All rights reserved.
//

import Foundation
#if canImport(MessageUI)
import MessageUI
#endif
import UIKit

fileprivate struct Config {
    static let logsDirectoryName = "ditto-debug-logs"
    static let logFileName = "DittoLogs.txt"
    static let zippedLogFileName = "DittoLogs.zip"

    /// Directory into which debug logs are to be stored. We use a dedicated
    /// directory to keep logs grouped (in the event that we begin generating
    /// more than one log - either from multiple sub-systems or due to log
    /// rotation).
    static var logsDirectory: URL! = {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(logsDirectoryName, isDirectory: true)
    }()

    /// URL within `logsDirectory` for our latest debug logs to stream.
    static var logFileURL: URL! = {
        return Self.logsDirectory.appendingPathComponent(Config.logFileName)
    }()

    /// A temporary location into which we can store zipped logs before sharing
    /// them via a share sheet.
    static var zippedLogsURL: URL! = {
        let directory = FileManager.default.temporaryDirectory
        return directory.appendingPathComponent(Config.zippedLogFileName)
    }()
}

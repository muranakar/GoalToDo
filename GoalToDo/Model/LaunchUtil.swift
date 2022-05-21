//
//  LaunchUtil.swift
//  GoalToDo
//
//  Created by 村中令 on 2022/05/21.
//

import Foundation

enum LaunchStatus {
    case firstLaunch
    case newVersionLaunch
    case launched
}

class LaunchUtil {
    static let launchedVersionKey = "launchedVersion"

    static var launchStatus: LaunchStatus {
        get {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let launchedVersion = self.loadLaunchedVersion()

            self.saveLaunchedVersion()

            if launchedVersion == "" {
                return .firstLaunch
            }

            return version == launchedVersion ? .launched : .newVersionLaunch
        }
    }
    static func saveLaunchedVersion() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        UserDefaults.standard.set(version, forKey: self.launchedVersionKey)
    }
    static func loadLaunchedVersion() -> String {
        let version = UserDefaults.standard.string(forKey: self.launchedVersionKey) ?? ""
        return version
    }
}

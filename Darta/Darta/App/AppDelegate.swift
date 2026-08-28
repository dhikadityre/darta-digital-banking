//
//  AppDelegate.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 19/08/26.
//

import DebugSwift
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    private let debugSwift = DebugSwift()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        #if DEBUG
        debugSwift.setup()
        // debugSwift.setup(disable: [.leaksDetector])
        debugSwift.show()
        #endif
        
        return true
    }
}

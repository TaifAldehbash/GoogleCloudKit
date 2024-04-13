//
//  GoogleCloudKit.swift
//
//  Created by Taif Al.qahtani on 13/04/2024.
//

import Foundation

public class GoogleCloudKit {
    // Singleton instance
    public static let shared = GoogleCloudKit()
    
    // Initialize CloudStorageManager
    let cloudStorageManager = CloudStorageManager.shared
    
    // Initialize GoogleAPIManager
    let googleAPIManager = GoogleAPIManager.shared
    
    // Private initializer to enforce singleton
    private init() {}
    
    // Method to initialize CloudStorageManager
    public static func initializeCloudStorageManager() -> CloudStorageManager {
        return CloudStorageManager.shared
    }
    
    // Method to initialize GoogleAPIManager
    public static func initializeGoogleAPIManager() -> GoogleAPIManager {
        return GoogleAPIManager.shared
    }
}


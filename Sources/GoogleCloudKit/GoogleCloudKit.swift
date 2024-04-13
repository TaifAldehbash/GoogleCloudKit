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
    public let cloudStorageManager = CloudStorageManager.shared
    
    // Initialize GoogleAPIManager
    public let googleAPIManager = GoogleAPIManager.shared
    
    // Private initializer to enforce singleton
    private init() {}
    
    // Method to initialize GoogleCloudKit.shared with any necessary configuration
    private static func initialize() {}
}


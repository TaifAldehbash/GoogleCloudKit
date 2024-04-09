//
//  CloudStorageManager.swift
//
//  Created by Taif Al.qahtani on 03/04/2024.
//

import Foundation
import FirebaseStorage
import FirebaseCore
import UIKit

class CloudStorageManager {
    static let shared = CloudStorageManager()
    private let storage = Storage.storage()
    
    private init() {
        FirebaseApp.configure()
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (URL?, Error?) -> Void) {
        
        
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, CloudStorageError.imageDataConversionFailed)
            return
        }
        
        // Create a reference to the Firebase Storage bucket
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(UUID().uuidString).jpg")
        
        // Upload the file to the Firebase Storage bucket
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                completion(nil, CloudStorageError.uploadFailed)
                return
            }
            // If the upload is successful, get the download URL
            imageRef.downloadURL { url, error in
                if let downloadURL = url {
                    completion(downloadURL, nil)
                } else {
                    completion(nil, CloudStorageError.downloadURLNotFound)
                }
            }
        }
    }
}

enum CloudStorageError: Error {
    case imageDataConversionFailed
    case uploadFailed
    case downloadURLNotFound
}

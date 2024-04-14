//
//  GoogleAPIManager.swift
//
//  Created by Taif Al.qahtani on 03/04/2024.
//
import Foundation
import GoogleSignIn
import Alamofire
import SwiftyJSON
import FirebaseCore
import FirebaseAuth
import SwiftUI

@available(iOS 13.0, *)
public class GoogleAPIManager {
    public static let shared = GoogleAPIManager()
    
    private var spreadsheetId = "1VhyyuTkWc14CVtUatF98atRKVnWXV17GMF0c4HwUo-U"
    private var accessToken: String?
    
    private init() {}
    
    // Method to set OAuth2 access token
    public func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    // Function to create a new sheet tab for a given title
    public func createSheetTab(title: String, completion: @escaping (Bool, Error?) -> Void) {
        
        guard let token = accessToken else {
            completion(false, NSError(domain: "GoogleAPIManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Access token is missing"]))
            return
        }
        
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId):batchUpdate"
        
        let sheetTitle = title
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken!)"
        ]
        
        let requestJSON: [String: Any] = [
            "requests": [
                [
                    "addSheet": [
                        "properties": [
                            "title": sheetTitle
                        ]
                    ]
                ]
            ]
        ]
        
        AF.request(url, method: .post, parameters: requestJSON, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response { response in
                debugPrint(response)
                switch response.result {
                    case .success:
                        completion(true, nil)
                    case .failure(let error):
                        completion(false, error)
                }
            }
    }
    
    // Function to check if a sheet with the specified name exists
    public func checkSheetExists(sheetName: String, completion: @escaping (Bool, Error?) -> Void) {
    let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)"
    
    let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken!)"
        ]
        
    AF.request(url, headers: headers).responseData { response in
        switch response.result {
            case .success(let data):
                let json = JSON(data)
                let sheets = json["sheets"].arrayValue
                for sheet in sheets {
                    let properties = sheet["properties"]
                    if let title = properties["title"].string, title == sheetName {
                        completion(true, nil)
                        return
                    }
                }
                completion(false, nil) // Sheet not found
            case .failure(let error):
                completion(false, error)
        }
    }
}
    
    // Function to upload data to a specific sheet in Google Sheets
    public func uploadDataToGoogleSheets(sheetName: String, data: [[Any]], completion: @escaping (Bool, Error?) -> Void) {
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!A1:append?valueInputOption=RAW"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken!)"
        ]
        
        let requestData: [String: Any] = [
            "range": "A1",
            "majorDimension": "ROWS",
            "values": data
        ]
        
        AF.request(url, method: .post, parameters: requestData, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .response { response in
                debugPrint(response)
                switch response.result {
                    case .success:
                        completion(true, nil)
                    case .failure(let error):
                        completion(false, error)
                }
            }
    }
    
    // Function to sign user in using GoogleSignIn
    func signInWithGoogle(completion: @escaping (String?, Error?) -> Void) {
        // Configure Google sign-in
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { authentication, error in
            if let error = error {
                completion(nil, error)
            }
            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else { return }
            
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    completion(nil, error)
                } else {
                    completion(accessToken, nil)
                }
            }
        }
    }
    
}

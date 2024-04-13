//
//  GoogleAPIManager.swift
//
//  Created by Taif Al.qahtani on 03/04/2024.
//
import Foundation
import Alamofire
import SwiftyJSON

public class GoogleAPIManager {
    static let shared = GoogleAPIManager()
    
    private var spreadsheetId = ProcessInfo.processInfo.environment["SPREADSHEET_ID"] ?? ""
    private let apiKey = ProcessInfo.processInfo.environment["GOOGLE_SHEETS_API_KEY"] ?? ""
    
    private init() {}
    
    // Function to create a new sheet tab for a given title
    func createSheetTab(title: String, completion: @escaping (Bool, Error?) -> Void) {
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId):batchUpdate?key=\(apiKey)"
        
        let sheetTitle = title
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
        
        AF.request(url, method: .post, parameters: requestJSON, encoding: JSONEncoding.default)
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
    func checkSheetExists(sheetName: String, completion: @escaping (Bool, Error?) -> Void) {
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)?key=\(apiKey)"
        
        AF.request(url).responseData { response in
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
    func uploadDataToGoogleSheets(sheetName: String, data: [[Any]], completion: @escaping (Bool, Error?) -> Void) {
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!A1:append?valueInputOption=RAW&key=\(apiKey)"
        
        let requestData: [String: Any] = [
            "range": "A1",
            "majorDimension": "ROWS",
            "values": data
        ]
        
        AF.request(url, method: .post, parameters: requestData, encoding: JSONEncoding.default)
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

}

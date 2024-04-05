//
//  GoogleAPIManager.swift
//
//  Created by Taif Al.qahtani on 03/04/2024.
//
import Foundation
import Alamofire
import SwiftyJSON

class GoogleAPIManager {
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
    
    // Function to get the latest entries from the latest three tabs
    func getLatestEntriesFromLatestThreeTabs(completion: @escaping ([Any]?, Error?) -> Void) {
        // URL for fetching sheet metadata
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)?fields=sheets.properties.title&key=\(apiKey)"
        
        AF.request(url)
            .validate()
            .responseData { response in
                debugPrint(response)
                switch response.result {
                    case .success(let data):
                        let json : JSON = JSON(data)
                        let sheets = json["sheets"].arrayValue
                        var tabTitles = [String]()
                        
                        for sheet in sheets {
                            let properties = sheet["properties"]
                            let title = properties["title"].stringValue
                            tabTitles.append(title)
                            
                        }
                        tabTitles.sort()
                        let latestThreeTabs = tabTitles.suffix(3)
                        
                        var resultData = [Any]()
                        let group = DispatchGroup()
                        for tabTitle in latestThreeTabs {
                            group.enter()
                            self.fetchDataFromTab(tabTitle: tabTitle) { data, error in
                                defer {
                                    group.leave()
                                }
                                if let data = data {
                                    resultData.append(contentsOf: data)
                                } else if let error = error {
                                    completion(nil, error)
                                }
                            }
                        }
                        group.notify(queue: DispatchQueue.global()) {
                            completion(resultData, nil)
                        }
                    case .failure(let error):
                        completion(nil, error)
                }
            }
    }
    
    // Helper function to fetch data from a specific tab
    private func fetchDataFromTab(tabTitle: String, completion: @escaping ([Any]?, Error?) -> Void) {
        let url = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(tabTitle)?key=\(apiKey)&majorDimension=ROWS"
        
        AF.request(url)
            .validate()
            .responseData { response in
                debugPrint(response)
                switch response.result {
                    case .success(let data):
                        let json : JSON = JSON(response.data!)
                        let values = json["values"].arrayValue
                        completion(values, nil)
                    case .failure(let error):
                        completion(nil, error)
                }
            }
    }
}
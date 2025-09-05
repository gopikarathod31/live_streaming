//
//  APIManager.swift
//  Tomato
//
//  Created by MultiQoS on 05/04/2021.
//  Copyright © 2021 MultiQoS. All rights reserved.
//

import Foundation
import Alamofire


struct APIResposne {
    
    var message: String
    var fullResponse: [String: Any]
    var statusCode : Int
    var status: HTTPStatusCode.ResponseType {
        return HTTPStatusCode(rawValue: self.statusCode)?.responseType ?? .undefined
    }
    
    fileprivate static func getSuccessObject(dict: [String: Any], statusCode:Int, enableApiLogs: Bool = true) -> APIResposne {
        
        /*var statusCode = dict["status"] as? Int ?? 0
         if !(400 ... 500).contains(statusCode) {
         statusCode = 200
         }*/
        let msg = dict["message"] as? String ?? ""
        
        if enableApiLogs {
            print("\n\nreponse:- \(dict) \n\n")
        }
        
        return APIResposne(message: msg, fullResponse: dict, statusCode: statusCode)
    }
    
    fileprivate static func getErrorObject(error: Error, status : Int) -> APIResposne {
        return APIResposne(message: error.localizedDescription ,fullResponse: [:], statusCode: status)
    }
}

class APIManager {
    
    var headers: HTTPHeaders {
        
        var authorization : String = AppUserDefaults[.authorization] ?? ""
        
//        if !authorization.isBlank {
//            authorization = "Bearer \(authorization)"
//        }
        
        let encodedAuthInfo = String(format: "%@:%@", "23533553-3a3b-4b43-84f1-89120dcee376", "zBGbP9jE5PhU8wpHbAH5wkNI5rUm1opR0Ko8Yc1zIeKMHqIr3o6gHVfqcJP+6FwRCZj+1HTgz3H")
                    .data(using: String.Encoding.utf8)!
                    .base64EncodedString()
        
        return [ "Accept" : "application/json",
                 "Content-Type" : "application/json",
                 "Authorization" : "Basic \(encodedAuthInfo)"]
    }
    
    private init() {
        
    }
    
    lazy var AFSession: Session = {
        let rootQueue = DispatchQueue(label: "org.alamofire.sessionManager.rootQueue")
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.underlyingQueue = rootQueue
        delegateQueue.name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "appName"
        let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "com.task.background"
        let sessionDelegate = SessionDelegate.init(fileManager: FileManager.default)
        
        let urlSession = URLSession.init(configuration: URLSessionConfiguration.background(withIdentifier: bundleId), delegate: SessionDelegate(), delegateQueue: delegateQueue)
        return Session.init(session: urlSession, delegate: sessionDelegate, rootQueue: rootQueue)
    }()
    static let shared = APIManager()
    
    @discardableResult
    func request(request:APIRequest, responseHandler: @escaping (APIResposne)->Void) -> DataRequest? {
        
        let apiURL = request.apiName.name
        
        return AF.request(apiURL, method: request.method, parameters: request.params , encoding: request.encodingType.type, headers: request.headers ?? headers).responseJSON { (response) in
            
            
            if request.enableApiLogs {
                print("METHOD..: \(request.method.rawValue)")
                print("URL.....: \(apiURL)")
                print("STATUS..: \(response.response?.statusCode ?? 0)")
                print("BODY....: \(request.params.toJson())")
                print("HEADERS....: \(self.headers)")
            }
            
            let statusCode = response.response?.statusCode ?? 200
            switch response.result {
            case .success(let data):
                guard let dict = data as? [String: Any] else {
                    responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: statusCode))
                    return
                }
                DispatchQueue.main.async {
                    responseHandler(APIResposne.getSuccessObject(dict: dict, statusCode: statusCode, enableApiLogs: request.enableApiLogs))
                }
            case .failure(let error):
                print("error.responseCode : \(error.responseCode ?? -1000)")
                print("error : \(error.errorDescription ?? "N/A")")
                responseHandler(APIResposne.getErrorObject(error: error, status: error.responseCode ?? -100))
            }
        }
    }
    
    
    @discardableResult
    func requestWithOutParam(request:APIRequest, responseHandler: @escaping (APIResposne)->Void) -> DataRequest? {
        
        let apiURL = request.apiName.name
        
        return AF.request(apiURL, method: request.method , encoding: request.encodingType.type, headers: request.headers ?? headers).responseJSON { (response) in
            
            
            if request.enableApiLogs {
                print("METHOD..: \(request.method.rawValue)")
                print("URL.....: \(apiURL)")
                print("STATUS..: \(response.response?.statusCode ?? 0)")
                print("BODY....: \(request.params.toJson())")
                print("HEADERS....: \(self.headers)")
            }
            
            let statusCode = response.response?.statusCode ?? 200
            switch response.result {
            case .success(let data):
                guard let dict = data as? [String: Any] else {
                    responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: statusCode))
                    return
                }
                DispatchQueue.main.async {
                    responseHandler(APIResposne.getSuccessObject(dict: dict, statusCode: statusCode, enableApiLogs: request.enableApiLogs))
                }
            case .failure(let error):
                print("error.responseCode : \(error.responseCode ?? -1000)")
                print("error : \(error.errorDescription ?? "N/A")")
                responseHandler(APIResposne.getErrorObject(error: error, status: error.responseCode ?? -100))
            }
        }
    }
    
    @discardableResult
    func requestWithImage(request:APIImageRequest, responseHandler: @escaping (APIResposne)->Void) -> DataRequest? {
        
        let apiURL = request.apiName.name
        
        let uploadRequest = AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in request.params {
                    print("\(value)".data(using: String.Encoding.utf8)!)
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    print(multipartFormData)
                }
                for (key, value) in request.singleImage {
                    if let data = value.media.mediaData{
                        let fileName = "\(Date().timeIntervalSince1970)." + value.mediaType.mediaExtension
                        multipartFormData.append(data, withName: key, fileName: fileName, mimeType:value.mediaType.mime)
                    }
                }
            },
            to: apiURL, method: request.method , headers: headers)
            .response { response in
                
                print("METHOD..: \(request.method.rawValue)")
                print("URL.....: \(apiURL)")
                print("BODY....: \(request.params.toJson())")
                print("HEADERS....: \(self.headers)")
                
                if let error = response.error {
                    responseHandler(APIResposne.getErrorObject(error: error, status: response.response?.statusCode ?? -100))
                    return
                }
                
                do{
                    guard let jsonData = response.data else {
                        responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                        return
                    }
                    
                    let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
                    
                    DispatchQueue.main.async {
                        responseHandler(APIResposne.getSuccessObject(dict: parsedData, statusCode: response.response?.statusCode ?? 200, enableApiLogs: request.enableApiLogs))
                    }
                    
                } catch {
                    responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                }
            }
        uploadRequest.uploadProgress { (progress) in
            request.uploadingProgress?(progress.fractionCompleted)
        }
        
        return uploadRequest
    }
    
    @discardableResult
    func requestWithImages(request:APIImagesRequest, responseHandler: @escaping (APIResposne)->Void) -> DataRequest? {
        
        let apiURL = request.apiName.name
        
        let uploadRequest = AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in request.params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                for (key, value) in request.multipleImage {
                    
                    for media in value {
                        if let data = media.media.mediaData {
                            //                            let fileName = fileNamePrefix + media.mediaType.mediaExtension
                            var fileName = ""
                            if let fName = media.fileName {
                                fileName =  fName
                            }else {
                                fileName = "\(Date().timeIntervalSince1970).\(media.mediaType.mediaExtension)"
                            }
                            
                            //                            multipartFormData.append(data, withName: key + "[]", fileName: fileName, mimeType:media.mediaType.mime)
                            print("FILE NAME..: \(fileName)")
                            multipartFormData.append(data, withName: key + "[]", fileName: fileName, mimeType:media.mediaType.mime)
                        }
                    }
                    
                }
            },
            to: apiURL, method: request.method , headers: headers)
            .response { response in
                
                print("METHOD..: \(request.method.rawValue)")
                print("URL.....: \(apiURL)")
                print("BODY....: \(request.params.toJson())")
                print("HEADERS....: \(self.headers)")
                
                if let error = response.error {
                    responseHandler(APIResposne.getErrorObject(error: error, status: response.response?.statusCode ?? -100))
                    return
                }
                
                do{
                    guard let jsonData = response.data else {
                        responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                        return
                    }
                    
                    let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
                    
                    DispatchQueue.main.async {
                        responseHandler(APIResposne.getSuccessObject(dict: parsedData, statusCode: response.response?.statusCode ?? 200, enableApiLogs: request.enableApiLogs))
                    }
                    
                }catch{
                    responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                }
            }
        uploadRequest.uploadProgress { (progress) in
            request.uploadingProgress?(progress.fractionCompleted)
        }
        
        return uploadRequest
    }
    
    @discardableResult
    func requestWithImageAndImages(request:APIImagesAndImagesRequest, responseHandler: @escaping (APIResposne)->Void) -> DataRequest? {
        
        let apiURL = request.apiName.name
        
        let uploadRequest = AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in request.params {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                for (key, value) in request.singleImage {
                    if let data = value.media.mediaData{
                        let fileName = "\(Date().timeIntervalSince1970)." + value.mediaType.mediaExtension
                        multipartFormData.append(data, withName: key, fileName: fileName, mimeType:value.mediaType.mime)
                    }
                }
                for (key, value) in request.multipleImage {
                    
                    for media in value {
                        if let data = media.media.mediaData {
                            //                            let fileName = fileNamePrefix + media.mediaType.mediaExtension
                            var fileName = ""
                            if let fName = media.fileName {
                                fileName =  fName
                            }else {
                                fileName = "\(Date().timeIntervalSince1970).\(media.mediaType.mediaExtension)"
                            }
                            
                            //                            multipartFormData.append(data, withName: key + "[]", fileName: fileName, mimeType:media.mediaType.mime)
                            print("FILE NAME..: \(fileName)")
                            multipartFormData.append(data, withName: key + "[]", fileName: fileName, mimeType:media.mediaType.mime)
                        }
                    }
                    
                }
            },
            to: apiURL, method: request.method , headers: headers)
            .response { response in
                
                print("METHOD..: \(request.method.rawValue)")
                print("URL.....: \(apiURL)")
                print("BODY....: \(request.params.toJson())")
                print("HEADERS....: \(self.headers)")
                
                if let error = response.error {
                    responseHandler(APIResposne.getErrorObject(error: error, status: response.response?.statusCode ?? -100))
                    return
                }
                
                do{
                    guard let jsonData = response.data else {
                        responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                        return
                    }
                    
                    let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
                    
                    DispatchQueue.main.async {
                        responseHandler(APIResposne.getSuccessObject(dict: parsedData, statusCode: response.response?.statusCode ?? 200, enableApiLogs: request.enableApiLogs))
                    }
                    
                }catch{
                    responseHandler(APIResposne(message:  "Invalid JSON.", fullResponse: [:], statusCode: response.response?.statusCode ?? -100))
                }
            }
        uploadRequest.uploadProgress { (progress) in
            request.uploadingProgress?(progress.fractionCompleted)
        }
        
        return uploadRequest
    }
}


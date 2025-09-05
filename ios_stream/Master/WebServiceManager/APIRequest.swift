//
//  APIRequest.swift
//  Tomato
//
//  Created by MultiQoS on 05/04/2021.
//  Copyright © 2021 MultiQoS. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

typealias Json = [String:Any]

enum RequestType {
    case queryString
    case httpBody
    case `default`
    case jsonDefault
    
    var type: ParameterEncoding {
        
        switch self {
        case .queryString:
            return URLEncoding.queryString
        case .httpBody:
            return URLEncoding.httpBody
        case .jsonDefault:
            return JSONEncoding.default
        case .default:
            return URLEncoding.default
        
        }
    }
}

class APIRequest {
    
    var apiName: APIName
    var method: HTTPMethod
    var params: Json
    var encodingType : RequestType
    var headers: HTTPHeaders?
    var enableApiLogs: Bool = true
    
    init(apiName: APIName, params: Json = [:],method: HTTPMethod = .post, encodingType : RequestType = .default, headers: HTTPHeaders? = nil, enableApiLogs: Bool = true) {
        
        self.apiName = apiName
        self.params = params
        self.method = method
        self.encodingType = encodingType
        self.headers = headers
        self.enableApiLogs = false
        
        #if DEBUG
        self.enableApiLogs = enableApiLogs
        #endif
        
    }
    
    @discardableResult
    func request(responseHandler : @escaping ((APIResposne)->Void)) -> DataRequest? {

        
        return APIManager.shared.request(request: self, responseHandler: { (request) in
            self.checkAPIRequestStatus(request: request)
            responseHandler(request)
        })
    }
    
    @discardableResult
    func request<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        return APIManager.shared.request(request: self, responseHandler: { (request) in
            
            self.checkAPIRequestStatus(request: request)
            guard let apiResonse: T = request.fullResponse.parseResponse() else {
                responseHandler(request, nil)
                return
            }
            responseHandler(request, apiResonse)
            //            }
        })
        
    }
    
    @discardableResult
    func checkAPIRequestStatus(request: APIResposne) -> Bool {
        
        guard request.status != .clientError else {
            print("API Status Code : \(request.statusCode) ")
            print("Message : \(request.message) ")
            /* `Types of error`
             - Url not found : 400
             - Un-authorized access. : 401
             - Method not valid : 400
             */
            
            switch request.statusCode {
            case 401:
                // Logout the user
                break
                
            case 400:
                break
                
            default:
                break
            }
            
            return false
        }
        
        guard request.status == .success else {
            return false
        }
        
        return true
    }
    
}

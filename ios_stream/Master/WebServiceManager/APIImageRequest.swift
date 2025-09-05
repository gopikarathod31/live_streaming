//
//  APIImageRequest.swift
//  SetupApp
//
//  Created by MultiQoS on 05/04/2021.
//  Copyright © 2021 MultiQoS. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class APIImageRequest: APIRequest {
    
    var singleImage: [String : UploadMedia]
    var uploadingProgress : ((Double) -> Void)?
    
    init(apiName: APIName, params: Json = [:], imageParams: [String : UploadMedia], method: HTTPMethod = .post, encodingType : RequestType = .httpBody) {
        self.singleImage = imageParams
        super.init(apiName: apiName, params: params, method: method, encodingType: encodingType)
    }
    
    @discardableResult
    override func request(responseHandler:  @escaping ((APIResposne)->Void)) -> DataRequest? {
        
        return APIManager.shared.requestWithImage(request: self, responseHandler: { (request) in
            self.checkAPIRequestStatus(request: request)
            responseHandler(request)
        })
    }
    
    @discardableResult
    override func request<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        
        return APIManager.shared.requestWithImage(request: self, responseHandler: { (request) in
            
            self.checkAPIRequestStatus(request: request)
            guard let apiResonse: T = request.fullResponse.parseResponse() else {
                responseHandler(request, nil)
                return
            }
            responseHandler(request, apiResonse)
        })
    }
}

class APIImagesRequest: APIRequest {
    
    var multipleImage: [String : [UploadMedia]]
    var uploadingProgress : ((Double) -> Void)?
    
    init(apiName: APIName, params: Json = [:], imagesParams: [String : [UploadMedia]], method: HTTPMethod = .post, encodingType : RequestType = .httpBody) {
        self.multipleImage = imagesParams
        super.init(apiName: apiName, params: params, method: method, encodingType: encodingType)
    }
    
    @discardableResult
    override func request(responseHandler :  @escaping ((APIResposne)->Void)) -> DataRequest? {
        
        return APIManager.shared.requestWithImages(request: self, responseHandler: { (request) in
            self.checkAPIRequestStatus(request: request)
            responseHandler(request)
        })
    }
    
    @discardableResult
    override func request<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        return APIManager.shared.requestWithImages(request: self, responseHandler: { (request) in
            
            if self.checkAPIRequestStatus(request: request) {
                guard let apiResonse: T = request.fullResponse.parseResponse() else {
                    responseHandler(request, nil)
                    return
                }
                responseHandler(request, apiResonse)
            } else {
                responseHandler(request, nil)
            }
        })
    }
}

class APIImagesAndImagesRequest: APIRequest {
    
    var singleImage: [String : UploadMedia]
    var multipleImage: [String : [UploadMedia]]
    var uploadingProgress : ((Double) -> Void)?
    
    init(apiName: APIName, params: Json = [:], imageParams: [String : UploadMedia], imagesParams: [String : [UploadMedia]], method: HTTPMethod = .post, encodingType : RequestType = .httpBody) {
        self.singleImage = imageParams
        self.multipleImage = imagesParams
        super.init(apiName: apiName, params: params, method: method, encodingType: encodingType)
    }
    
    @discardableResult
    override func request(responseHandler :  @escaping ((APIResposne)->Void)) -> DataRequest? {
        
        return APIManager.shared.requestWithImageAndImages(request: self, responseHandler: { (request) in
            self.checkAPIRequestStatus(request: request)
            responseHandler(request)
        })
    }
    
    @discardableResult
    override func request<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        
        return APIManager.shared.requestWithImageAndImages(request: self, responseHandler: { (request) in
            
            if self.checkAPIRequestStatus(request: request) {
                guard let apiResonse: T = request.fullResponse.parseResponse() else {
                    responseHandler(request, nil)
                    return
                }
                responseHandler(request, apiResonse)
            } else {
                responseHandler(request, nil)
            }
        })
    }
}

enum MediaType {
    
    case mimeType(mime:APIMimeTypes)
    
    var mediaExtension : String {
        switch self {
        case .mimeType(let mime):
            return mime.rawValue
        }
    }
    
    var mime : String {
        switch self {
        case .mimeType(let mime):
            return mime.mime
        }
    }
}

enum MediaData {
    
    case Url( _:String)
    case RawData( _:Data)
    
    var mediaData : Data? {
        switch self {
        case .Url(let strUrl):
            do {
                guard let _url = URL(string: strUrl) else { return nil}
                let data = try Data(contentsOf: _url, options: .mappedIfSafe)
                return data
            }catch{
                return nil
            }
        case .RawData(let data):
            return data
        }
    }
}

struct UploadMedia {
    var mediaType : MediaType
    var media : MediaData
    var fileName : String?
    var index : String?
}



class APIRequestWithOutParam: APIRequest {
    
    @discardableResult
    func requestwithOutPAram<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        return APIManager.shared.requestWithOutParam(request: self, responseHandler: { (request) in
            self.checkAPIRequestStatus(request: request)
            guard let apiResonse: T = request.fullResponse.parseResponse() else {
                responseHandler(request, nil)
                return
            }
            responseHandler(request, apiResonse)
        })
    }
    
    @discardableResult
    override func request<T: Codable>(model:T.Type, responseHandler : @escaping ((APIResposne, T?)->Void)) -> DataRequest? {
        
        
        return APIManager.shared.requestWithOutParam(request: self, responseHandler: { (request) in
            
            if self.checkAPIRequestStatus(request: request) {
                guard let apiResonse: T = request.fullResponse.parseResponse() else {
                    responseHandler(request, nil)
                    return
                }
                responseHandler(request, apiResonse)
            } else {
                responseHandler(request, nil)
            }
        })
    }
}

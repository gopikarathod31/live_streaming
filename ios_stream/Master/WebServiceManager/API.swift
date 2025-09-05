//
//  API.swift
//  Tomato
//
//  Created by MultiQoS on 05/04/2021.
//  Copyright © 2021 MultiQoS. All rights reserved.
//

import Foundation
import Alamofire
import SwiftUI

fileprivate let ApiEnv: APIEnvironment = .staging

fileprivate enum APIEnvironment {
    case local
    case staging
    case live
}

public var BaseURL: String {
    switch ApiEnv {
    case .local:
        return "http://localhost:3000/"
    case .staging:
        return "https://api.mux.com/video/v1/"
    case .live:
        return ""
    }
}

//MARK: - APIs List -
enum APIName {
    
    //User Auth
    case login
    case createCall
    case newLiveStream
    
    var name: String {
        
        switch self {
            
        case .login:
            return BaseURL + "token"
            
        case .createCall:
            return BaseURL + "calls"
            
        case .newLiveStream:
            return BaseURL + "live-streams"
        }
    }
}


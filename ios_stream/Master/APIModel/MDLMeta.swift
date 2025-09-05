//
//  Meta.swift
//  Model Generated using http://www.jsoncafe.com/ 

import Foundation

enum MetaStatus: Int {
    case success = 1
    case failed = 0
}

struct MDLMeta : Codable {
    
    let message : String?
    let token : String?
    private let _status : Int?
    private let _accountSetup : Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case _status = "status"
        case token = "token"
        case _accountSetup = "accountSetup"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        _status = try values.decodeIfPresent(Int.self, forKey: ._status)
        _accountSetup = try values.decodeIfPresent(Bool.self, forKey: ._accountSetup)
    }
    
    var status: MetaStatus {
        return MetaStatus(rawValue: _status ?? 0) ?? .failed
    }
    
    var accountSetup: MetaStatus {
        return MetaStatus(rawValue: (_accountSetup ?? false) ? 1 : 0) ?? .failed
    }
}
 

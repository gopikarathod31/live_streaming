//
//  mdl_token.swift
//  live_streaming
//
//  Created by MQS_2 on 20/08/25.
//
import Foundation

class MdlStream: Codable, Hashable {
    var title: String?
    let test: Bool?
    let streamKey: String?
    let status: String?
    let srtPassphrase: String?
    let reconnectWindow: Int?
    let playbackIds: [PlaybackID]?
    let newAssetSettings: NewAssetSettings?
    let maxContinuousDuration: Int?
    let latencyMode: String?
    let id: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case test
        case streamKey = "stream_key"
        case status
        case srtPassphrase = "srt_passphrase"
        case reconnectWindow = "reconnect_window"
        case playbackIds = "playback_ids"
        case newAssetSettings = "new_asset_settings"
        case maxContinuousDuration = "max_continuous_duration"
        case latencyMode = "latency_mode"
        case id
        case createdAt = "created_at"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        test = try values.decodeIfPresent(Bool.self, forKey: .test)
        streamKey = try values.decodeIfPresent(String.self, forKey: .streamKey)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        srtPassphrase = try values.decodeIfPresent(String.self, forKey: .srtPassphrase)
        reconnectWindow = try values.decodeIfPresent(Int.self, forKey: .reconnectWindow)
        playbackIds = try values.decodeIfPresent([PlaybackID].self, forKey: .playbackIds)
        newAssetSettings = try values.decodeIfPresent(NewAssetSettings.self, forKey: .newAssetSettings)
        maxContinuousDuration = try values.decodeIfPresent(Int.self, forKey: .maxContinuousDuration)
        latencyMode = try values.decodeIfPresent(String.self, forKey: .latencyMode)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
    }
    
    static func == (lhs: MdlStream, rhs: MdlStream) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class PlaybackID: Codable, Hashable {
    let policy: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case policy
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        policy = try values.decodeIfPresent(String.self, forKey: .policy)
        id = try values.decodeIfPresent(String.self, forKey: .id)
    }
    
    static func == (lhs: PlaybackID, rhs: PlaybackID) -> Bool {
        return lhs.id == rhs.id && lhs.policy == rhs.policy
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(policy)
    }
}

class NewAssetSettings: Codable, Hashable {
    let playbackPolicies: [String]?
    
    enum CodingKeys: String, CodingKey {
        case playbackPolicies = "playback_policies"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        playbackPolicies = try values.decodeIfPresent([String].self, forKey: .playbackPolicies)
    }
    
    static func == (lhs: NewAssetSettings, rhs: NewAssetSettings) -> Bool {
        return lhs.playbackPolicies == rhs.playbackPolicies
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(playbackPolicies)
    }
}

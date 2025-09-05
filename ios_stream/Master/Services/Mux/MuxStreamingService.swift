//
//  MusStreamingService.swift
//  live_streaming
//
//  Created by MQS_2 on 04/09/25.
//

import Foundation


final class MuxStreamingService {
    
    func newLiveStream(completion: ((APIBaseModel<MdlStream, MDLMeta>?)-> Void)?) {
        
        let json: [String: Any] = ["playback_policy": "public",
                                   "new_asset_settings": [ "playback_policy": "public" ] ]
        
        APIRequest(apiName: .newLiveStream, params: json, method: .post, encodingType: .jsonDefault).request(model: APIBaseModel<MdlStream, MDLMeta>.self) { [weak self] (response, user) in
            
            guard let _ = self,
                  let `completion` = completion,
                  let `user` = user else {
                return
            }
            
            completion(user)
        }
    }
}

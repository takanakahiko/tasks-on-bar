//
//  Tasks.swift
//  tasks-on-bar
//
//  Created by Takayuki Nakayama on 2018/08/16.
//  Copyright © 2018年 Takayuki Nakayama. All rights reserved.
//

import Foundation
import OAuth2
import Cocoa

class Tasks: OAuth2DataLoader {
    
    let baseURL = URL(string: "https://www.googleapis.com")!
    
    public init() {
        let oauth = OAuth2CodeGrant(settings: [
            "client_id": client_id,
            "client_secret": client_secret,
            "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://www.googleapis.com/oauth2/v3/token",
            "scope": "https://www.googleapis.com/auth/tasks",
            "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob"],
            "keychain": false,
        ])
        oauth.authConfig.authorizeEmbedded = true
        //oauth.authConfig.authorizeContext = NSWindow
        super.init(oauth2: oauth, host: "https://www.googleapis.com")
        alsoIntercept403 = true
    }
    
    /** Perform a request against the API and return decoded JSON or an Error. */
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                if let error = (dict["error"] as? OAuth2JSON)?["message"] as? String {
                    DispatchQueue.main.async { callback(nil, OAuth2Error.generic(error)) }
                } else {
                    DispatchQueue.main.async { callback(dict, nil) }
                }
            } catch let error {
                DispatchQueue.main.async { callback(nil, error) }
            }
        }
    }
    
    func requestTaskLists(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "tasks/v1/users/@me/lists", callback: callback)
    }
    
    func requestTasks(tasklistId:String, callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "tasks/v1/lists/\(tasklistId)/tasks", callback: callback)
    }
}

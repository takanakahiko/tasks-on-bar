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

struct TaskList: Codable{
    var id: String
    var kind: String
    var selfLink: String
    var title: String
    var updated: String
}

struct TaskListGroup: Codable{
    var kind: String
    var etag: String
    var items: [TaskList]
}

struct Task: Codable{
    var etag: String
    var id: String
    var kind: String
    var selfLink: String
    var status: String
    var title: String
    var updated: String
}

struct TaskGroup: Codable{
    var kind: String
    var etag: String
    var items: [Task]
}

class TasksApi: OAuth2DataLoader {
    
    let baseURL = URL(string: "https://www.googleapis.com")!

    public init() {
        let oauth = OAuth2CodeGrant(settings: [
            "client_id": client_id,
            "client_secret": client_secret,
            "authorize_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://www.googleapis.com/oauth2/v3/token",
            "scope": "https://www.googleapis.com/auth/tasks",
            "redirect_uris": ["urn:ietf:wg:oauth:2.0:oob:auto"],
            "keychain": false,
        ])
        oauth.logger = OAuth2DebugLogger(.trace)
        oauth.authConfig.authorizeEmbedded = true
        //oauth.authConfig.authorizeContext = NSWindow
        super.init(oauth2: oauth, host: "https://www.googleapis.com")
        alsoIntercept403 = true
    }
    
    
    func request(path: String, callback: @escaping ((String?, Error?) -> Void)) {
        let url = baseURL.appendingPathComponent(path)
        let req = oauth2.request(forURL: url)

        perform(request: req) { response in
            do {
                let ret = try response.responseData()
                let tmp =  String(data: ret, encoding: .utf8)!
                DispatchQueue.main.async { callback( tmp, nil) }
            } catch let error {
                DispatchQueue.main.async { callback(nil, error) }
            }
        }
    }


    func requestJson<T:Codable>(path: String, type: T.Type, callback: @escaping ((T?, Error?) -> Void)) {

        request(path:path) { responseText , error in
            guard let _responseText = responseText else{
                callback(nil, error)
                return;
            }
            do{
                let ret = try JSONDecoder().decode(type.self, from: _responseText.data(using: .utf8)!)
                callback(ret, nil)
            }catch let error{
                callback(nil, error)
            }
            return;

        }

    }


    func requestTaskLists(callback: @escaping ((_ dict: TaskListGroup?, _ error: Error?) -> Void)) {
        //request(path: "tasks/v1/users/@me/lists", callback: callback)
        requestJson(path:"tasks/v1/users/@me/lists", type:TaskListGroup.self)  { json , error in
            guard let _json = json else{
                callback(nil, error)
                return;
            }
            callback(_json, nil)
            return;
        }
    }

    func requestTasks(tasklistId:String, callback: @escaping ((_ dict: TaskGroup?, _ error: Error?) -> Void)) {
        requestJson(path:"tasks/v1/lists/\(tasklistId)/tasks", type:TaskGroup.self) { json , error in
            guard let _json = json else{
                callback(nil, error)
                return;
            }
            callback(_json, nil)
            return;
        }
    }
}

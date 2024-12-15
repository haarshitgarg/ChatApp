//
//  ViewModelController.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import Foundation
import SwiftUI

class ViewModelController: ObservableObject {
    @Published public var view_: ActiveViews = .login
    @Published public var cache_: SystemState = SystemState(jwt: "", view: .login, username: "")

    public static var instance = ViewModelController()
    
    private init(){
        do {
            self.cache_ = try loadCache()
            self.view_ = cache_.view
        }
        catch {
            logger_.error("[VIEW MODEL CONTROLLER] Could not load the cache file: \(error)")
            return
        }
    }
    
    public func updateSystemState(view: ActiveViews) {
        self.cache_.view = view
        writeCache()
    }
    
    public func updateSystemState(jwt: String, username: String) {
        self.cache_.jwt = jwt
        self.cache_.username = username
        writeCache()
    }
    
    public func updateSystemState(view: ActiveViews, jwt: String, username: String) {
        self.cache_.jwt = jwt
        self.cache_.view = view
        self.cache_.username = username
        writeCache()
    }
    
    public func getCurrentView() -> any View {
        logger_.debug("[VIEW MODEL CONTROLLER] getCurrentView() called")
        switch self.cache_.view {
        case .initial:
            return DummyView(name: "Initial")
        case .login:
            return LoginView()
        case .chat:
            return DummyView(name: "Chat")
        }
    }
    
    private func writeCache() {
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cache_path = directoryPath.appendingPathComponent("app_cache.json").path
        let encoder = JSONEncoder()
        let cache_json = try! encoder.encode(cache_)
        if FileManager.default.createFile(atPath: cache_path , contents: cache_json) {
            logger_.info("[VIEW MODEL CONTAINER] Cache files created")
        }
        else {
            logger_.error("[VIEW MODEL CONTAINER] Cache file cannot be created")
        }
    }
}

extension ViewModelController {
    private func loadCache() throws -> SystemState{
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cache_path = directoryPath.appendingPathComponent("app_cache.json").path
        if !FileManager.default.fileExists(atPath: cache_path) {
            logger_.debug("[APP] Cache file cache.json doesn't exist. Creating a default cache.json")
            
            let encoder: JSONEncoder = JSONEncoder()
            let cache_data: SystemState = SystemState(jwt: "", view: .login, username: "")
            encoder.outputFormatting = .prettyPrinted
            let cache_json_data = try encoder.encode(cache_data)
            
            let status = FileManager.default.createFile(atPath: cache_path, contents: cache_json_data)
            logger_.debug("[APP] File creation status: \(status)")
        }
        
        let cache_content_: Data = FileManager.default.contents(atPath: cache_path)!
        let decoder: JSONDecoder = JSONDecoder()
        let cache_data = try decoder.decode(SystemState.self, from: cache_content_)
        
        return cache_data
    }
}

enum ActiveViews: Codable {
    case initial;
    case login;
    case chat;
}

class SystemState: Codable {
    public var jwt: String;
    public var view: ActiveViews;
    public var username: String;
    
    init(jwt: String, view: ActiveViews, username: String) {
        self.jwt = jwt
        self.view = view
        self.username = username
    }
}

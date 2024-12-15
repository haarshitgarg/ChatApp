//
//  NetworkManager.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import Foundation

class NetworkManager {
    // Singleton network manager
    static var instance = NetworkManager()
    private var view_controller_ = ViewModelController.instance
    private init(){}
    
    public func loginRequest(username: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) throws {
        logger_.info("[NETWORK MANAGER] Posting logging request")
        let login_request = AuthRequest(username: username, password: password)
        guard let url = URL(string: "http://localhost:8082/auth")
        else{
            logger_.error("Invalid URL")
            throw NetworkManagerExeptions.URLInvalid
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        do {
            request.httpBody = try JSONEncoder().encode(login_request)
        } catch {
            logger_.error("[NETWORK MANAGER] : \(NetworkManagerExeptions.JSONEncoderError.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            logger_.info("[NETWORK MANAGER] Creating the data Task")
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                logger_.error("[NETWORK MANAGER] Response error")
                completion(.failure(NetworkManagerExeptions.HTTPResponseError))
                return
            }
            
            print(httpResponse.statusCode)
            
            guard let data = data else {
                logger_.info("[NETWORK MANAGER] Response Sent: Failure")
                completion(.failure(NetworkManagerExeptions.HTTPResponseError))
                return
            }
            
            // Decoding the response
            do {
                let auth_response = try JSONDecoder().decode(AuthResponse.self, from: data)
                logger_.info("[NETWORK MANAGER] Response Sent: Success")
                completion(.success(auth_response))
                return
            }
            catch {
                logger_.info("[NETWORK MANAGER] Response Sent: Failure")
                completion(.failure(NetworkManagerExeptions.JSONDecoderError))
                return
            }
            
        }
        
        logger_.info("[NETWORK MANAGER] Created the task to send the POST request")
        task.resume()
    }
    
    public func getContactInformation(completion: @escaping ([ContactInformation]) -> Void) throws {
        let baseURL = "http://localhost:8082/chat"
        
        guard let url: URL = URLComponents(string: baseURL)?.url else {
            throw NetworkManagerExeptions.URLInvalid
        }
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue(view_controller_.cache_.jwt, forHTTPHeaderField: "Authorization")
        request.url?.append(queryItems: [URLQueryItem(name: "userid", value: view_controller_.cache_.username)])
        
        print("[NETWORK MANAGER] URL Request: \(request.url as URL?)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger_.error("[NETWORK MANAGER] Found an error in http request task: \(error)")
            }

            guard let http_response: HTTPURLResponse = response as? HTTPURLResponse else {
                logger_.error("[NETWORK MANAGER] Found an error in http request task, response is not empty: \(error)")
                return
            }
            logger_.debug("[NETWORK MANAGER] HTTP status: \(http_response.statusCode)")
            
            guard let data = data else {
                logger_.error("[NETWORK MANAGER] data is empty")
                return
            }
            do {
                let chat_response: ContactList = try JSONDecoder().decode(ContactList.self, from: data)
                logger_.debug("[NETWORK MANAGER] Chat friends list: \(chat_response.contact_list_)")
                completion(chat_response.contact_list_)
            }
            catch {
                logger_.error("[NETWORK MANAGER] Error: \(error)")
                return
            }
        }
        task.resume()
    }
}

struct AuthRequest: Codable {
    public var username: String;
    public var password: String;
    
    init(username: String, password: String) {
        self.username = username 
        self.password = password
    }
}

struct AuthResponse: Codable{
    public var status: String;
    public var jwt_token: String;
    
    init(status: String, jwt_token: String) {
        self.status = status
        self.jwt_token = jwt_token
    }
}

class ContactList: Codable, ObservableObject{
    public var contact_list_: [ContactInformation]
    
    init(contact_list: [ContactInformation]) {
        self.contact_list_ = contact_list
    }
    
    public func updateList(contact_list: [ContactInformation]) {
        self.contact_list_ = contact_list
    }
}

struct ContactInformation: Codable{
    public var name: String
    public var lastChat: String
    
    init(name: String, lastChat: String) {
        self.name = name
        self.lastChat = lastChat
    }
}

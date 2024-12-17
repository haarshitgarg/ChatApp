//
//  gRPCHandler.swift
//  ChatApp
//
//  Created by Harshit Garg on 02/12/24.
//

import Foundation
import GRPC
import NIO

class GRPCHandler: ConnectivityStateDelegate {
    
    private static var instance: GRPCHandler = GRPCHandler();
    private var view_controller_: ViewModelController = ViewModelController.instance;
    private var channel_: ClientConnection
    private var client_: Org_Harshit_Messenger_Chat_ChatServiceNIOClient
    public var call_: BidirectionalStreamingCall<Org_Harshit_Messenger_Chat_ChatMessage, Org_Harshit_Messenger_Chat_ChatMessage>?
    
    public var client_callback_: ((Org_Harshit_Messenger_Chat_ChatMessage) -> Void)? = nil
    
    private init(){
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        channel_ = ClientConnection.insecure(group: group).connect(host: "localhost", port: 9000)
        client_ = Org_Harshit_Messenger_Chat_ChatServiceNIOClient(channel: self.channel_)
        
        channel_.connectivity.delegate = self
        
    }
    
    public static func getInstance() -> GRPCHandler {
        return instance;
    }
    
    public func startClient() {
        // Create a channel
        logger_.debug("[GRPC HANDLER] Starting the client")
        call_ = client_.sendMessagesGRPC { response in
            self.client_callback_?(response)
        }
    }
    
    public func keepConnAlive() {
        // TODO in future
        // I can add something here that will keep the connection alive by sending keepalive signals if necessary
    }
    
    public func sendMessage(msg: String, to friend: String) async throws {
        // Draft the message
        var request = Org_Harshit_Messenger_Chat_ChatMessage()
        request.friend = friend
        request.timestamp = Int64(Date().timeIntervalSince1970*1000)
        request.message = msg
        request.user = view_controller_.cache_.username
        
        logger_.debug("[GRPC HANDLER] Client is available")
        call_?.sendMessage(request).whenComplete{result in
            switch result {
            case .success(let success):
                logger_.debug("[GRPC HANDLER] Success sending the message")
            case .failure(let failure):
                logger_.error("[GRPC HANDLER] Couldn't send the message")
                logger_.error("[GRPC HANDLER] Error: \(failure)")
            }
        }
    }
    
    public func runClient(friend: String) {
        print("Running the client");
        // Create a channel
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1);
        let channel = ClientConnection.insecure(group: group).connect(host: "localhost", port: 9000)
        print("Created the channel")
        // create a client
        let client = Org_Harshit_Messenger_Chat_ChatServiceNIOClient(channel: channel)
        print("Created the client")
        
        // create a request
        var request = Org_Harshit_Messenger_Chat_ChatMessage()
        request.friend = friend
        request.user = view_controller_.cache_.username;
        request.message = "Hello from the client"
        request.timestamp = 20302810
        
        print("Created the request")
        
        // get the respons
        let response = client.sendMessage(request)
        print("Going to wait for response")
        response.response.whenSuccess(messageCallback)
    }
    
    private func messageCallback(_:Org_Harshit_Messenger_Chat_ChatMessageResponse) {
        print("Here I don't know why")
    }
    
    func connectivityStateDidChange(from oldState: GRPC.ConnectivityState, to newState: GRPC.ConnectivityState) {
        print("[GRPC HANDLER] Connectivity changed from \(oldState) to \(newState)")
    }

}

//
//  MessageView.swift
//  ChatApp
//
//  Created by Harshit Garg on 04/12/24.
//

import Foundation
import SwiftUI

struct MessageView: View {
    @Binding public var friend: String
    
    @State var message: String = ""
    @State private var messages: [ChatMessage] = []
    
    public var persistancy_handler_ = PersistantModel.instance
    public var view_controller_ = ViewModelController.instance
    public var grpc_handler_ = GRPCHandler.getInstance()
    
    init(friend: Binding<String>) {
        self._friend = friend
        grpc_handler_.startClient(handler: self.receiveCallback)
    }
    
    var body: some View {
        VStack {
            Text(friend).font(.title)
            ScrollView {
                ForEach(messages, id: \.self) { msg in
                    HStack{
                        if(msg.type == .Sent) {
                            Spacer()
                        }
                        Text(msg.message).padding(.horizontal)
                        if(msg.type == .Received) {
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
            HStack{
                TextField("Message", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: self.send) {
                    Image(systemName: "paperplane")
                }
            }
            .padding()
        }
        .onAppear{
            reload()
        }
    }
    
    private func send() {
        // Adding message to the MessageList (I also need to keep the messages sorted)
        // Send message to the Server
        messages.append(ChatMessage(message: self.message, type: .Sent, time: Int64(Date().timeIntervalSince1970*1000)))
        Task {
            logger_.debug("[MESSAGE VIEW] Running Tasks")
            try await grpc_handler_.sendMessage(msg: self.message, to: self.friend)
        }
    }
    
    private func receiveCallback(_ response: Org_Harshit_Messenger_Chat_ChatMessage) {
        // Received message from the server
        logger_.debug("[MESSAGE VIEW] Received message from the server")
        logger_.debug("[MESSAGE VIEW] Received message: \(response.message) from \(response.user)")
        // Add message to he MessageList (I also need to keep the messages sorted based on time)
        DispatchQueue.main.async {
            self.messages.append(ChatMessage(message: response.message, type: .Received, time: response.timestamp))
        }
        //messages.sort { msg1, msg2 in
        //    if(msg1.time > msg2.time){ return false;}
        //    return true
        //}
    }
    
    private func updateCoreData() async {
        // Update CoreData persistency at various intervals
    }
    
    private func reload() {
        logger_.debug("[MESSAGE VIEW] Reloading...")
        let request = MessageDB.fetchRequest()
        request.predicate = NSPredicate(format: "(sender.username==%@ AND ANY receiver.username==%@) OR (ANY receiver.username==%@ AND sender.username==%@)", view_controller_.cache_.username, self.friend, view_controller_.cache_.username, self.friend)

        // Fetch the request
        do {
            let result = try PersistantModel.instance.container.viewContext.fetch(request)
            messages = result.map { res in
                return ChatMessage(message: res.message ?? "", type: .Sent, time: res.time_sent)
            }
        }
        catch {
            logger_.error("[MESSAGE VIEW] Cannot access the core data persistency")
        }
        
    }
}

struct ChatMessage: Hashable {
    public var message: String
    public var type: ChatMessageType
    public var time: Int64
    
    init(message: String, type: ChatMessageType, time: Int64) {
        self.message = message
        self.type = type
        self.time = time
    }
}

enum ChatMessageType {
    case Sent
    case Received
}

struct MessageViewPreview: PreviewProvider {
    @State static var temp_name: String = "Default"
    static var previews: some View {
        MessageView(friend: self.$temp_name)
    }
}

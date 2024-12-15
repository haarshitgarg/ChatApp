//
//  ChatView.swift
//  ChatApp
//
//  Created by Harshit Garg on 10/11/24.
//

import Foundation
import SwiftUI

struct ChatView: View {
    private let network_manager_: NetworkManager = NetworkManager.instance
    private let grpc_manager_: GRPCHandler = GRPCHandler.getInstance()
    @State private var friend_currently_in_view_: String = ""
    @ObservedObject private var view_controller_ = ViewModelController.instance
    @StateObject private var friends_: Friends = Friends(friends_list_: [])
    
    private var viewContext = PersistantModel.instance.container.viewContext
    
    init() {
    }
    
    var body: some View {
        NavigationView {
            VStack{
                Image(systemName: "person.crop.circle")
                    .imageScale(.large)
                List(friends_.friends_list_, id: \.name) { friend in
                    Button(friend.name.replacingOccurrences(of: "\"", with: "")) {
                        friend_currently_in_view_ = friend.name
                        print("Updated the friend")
                    }
                }
                
            }
            HStack{
                MessageView(friend: $friend_currently_in_view_)
            }
        }
        .navigationTitle("CHAT APP")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: reload) {
                    Image(systemName: "arrow.clockwise")
                        .help("Reload")
                }
            }
            
            ToolbarItem(placement: .navigation, content: {
                Button(action: logout, label: {
                    Text("Logout")
                })
            })
        }
        .onAppear {
            reload()
        }
    }
    
    private func chatGetCompletion(result: [ContactInformation]) {
        logger_.info("[CHAT VIEW] Get Chat completion function is called")
        DispatchQueue.main.async {
            // Check if the user exists in DB
            let requestUser = UserDB.fetchRequest()
            requestUser.predicate = NSPredicate(format: "username==%@", view_controller_.cache_.username)
            let user: UserDB
            
            do {
                let users = try viewContext.fetch(requestUser)
                user = users.first ?? UserDB(context: self.viewContext)
            }
            catch {
                user = UserDB(context: self.viewContext)
            }
            user.username = view_controller_.cache_.username
            
            // Get friends list of the user.
            self.friends_.friends_list_ = result
            for friend in result {
                let friendRequest = UserDB.fetchRequest()
                friendRequest.predicate = NSPredicate(format: "username==%@", friend.name)
                do {
                    let friends = try viewContext.fetch(friendRequest)
                    let friendUser: UserDB = friends.first ?? UserDB(context: self.viewContext)
                    friendUser.username = friend.name
                    if (!user.friend!.contains(friendUser)){
                        user.addToFriend(friendUser)
                    }
                }
                catch {
                    let _: UserDB = UserDB(context: self.viewContext)
                }
            }
            
            do {
                try viewContext.save()
                logger_.debug("[CHAT VIEW] Added users to the database")
            }
            catch {
                logger_.warning("[CHAT VIEW] Couldn't store the list of friends because: \(error.localizedDescription)")
            }
        }
    }
    
    private func reload(){
        logger_.debug("[CHAT VIEW] Reloading...")
        do {
            try network_manager_.getContactInformation(completion: self.chatGetCompletion)
        }
        catch {
            logger_.debug("[CHAT VIEW] Got error: \(error.localizedDescription)")
            return
        }
    }
    
    private func logout() {
        logger_.debug("[CHAT VIEW] Logging out...")
        DispatchQueue.main.async{
            view_controller_.updateSystemState(view: .login, jwt: "", username: "")
            view_controller_.view_ = .login
        }
    }
}

class Friends: ObservableObject {
    @Published public var friends_list_: [ContactInformation] = [];
    
    init(friends_list_: [ContactInformation]) {
        self.friends_list_ = friends_list_
    }
}

#Preview {
    ChatView()
}

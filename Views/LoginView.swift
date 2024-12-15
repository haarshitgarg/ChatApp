//
//  LoginView.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    private var manager: NetworkManager = NetworkManager.instance
    @ObservedObject private var view_controller: ViewModelController = ViewModelController.instance
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: signIn) {
                Label("Sign In", systemImage: "arrow.up")
            }
        }
    }
    
    func signIn() {
        logger_.info("[LOGIN VIEW] Pressed the sign in button")
        do {
            try manager.loginRequest(username: self.username, password: self.password) { result in
                switch result {
                case .success(let success):
                    logger_.info("[LOGIN VIEW] Successful signin: \(success.jwt_token)")
                    DispatchQueue.main.async {
                        view_controller.updateSystemState(view: .chat, jwt: success.jwt_token, username: self.username)
                        view_controller.view_ = .chat
                    }
                case .failure(let failure):
                    logger_.info("[LOGIN VIEW] Failed to signin: \(failure.localizedDescription)")
                }
            }
        }
        catch {
            logger_.error("[LOGIN VIEW] Error occured: \(error as Error?)")
        }
    }
}

#Preview {
    LoginView()
}



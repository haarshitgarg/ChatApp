//
//  ContentView.swift
//  ChatApp
//
//  Created by Harshit Garg on 10/11/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var view_controller_ = ViewModelController.instance
    var body: some View {
        switch view_controller_.view_ {
        case .initial:
            LoginView()
        case .login:
            LoginView()
        case .chat:
            ChatView()
        }
    }
}

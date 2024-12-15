//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import SwiftUI
import os

var logger_: Logger = Logger()

@main
struct ChatApp: App {
    @ObservedObject private var view_controller_: ViewModelController = ViewModelController.instance
    @StateObject var persistancy_: PersistantModel = PersistantModel.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.environment(\.managedObjectContext ,persistancy_.container.viewContext)
        }
    }
}


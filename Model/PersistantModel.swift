//
//  PersistantModel.swift
//  ChatApp
//
//  Created by Harshit Garg on 05/12/24.
//

import Foundation
import CoreData

class PersistantModel: ObservableObject {
    public static var instance = PersistantModel()
    private init(){}
    
    var container: NSPersistentContainer  = {
        var container = NSPersistentContainer(name: "ChatApp")
        
        // Loading the persistent stores. It creates one if it doesn't exist
        container.loadPersistentStores(completionHandler: {_, error in
            logger_.error("[PERSITANCY MODEL] Error: \(error.debugDescription)")
        })
        
        return container
    }()
}

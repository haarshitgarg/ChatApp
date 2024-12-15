//
//  DummyView.swift
//  ChatApp
//
//  Created by Harshit Garg on 01/11/24.
//

import SwiftUI
import Foundation

struct DummyView: View {
    private var name: String
    init(name: String) {
        self.name = name
    }
    var body: some View {
        VStack{
            Text("Dummy View: \(name)")
        }
    }
}

//
//  AppRootView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI
import Firebase

struct AppRootView: View {
    

    @EnvironmentObject var currentAuth: UserAuth
    
    var body: some View {
        Group {
            if currentAuth.auth.currentUser != nil {
//                print(currentAuth.auth.currentUser?.providerData)
                UserHomepageView(user: User(fn: "\(currentAuth.auth.currentUser?.uid)", ln: "b", id: "d"))
              // ...
            } else {
              // No user is signed in.
              ContentView()
            }
            
           
        }
    }
}

class UserAuth: ObservableObject {
    
    @Published var auth = Auth.auth()
    init(){
        let handle = auth.addStateDidChangeListener { (authFromDataB, user) in
            self.auth = authFromDataB
        }
    }
 
}


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
    
//    let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//
//    }
    @ObservedObject var currentAuth: UserAuth
    
    var body: some View {
        Group {
            if currentAuth.auth.currentUser != nil {
//                print(currentAuth.auth.currentUser?.providerData)
                UserHomepageView(user: User(fn: "\(currentAuth.auth.currentUser?.metadata)", ln: "\(currentAuth.auth.currentUser)", id: "\(currentAuth.auth.currentUser)"))
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
}

//struct AppRootView_Previews: PreviewProvider {
//    static var previews: some View {
//        let userT = User(fn: "B", ln: "L", id: "DS")
//        userT.isLoggedIn = true
//        return AppRootView
//    }
//}

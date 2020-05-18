//
//  AppRootView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import Firebase

struct AppRootView: View {
    

    @EnvironmentObject var authManager: FirebaseManager
    
    var body: some View {
        Group {
            if authManager.currentUser != nil {
                
                UserHomepageView() //user: authManager.currentUser!
              
            } else {
              // No user is signed in.
              SignupView()
            }
            
           
        }
    }
}

class FirebaseManager: ObservableObject {
    //Helpful links
    //https://benmcmahen.com/authentication-with-swiftui-and-firebase/
    //https://github.com/invertase/react-native-firebase/issues/1166 --Pod informatioin
    @Published var currentUser: User?
    @Published var handle: AuthStateDidChangeListenerHandle? //Not sure if this should be published
    var db: Firestore!

    //This init starts a listener that looks for changes in the Authstate. If the listener is triggered, the user wilil be set
    init(){
        db = Firestore.firestore()
        let handle = Auth.auth().addStateDidChangeListener { (authFromDataB, user) in
            if let user = user {
                //We got a user
                print("User: \(user)")
                self.getUser(id: user.uid, completionHandler: { (success) -> Void in //Sets the current user
                    if success {
                        print("Set USer succsessfully")
                        //self.currentUser!.updateFiles()
                    }else{
                        //ERROR
                        print("Failed to set user")
                    }
                })
            }
        }
    }
    
    //This gets a users information from the database
    func getUser(id: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let docRef = db.collection("users").document(id)
        docRef.getDocument {(document, error) in
            if let document = document, document.exists{
                let dataDescription = document.data()
                self.currentUser = User(fn: dataDescription!["firstN"] as! String,
                                        ln: dataDescription!["lastN"] as! String,
                                        id: document.documentID,
                                        aID: dataDescription!["associationID"] as! String,
                                        testRefs: ["BEN"])
                completionHandler(true)

            }else{
                print("Document was not retrieved")
                self.currentUser = nil
                completionHandler(false)
            }
            
        }
    }
    
    //This creats a user in the database
    func createUser(uid: String, fn: String, ln: String, aid: String, handler: @escaping (_ success: Bool) -> Void){
        
        self.db.collection("users").document(uid).setData(["firstN": fn, "lastN": ln, "associationID": aid]){ error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
                handler(false)
            }else{
                print("Suuccess creating user document")
                handler(true)
            }
        }
    }
    
    //This funciton creats an authenticated User. The id of the authenticaed user is tied to the document id in the database
    func signUp(userRegModel: UserRegistrationViewModel, handler: @escaping (_ success: Bool) -> Void) {
                
        Auth.auth().createUser(withEmail: userRegModel.email, password: userRegModel.password) { authResult, error in
            if let error = error {
                print("Error creating account with user name and password: \(error.localizedDescription)")
                handler(false)
            } else{
                //The authResult has user.uid and user.email
                print("Sucess creating authenticated account: \(authResult!)")
                //We now want to create this user in our database
                self.createUser(uid: (authResult?.user.uid)!, fn: userRegModel.firstName, ln: userRegModel.lastName, aid: userRegModel.associationID, handler: {(success) -> Void in
                    if success {
                        self.getUser(id: (authResult?.user.uid)!, completionHandler: { (success) -> Void in //Sets the current user
                            if success {
                                //Sucess getting the user info from database
                                handler(true)
                            }else{
                                //Failure getting the user info from database
                                handler(false)
                            }
                        })
                    } else{
                        //Failutre to create user
                        handler(false)
                    }
                })

            }
        }
        
    }
    
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            return true
        } catch {
            return false
        }
    }
    
    
}


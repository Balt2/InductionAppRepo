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
            if authManager.initialized == false {
                //Loading view
                //Could also just be a white screenn until it firebase initailzes
                Image("ilLogo")
            }else if authManager.currentUser != nil  {
                UserHomepageView(user: authManager.currentUser!)
            }else{
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
    @Published var associations = Set<Association>()
    @Published var handle: AuthStateDidChangeListenerHandle? //Not sure if this should be published
    @Published var initialized = false
    //@Published var pencilManager = ApplePencilReachability()
    var db: Firestore!

    //This init starts a listener that looks for changes in the Authstate. If the listener is triggered, the user wilil be set
    init(){
        print("FIREBASE Start INIT")
        db = Firestore.firestore()
        
        //Get Associations
        getAssociations(){_ in
            print("GETTING ASSOCIATIONS")
            print(self.associations)
        }
        
        //State listener for authentication
        Auth.auth().addStateDidChangeListener { (authFromDataB, user) in //let handle =
            print("Listeninng for auth changes")
            if let user = user {
                //We got a user
                print("User: \(user)")
                self.getUser(id: user.uid, completionHandler: { (success) -> Void in //Sets the current user
                    if success {
                        print("Set USer succsessfully")
                        self.initialized = true
                        //self.currentUser!.updateFiles()
                    }else{
                        //ERROR
                        self.initialized = true
                        print("Failed to set user")
                    }
                })
            }else{
                self.initialized = true
            }
        }
        
        
        
    }
    
    func getAssociations(completionHander: @escaping (_ success: Bool) -> Void) {
        let ref = db.collection("association")
        ref.getDocuments(){(querySnnapshot, error) in
            if let error = error {
                print("Error getting doc: \(error)")
                completionHander(false)
            }else{
                for document in querySnnapshot!.documents{
                    let documentData = document.data()
                    let newAssociation = Association(uid: document.documentID,
                                                     associationID: documentData["associationID"] as! String,
                                                     name: documentData["name"] as! String,
                                                     imagePath: documentData["imagePath"] as! String)
                    self.associations.insert(newAssociation)
                    print(self.associations)

                }
                completionHander(true)
            }
        }
    }
    
    //This gets a users information from the database
    func getUser(id: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let docRef = db.collection("users").document(id)
        print("GET USER CALLED") // TODO: PROBLEM HERE occosioanllyy while loading. Add a variable to that call and then if it goes on for 5 seconds try again
        docRef.getDocument {(document, error) in
            print("GETTING DOC REF")
            if let document = document, document.exists{
                let dataDescription = document.data()
                
                self.getAssociations(){got in
                    if got == true {
                        self.currentUser = User(fn: dataDescription!["firstN"] as! String,
                                                ln: dataDescription!["lastN"] as! String,
                                                id: document.documentID,
                                                association: self.associations.first(where: {$0.associationID == dataDescription!["associationID"] as! String })!,
                                                testRefs: dataDescription!["testRefs"]! as! [String], testResultRefs: dataDescription!["testResultRefs"]! as! [String]) //"1904sFilled",  //dataDescription!["testRefs"] as! [String]
                        completionHandler(true)
                    }else{
                        //ERROR: No association found
                        print("NO ASSOCIATION FOUND")
                        self.currentUser = nil
                        completionHandler(false)
                    }
                }

            }else{
                print("Document was not retrieved")
                self.currentUser = nil
                completionHandler(false)
            }
            
        }
    }
    
    //This creats a user in the database
    func createUser(uid: String, fn: String, ln: String, aid: String, handler: @escaping (_ success: Bool) -> Void){
        
        self.db.collection("users").document(uid).setData(["firstN": fn, "lastN": ln, "associationID": aid, "testResultRefs": ["1912SFilled", "1906Filled"], "studyResultRefs": [], "testRefs": ["1904S", "1906ACT", "1912ACT"], "studyRefs": []]){ error in
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
                        //Self.getUser
                        //Firebase automatically gets user so we dont need to call this
                        handler(true)
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


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
        return Group {
            
            if authManager.currentUser != nil{
                UserHomepageView(user: authManager.currentUser!, showSheet: authManager.currentUser!.showInstructions, showInstructions: authManager.currentUser!.showInstructions)
            }else if authManager.initialized == false{
                //Loading view
                //Could also just be a white screenn until it firebase initailzes
                Image("ilLogo").opacity(authManager.initialized ? 0.5: 1.0)
            }else{
                SignupView()
            }
            
//            if authManager.initialized == false {
//                //Loading view
//                //Could also just be a white screenn until it firebase initailzes
//                Image("ilLogo").opacity(authManager.initialized ? 0.5: 1.0)
//            }else if authManager.currentUser != nil  {
//                UserHomepageView(user: authManager.currentUser!, showSheet: authManager.currentUser!.showInstructions, showInstructions: authManager.currentUser!.showInstructions)
//            }else{
//                SignupView()
//            }
           
        }.opacity((authManager.initialized || authManager.currentUser != nil)  ? 1.0: 1.0)
    }
}

class FirebaseManager: ObservableObject {
    //Helpful links
    //https://benmcmahen.com/authentication-with-swiftui-and-firebase/
    //https://github.com/invertase/react-native-firebase/issues/1166 --Pod informatioin
    @Published var currentUser: User?
    @Published var associations = Set<Association>()
    @Published var accessCodes = Set<String>()
    @Published var handle: AuthStateDidChangeListenerHandle? //Not sure if this should be published
    @Published var initialized = false{
        didSet{
            print("App is Initialized: \(initialized)")
            print(self.currentUser)
        }
    } //Should be set to false initially TODO{
    var handler: AuthStateDidChangeListenerHandle?
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
        
        getAccessCodes(){accessList in
            self.accessCodes = accessList
            print("GOT ACCESS CODES")
        }
        
        //State listener for authentication
        //self.initialized = true
        handle = Auth.auth().addStateDidChangeListener { (authFromDataB, user) in //let handle =
            print("Listeninng for auth changes")
            if let user = user {
                //We got a user9
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
                print("No User loged in")
                self.initialized = true
            }
        }
        
        
        
        
    }
    
    func getAccessCodes(completionHander: @escaping (_ success: Set<String>) -> Void){
        let ref = db.collection("accessCodes")
        var tempAccessSet = Set<String>()
        ref.getDocuments(){(querySnnapshot, error) in
            if let error = error {
                print("Error getting doc: \(error)")
                completionHander(tempAccessSet)
            }else{
                for document in querySnnapshot!.documents{
                    tempAccessSet.insert(document.documentID)
                    print(document.documentID)
                }
                completionHander(tempAccessSet)
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
                                                testResultRefs: dataDescription!["testResultRefs"]! as! [String], testRefsMap: (dataDescription!["testRefsMap"])! as! [String: Bool]) //"1904sFilled",
                        
                        if let showInstructionsBool = dataDescription!["showInstructions"]{
                            let shib = showInstructionsBool as! Bool
                            self.currentUser?.showInstructions = shib
                        }
                        if let dataMapSAT = dataDescription!["quickDataMapSAT"] {
                            let structuredDataMapSAT = dataMapSAT as! [String: [String : [String: Int]]]
                            self.currentUser?.quickDataSAT.createData(nsDictionary: structuredDataMapSAT)
                        }
                        
                        if let dataMapACT = dataDescription!["quickDataMapACT"] {
                            let structuredDataMapACT = dataMapACT as! [String: [String : [String: Int]]]
                            self.currentUser?.quickDataACT.createData(nsDictionary: structuredDataMapACT)
                        }
                        
                        if let dataMapPSAT = dataDescription!["quickDataMapPSAT"] {
                            let structuredDataMapPSAT = dataMapPSAT as! [String: [String : [String: Int]]]
                            self.currentUser?.quickDataPSAT.createData(nsDictionary: structuredDataMapPSAT)
                        }
                        
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
    func createUser(uid: String, fn: String, ln: String, aid: String, accessCode: String, timeAndHalf: Bool, handler: @escaping (_ success: Bool) -> Void){
        //
        //
        self.db.collection("users").document(uid).setData(["firstN": fn, "lastN": ln, "associationID": aid, "testResultRefs": [], "studyResultRefs": [], "studyRefs": [] , "testRefsMap": [ (timeAndHalf ? "1572cpre-tmh" : "1572cpre"): false, (timeAndHalf ? "1874fpre-tmh" : "1874fpre"): false, (timeAndHalf ? "67c-tmh" : "67c"): false, (timeAndHalf ? "73g-tmh" : "73g"): false, (timeAndHalf ? "cb5-tmh" : "cb5") : false, (timeAndHalf ? "cb6-tmh" : "cb6"): false, (timeAndHalf ? "cb9-tmh" : "cb9"): false, (timeAndHalf ? "cb7-tmh" : "cb7"): false, (timeAndHalf ? "pr5-tmh" : "pr5"): false, (timeAndHalf ? "psat1-tmh" : "psat1"): false, (timeAndHalf ? "psat2-tmh" : "psat2"): false], "quickDataMapSAT": [:], "quickDataMapACT": [:], "accessCode": accessCode, "showInstructions": true]){ error in //"1904S", //TestResutlRefs: "1912SFilled", "1906Filled" "1874fpre-SR8fDgu9W8Nrp68z7qwpWNy1NcO2-08-01-2020" //, 
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
    func signUp(userRegModel: UserRegistrationViewModel, handler: @escaping (_ handler: (created: Bool, error: String)) -> Void) {
        let noSpacesAccessCode = userRegModel.accessCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if accessCodes.contains(noSpacesAccessCode){
            Auth.auth().createUser(withEmail: userRegModel.email, password: userRegModel.password) { authResult, error in
                if let error = error {
                    print("Error creating account with user name and password: \(error.localizedDescription)")
                    handler((created: false, error: "Error creating account with user name and password: \(error.localizedDescription)"))
                } else{
                    //The authResult has user.uid and user.email
                    print("Sucess creating authenticated account: \(authResult!)")
                    //We now want to create this user in our database
                    self.createUser(uid: (authResult?.user.uid)!, fn: userRegModel.firstName, ln: userRegModel.lastName, aid: userRegModel.associationID, accessCode: noSpacesAccessCode, timeAndHalf: userRegModel.timeAndHalf, handler: {(success) -> Void in
                        if success {
                            //Self.getUser
                            //Firebase automatically gets user so we dont need to call this
//                            self.db.collection("accessCodes").document(noSpacesAccessCode).delete(){ err in
//                                if let err = err {
//                                    print("Error removing document: \(err)")
//                                } else {
//                                    print("Document successfully removed!")
//                                }
//                            }
                            handler((created: true, error: ""))
                        } else{
                            //Failutre to create user
                            handler((created: false, error: "Failure creating user within application"))
                        }
                    })

                }
            }
        }else{
            print("ERROR WITH ACCESS CODE")
            print(userRegModel.accessCode)
            print(accessCodes)
            handler((created: false, error: "Invalid access code"))
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


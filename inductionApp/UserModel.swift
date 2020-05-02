//
//  UserModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase


class User: ObservableObject {
    //@Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    let associationID: String
    let testRefs: [String]
    let tests: [Test] = []
    
    init(fn: String, ln: String, id: String, aID: String, testRefs: [String]){
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.associationID = aID
        self.testRefs = testRefs
    }
    
    func getTests(){
        let storageRef = Storage.storage().reference().child("\(associationID)Files/testJSONS")
        storageRef.listAll { (result, error) in
          if let error = error {
            // ...
          }
          for prefix in result.prefixes {
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
          for item in result.items {
//            item.get
          }
        }
        
        //let storageRef = Storage.storage().reference(withPath: "\(associationID)Files")
    }
    
}




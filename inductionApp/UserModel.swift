//
//  UserModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import Foundation
import Firebase


class User: ObservableObject {
    @Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    let association: String
    let tests: [Test] = []
    
    init(fn: String, ln: String, id: String){
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.association = "NU Tutors"
    }
    
}


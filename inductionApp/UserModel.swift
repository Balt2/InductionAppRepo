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
    
    
    @Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    let associationID: String
    let testRefs: [String]
    var tests: [Test] = []
    
    init(fn: String, ln: String, id: String, aID: String, testRefs: [String], completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.associationID = aID
        self.testRefs = testRefs
        self.getTests { test in
            self.tests.append(test)
            print(test)
            print("DANNIEL")
            self.isLoggedIn = true
            completionHandler(true)
            
        }
    }
    

    
    func getTests(completionHandler: @escaping (_ test: Test) -> ()) {
        self.getTestPDFs { pdfs in
            self.getTestJsons { jsons in
                let test = Test(jsonData: jsons[0], pdfData: pdfs[0])
                print(test)
                completionHandler(test)
            }
            
        }
        
    }
    
    func getTestJsons(completionHandler: @escaping (_ jsons: [Data]) -> ()) {
        print("GETTING JSONS...")
        var jsonDataList: [Data] = []
        let storageRef = Storage.storage().reference().child("\(associationID)Files/testJSONS")
        storageRef.listAll { (result, error) in
          if let error = error {
            print("ERROR RETRIVEVING JSONs FROM DATABASE")
            completionHandler(jsonDataList)
          }
            print(result.prefixes)
          for prefix in result.prefixes {
            print("PREFIX: \(prefix)")
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
            print("JSONS ARRAY: \(result.items)")
          for item in result.items {
            item.getData(maxSize: 1 * 1024 * 1024){data, error in
                if let error = error {
                    print("Error retriving JSON")
                }else{
                    print(data)
                    jsonDataList.append(data!)
                    completionHandler(jsonDataList)
                }
            }
            
          }
            
        }
    }
    
    func getTestPDFs(completionHandler: @escaping (_ jsons: [Data]) -> ()) {
        print("Getting PDFs...")
        var pdfDataList: [Data] = []
        let storageRef = Storage.storage().reference().child("\(associationID)Files/testPDFS")
        storageRef.listAll { (result, error) in
          if let error = error {
            print("ERROR RETRIVEVING PDF's FROM DATABASE")
            completionHandler(pdfDataList)
          }
          for prefix in result.prefixes {
            print("PDFS")
            print("PREFIX: \(prefix)")
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
            print("PDFS ARRAY: \(result.items)")
          for item in result.items {
            print("HELLO")
            item.getData(maxSize: 40 * 1024 * 1024){data, error in
                if let error = error {
                    print("Error retriving JSON")
                }else{
                    print("PDFS: \(data)")
                    pdfDataList.append(data!)
                     completionHandler(pdfDataList)
                }
            }
           

          }
        }
        
        //let storageRef = Storage.storage().reference(withPath: "\(associationID)Files")
    }
    
}




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
    
    init(fn: String, ln: String, id: String, aID: String, testRefs: [String]) {//, completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.associationID = aID
        self.testRefs = testRefs
        self.getTestsFromFolder{testList in
            print("DONE")
        }
        self.getTests { testList in
            self.tests.append(contentsOf: testList)
            self.isLoggedIn = true
            //completionHandler(true)
        }
    }
    

    
    
    func getTests(completionHandler: @escaping (_ testList: [Test]) -> ()) {
        var testListFromDB: [Test] = []
        
        
        self.getTestPDFs { pdfs in
            self.getTestJsons { jsons in
                for (index, json) in jsons.enumerated() {
                    let searchString = json.1.prefix(4)
                    let correctPdf = pdfs.filter {$0.1.contains(searchString)}
                    let test = Test(jsonData: json.0 , pdfData: correctPdf[0].0)
                    testListFromDB.append(test)
                }
                print(testListFromDB)
                completionHandler(testListFromDB)
            }
            
        }
        
    }
    
    func getTestsFromFolder(completionHandler: @escaping (_ testList: [Test]) -> ()) {
        print("BENDa")
        var testListFromDB: [Test] = []
        let storageRef = Storage.storage().reference().child("\(associationID)Files/")
         storageRef.listAll { (result, error) in
            if let error = error {
              print("ERROR RETRIVEVING JSONs FROM DATABASE")
              completionHandler(testListFromDB)
            }
            
            for item in result.items {
              print(item.name)
              item.getData(maxSize: 1 * 1024 * 1024){data, error in
                  if let error = error {
                      print("Error retriving JSON")
                  }else{
                      print("JSON DATA: \(data)")
                      //testListFromDB.append(data!)
                      if testListFromDB.count == result.items.count {
                          print("Done Loading JSON")
                          completionHandler(testListFromDB)
                      }
                  }
              }
            }
        }
    }
    
    
    
    func getTestJsons(completionHandler: @escaping (_ jsons: [(Data, String)]) -> ()) {
        print("GETTING JSONS...")
        var jsonDataList: [(Data, String)] = []
        let storageRef = Storage.storage().reference().child("\(associationID)Files/testJSONS")
        storageRef.listAll { (result, error) in
            
          if let error = error {
            print("ERROR RETRIVEVING JSONs FROM DATABASE")
            completionHandler(jsonDataList)
          }
            print("JSON Prefixes")
            print(result.prefixes)
          for prefix in result.prefixes {
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
            
          print("JSONS ARRAY: \(result.items)")
          for item in result.items {
            print(item.name)
            item.getData(maxSize: 1 * 1024 * 1024){data, error in
                if let error = error {
                    print("Error retriving JSON")
                }else{
                    print("JSON DATA: \(data)")
                    jsonDataList.append( (data!, item.name) )
                    if jsonDataList.count == result.items.count {
                        print("Done Loading JSON")
                        completionHandler(jsonDataList)
                    }
                }
            }
          }
        }
    }
    
    func getTestPDFs(completionHandler: @escaping (_ jsons: [(Data, String)]) -> ()) {
        print("Getting PDFs...")
        var pdfDataList: [(Data, String)] = []
        let storageRef = Storage.storage().reference().child("\(associationID)Files/testPDFS")
        storageRef.listAll { (result, error) in
            
          if let error = error {
            print("ERROR RETRIVEVING PDF's FROM DATABASE")
            completionHandler(pdfDataList)
          }
            print("PDF Prefixes")
            print(result.prefixes)
          for prefix in result.prefixes {
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
            print("PDFS ARRAY: \(result.items)")
          for item in result.items {
            print(item.name)
            item.getData(maxSize: 40 * 1024 * 1024){data, error in
                if let error = error {
                    print("Error retriving PDF")
                }else{
                    print("PDF DATA: \(data)")
                    pdfDataList.append( (data!, item.name))
                    
                    if pdfDataList.count == result.items.count {
                        print("Done Loading PDFS")
                        completionHandler(pdfDataList)
                    }
                    
                }
                
            }
           

          }
        }
        
        //let storageRef = Storage.storage().reference(withPath: "\(associationID)Files")
    }
    
}




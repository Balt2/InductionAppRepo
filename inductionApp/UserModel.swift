//
//  UserModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase


class User: ObservableObject, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    
    @Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    let associationID: String
    let testRefs: [String]
    @Published var tests: [Test] = []
    @Published var getTestsComplete = false
    var performancePDF = [PageModel]()
    
    init(fn: String, ln: String, id: String, aID: String, testRefs: [String]) {//, completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.associationID = aID
        self.testRefs = testRefs
        
        
        self.getTests{_ in
            //If boolean is false then no tests exist
            self.getTestsComplete = true
        }
        
//        self.addTests { b in
//            if b == true{
//                print("At least one test loaded in")
//                self.getTestsComplete = true
//            }else{
//                print("No Test loaded in")
//                self.getTestsComplete = true
//            }
//        }
        
//        self.getPerformancePdf { pdf in
//            self.performancePDF = TestPDF(data: pdf).pages
//        }
    }
    
    func getTests(completionHandler: @escaping (_ completion: Bool) -> ()) {
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        if testRefs.count == 0 {completionHandler(false)} //Return if there are no tests in testRefs available
        for testRef in self.testRefs {
            let refJson: StorageReference = Storage.storage().reference().child("\(associationID)/tests/\(testRef).json")
            let refPdf: StorageReference = Storage.storage().reference().child("\(associationID)/tests/\(testRef).pdf")
            getFile(ref: refJson, pdf: false){jsonD in
                guard let jsonData = jsonD else {return}
                self.getFile(ref: refPdf, pdf: true){pdfD in
                    guard let pdfData = pdfD else {return}
                    let test = Test(jsonData: jsonData, pdfData: pdfData)
                    print("TEST ADDED: \(refJson.fullPath)")
                    self.tests.append(test)
                    count += 1
                    if count == self.testRefs.count {completionHandler(true)}
                }
            }
        }
    }
    
    func getFile(ref: StorageReference, pdf: Bool, completionHandler: @escaping (_ completion: Data?) -> ()) {
        ref.getData(maxSize: pdf == true ? (40 * 1024 * 1024) : (1 * 1024 * 1024)){data, error in
            if let error = error {
                print("error retriving file at: \(ref.fullPath)")
                completionHandler(nil)
            }else{
                completionHandler(data!)
            }
        }
    }
    
    
    
    
    func addTests(completionHandler: @escaping (_ completion: Bool) -> ()) {

        self.getTestPDFs { pdfs in
            self.getTestJsons { jsons in
                for (index, json) in jsons.enumerated() {
                    let searchString = json.1.prefix(4)
                    let correctPdf = pdfs.filter {$0.1.contains(searchString)}
                    let test = Test(jsonData: json.0 , pdfData: correctPdf[0].0)
                    self.tests.append(test)
                }
                if self.tests.count == 0 {
                    completionHandler(false)
                }else{
                    completionHandler(true)
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
            if result.items.count == 0 {
                completionHandler(jsonDataList)
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
            if result.items.count == 0 {
                completionHandler(pdfDataList)
            }
        }
        
        //let storageRef = Storage.storage().reference(withPath: "\(associationID)Files")
    }
    
    func getPerformancePdf(completionHandler: @escaping (_ pdf: Data) -> ()) {
        print("Getting PDF Perforamce...")
        var pdfD = Data()
        let storageRef = Storage.storage().reference().child("\(associationID)Files/performancePdfs")
        storageRef.listAll { (result, error) in
            
            if let error = error {
                print("ERROR RETRIVEVING PDF's FROM DATABASE")
                completionHandler(pdfD)
            }
            
            print("PDFS ARRAY: \(result.items)")
            result.items[0].getData(maxSize: 40 * 1024 * 1024){data, error in
                if let error = error {
                    print("Error retriving PDF")
                }else{
                    print("PDF DATA: \(data)")
                    pdfD = data!
                    completionHandler(pdfD)
                }
            }
        }
        
    }
    
}




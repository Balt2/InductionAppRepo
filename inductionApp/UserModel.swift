//
//  UserModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class User: ObservableObject, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    @Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    var association: Association
    let testRefs: [String]
    @Published var tests: [Test] = []
    @Published var getTestsComplete = false
    var performancePDF = [PageModel]()
    
    init(fn: String, ln: String, id: String, association: Association, testRefs: [String]) {//, completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.association = association
        self.testRefs = testRefs
        
        //Getting Associations image
        let imageRef: StorageReference = Storage.storage().reference().child(association.imagePath)
        self.getFile(ref: imageRef, pdf: false){image in
            //Image is data, the UI will turn it into a UIImage
            if let imageData = image{
                self.association.image = UIImage(data: imageData)
            }
            //self.association.image = UIImage(data: image!)
            
        }
        
        self.getTests{_ in
            //If boolean is false then no tests exist
            self.getTestsComplete = true
        }
        
//        self.getPerformancePdf { pdf in
//            self.performancePDF = TestPDF(data: pdf).pages
//        }
    }
    
    func getTests(completionHandler: @escaping (_ completion: Bool) -> ()) {
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        if testRefs.count == 0 {completionHandler(false)} //Return if there are no tests in testRefs available
        for testRef in self.testRefs {
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef).json")
            let refPdf: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef).pdf")
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
    
    

    

    //DONT USE ANYMORE. USINGN AS EXAMPLE OF LIST ALL
    func getTestPDFs(completionHandler: @escaping (_ jsons: [(Data, String)]) -> ()) {
        print("Getting PDFs...")
        var pdfDataList: [(Data, String)] = []
        let storageRef = Storage.storage().reference().child("\(association.associationID)Files/testPDFS")
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
        let storageRef = Storage.storage().reference().child("\(association.associationID)Files/performancePdfs")
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




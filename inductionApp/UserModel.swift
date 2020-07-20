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
import SwiftUI
import CoreData



class User: ObservableObject, Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var db = Firestore.firestore() //Instance of database
    let id: String
    let firstName: String
    let lastName: String
    var association: Association
    
    @Published var tests: [Test] = []
    
    
    @Published var allACTPerformanceData: AllACTData?
    @Published var allSATPerformanceData: AllACTData?
    @Published var showACTData: Bool?
    var currentPerformanceData: AllACTData?{
        if showACTData == true{
            return allACTPerformanceData
        }else if showACTData == false{
            return allSATPerformanceData
        }else{
            return nil
        }
    }
    
    @Published var getTestsComplete = false
    @Published var getPerformanceDataComplete = false
    var performancePDF = [PageModel]()
    
    var testRefs: [String]
    var testRefsMap: [String: Bool]?
    var testResultRefs: [String]
    var studyRefs: [String] = []
    var studyResultRefs: [String] = []
    
    
    init(fn: String, ln: String, id: String, association: Association, testRefs: [String], testResultRefs: [String]) {//, completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.association = association
        self.testRefs = testRefs
        self.testResultRefs = testResultRefs
        
        //Getting Associations image
        let imageRef: StorageReference = Storage.storage().reference().child(association.imagePath)
        
        
        self.getFile(ref: imageRef, pdf: false){image in
            print("IMAGEEE")
            //Image is data, the UI will turn it into a UIImage
            if let imageData = image{
                print("Got Image, User Init")
                self.association.image = UIImage(data: imageData)
            }
        }
        
        self.getTestData{testsData in
            DispatchQueue.global(qos: .utility).async {
                var tempArray: [Test] = []
                if testsData != nil{
                    for test in testsData!{
                        let tempTest = Test(jsonData: test.json, pdfData: test.pdf)
                        tempArray.append(tempTest)
                    }
                    //If boolean is false then no tests exist
                    print("Got Tests, User Init")
                    DispatchQueue.main.sync {
                        self.tests.append(contentsOf: tempArray)
                        self.getTestsComplete = true
                    }
                }else{
                    print("ERROR Getting tests")
                    DispatchQueue.main.sync {
                        self.getTestsComplete = true
                    }
                }
            }
        }
        
        self.getTestResultsData{dataArr in
            if !dataArr.isEmpty{
                print("Got Result Jsons, User Init")
                DispatchQueue.global(qos: .utility).async {
                    
                    let actPerformanceTests: [ACTFormatedTestData] = dataArr.enumerated().map{(index, data) in
                        ACTFormatedTestData(data: data, index: index, tutorPDFName: "BreiteJ-CB1")
                    }
                    DispatchQueue.main.sync{
                        //Loading in the performance PDFs
                        self.allACTPerformanceData = AllACTData(tests: actPerformanceTests.filter {$0.act == true}, isACT: true, user: self)
                        self.allSATPerformanceData = AllACTData(tests: actPerformanceTests.filter{$0.act == false}, isACT: false, user: self)
                        
                        if self.allACTPerformanceData != nil {
                            self.showACTData = true
                            print("SHOW ACT TRUE")
                            print(self.allACTPerformanceData)
                            print(self.allACTPerformanceData!.overallPerformance)
                        }else if self.allSATPerformanceData != nil {
                            self.showACTData = false
                            print("SHOW SAT TRUE")
                        }
                        print(actPerformanceTests.count)
                        self.getPerformanceDataComplete = true
                        
                        print("Finished Creating Result Data")
                    }
                }
            }else{
                self.getPerformanceDataComplete = true
                print("Did not get result jsons")
            }
            
            
        }
        print("DONE CREATING USER")
    }
    
    func getTestData(completionHandler: @escaping (_ dataArray: [(pdf: Data, json: Data)]?) -> ()) {
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        if testRefs.count == 0 {completionHandler(nil)} //Return if there are no tests in testRefs available
        var sendArray: [(pdf: Data, json: Data)] = []
        for testRef in self.testRefs {
            print("STILL IN GET TETSTS")
            print(testRef)
            
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef).json")
            let refPdf: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef).pdf")
            let jsonURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef).json")
            let pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef).pdf")
            if FileManager.default.fileExists(atPath: jsonURL.path){
                do {
                    print("GETTING DOCUMENTS")
                    let jsonData = try Data(contentsOf: jsonURL)
                    let pdfData = try Data(contentsOf: pdfURL)
                    sendArray.append((pdf: pdfData, json: jsonData))
                    //let test = Test(jsonData: jsonData, pdfData: pdfData)
                    //self.tests.append(test)
                    count += 1
                    print("GOT DOCUMENTs")
                    print("COUNT: \(count)")
                    if count == self.testRefs.count {completionHandler(sendArray)}
                }  catch{
                    print("ERROR Retriving data from local storage")
                }
            }else{
                print("Getting json/pdf data from database")
                print(refJson)
                print(refPdf)
                   self.getFile(ref: refJson, pdf: false){jsonD in
                    
                       guard let jsonDataC = jsonD else {return}
                       self.getFile(ref: refPdf, pdf: true){pdfD in
                           guard let pdfDataC = pdfD else {return}
                        print("GETTING TEST FROM DATABASE")
                           sendArray.append((pdf: pdfDataC, json: jsonDataC))
                           count += 1
                           do {
                               print("Writing document to file manager")
                               try pdfDataC.write(to: pdfURL)
                               try jsonDataC.write(to: jsonURL)
                                print("Success Writing Document to file manager")
                           }
                           catch {
                               print("ERROR WRITING DOCUMENT")
                           }
                        print("COUNT: \(count)")
                        if count == self.testRefs.count {completionHandler(sendArray)}
                       }
                   }
                
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getTestResultsData(completionHandler: @escaping  (_ completion: [Data]) -> ()){
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        var dataArray = [Data]()
        if testResultRefs.count == 0 {completionHandler(dataArray)} //Return if there are no tests in testRefs available
        print(testResultRefs)
        for testResultRef in testResultRefs{
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/testResults/\(testResultRef).json")
            let jsonURL = self.getDocumentsDirectory().appendingPathComponent("\(testResultRef).json")
            
            if !FileManager.default.fileExists(atPath: jsonURL.path){
                do{
                    print("GETTING PERFORMANCE JSON FROM FILE MANAGER")
                    let jsonData = try Data(contentsOf: jsonURL)
                    dataArray.append(jsonData)
                    count += 1
                    if count == self.testResultRefs.count {completionHandler(dataArray)}
                }catch{
                    print("ERROR Retriving performance json from file manager")
                }
            }else{
                getFile(ref: refJson, pdf: false){jsonD in
                    print("GETTING TEST RESULT JSON")
                    guard let jsonData = jsonD else {return}
                    dataArray.append(jsonData)
                    count += 1
                    do {
                        print("Writing document to file manager")
                        try jsonData.write(to: jsonURL)
                         print("Success Writing Document to file manager")
                    }
                    catch {
                        print("ERROR WRITING DOCUMENT")
                    }
                    if count == self.testResultRefs.count {completionHandler(dataArray)}
                }
            }

        }
    }
    
    func getFile(ref: StorageReference, pdf: Bool, completionHandler: @escaping (_ completion: Data?) -> ()) {
        ref.getData(maxSize: pdf == true ? (40 * 1024 * 1024) : (1 * 1024 * 1024)){data, error in
            if let error = error {
                print(pdf)
                print(ref)
                print("error retriving file at: \(ref.fullPath) with error: \(error)")
                completionHandler(nil)
            }else{
                completionHandler(data!)
            }
        }
    }
    
    func uploadedTestPDF(testRef: String, completionHander: @escaping (_ completition: Bool) -> ()){
        self.testRefsMap![testRef] = true
        self.db.collection("users").document(self.id).updateData([
            "testRefsMap": self.testRefsMap!
        ]){error in
            if let error = error{
                self.testRefsMap![testRef] = false
                print("ERROR Updating testRefsMap")
                completionHander(false)
            }else{
                completionHander(true)
            }
        }
    }
    
    
    
    //DONT USE ANYMORE. USINGN AS EXAMPLE OF LIST ALL
//    func getTestPDFs(completionHandler: @escaping (_ jsons: [(Data, String)]) -> ()) {
//        print("Getting PDFs...")
//        var pdfDataList: [(Data, String)] = []
//        let storageRef = Storage.storage().reference().child("\(association.associationID)Files/testPDFS")
//        storageRef.listAll { (result, error) in
//
//            if let error = error {
//                print("ERROR RETRIVEVING PDF's FROM DATABASE with error: \(error)")
//                completionHandler(pdfDataList)
//            }
//            print("PDF Prefixes")
//            print(result.prefixes)
//            for prefix in result.prefixes {
//                // The prefixes under storageReference.
//                // You may call listAll(completion:) recursively on them.
//            }
//            print("PDFS ARRAY: \(result.items)")
//            for item in result.items {
//                print(item.name)
//                item.getData(maxSize: 40 * 1024 * 1024){data, error in
//                    if let error = error {
//                        print("Error retriving PDF")
//                    }else{
//                        print("PDF DATA: \(data)")
//                        pdfDataList.append( (data!, item.name))
//
//                        if pdfDataList.count == result.items.count {
//                            print("Done Loading PDFS")
//                            completionHandler(pdfDataList)
//                        }
//
//                    }
//
//                }
//
//
//            }
//            if result.items.count == 0 {
//                completionHandler(pdfDataList)
//            }
//        }
//
//        //let storageRef = Storage.storage().reference(withPath: "\(associationID)Files")
//    }

    
}




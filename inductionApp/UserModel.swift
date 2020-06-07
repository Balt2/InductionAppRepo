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



class User: ObservableObject, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    @Published var isLoggedIn = false
    let id: String
    let firstName: String
    let lastName: String
    var association: Association
    
    @Published var tests: [Test] = []
    var testResults: [Test] = []
    var fullTestResults: [ACTFormatedTestData] = []
    var sectionDateGraphs: [String: BarData]{
        
        var sectionEntries = [String: [BarEntry]]()
        for test in fullTestResults{
            for (key, sectionData) in test.sectionsOverall{
                if sectionEntries[key] == nil{
                    sectionEntries[key] = [sectionData]
                }else{
                    sectionEntries[key]!.append(sectionData)
                }
            }
        }
        var sectionGraphs = [String: BarData]()
        for (section, entries) in sectionEntries{
            let tempGraph = BarData(title: "ACT \(section) Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: entries)
            sectionGraphs[section] = tempGraph
        }
        return sectionGraphs
    }
    @Published var getTestsComplete = false
    var performancePDF = [PageModel]()
    
    var testRefs: [String]
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
//        self.testResultRefs.append("1904sFilled")
//        self.testResultRefs.append("1912SFilled")
        print("HELLO?")
        self.getTestResults{_ in
            print("BENJAIMIN")
            print(self.testResultRefs)
            print(self.testResults)
            for (index, testResult) in self.testResults.enumerated(){
                self.createResulut(test: testResult, index: index)
            }
        }
        print("DONE CREATING USER")
        
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
    
    func getTestResults(completionHandler: @escaping  (_ completion: Bool) -> ()){
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        if testResultRefs.count == 0 {completionHandler(false)} //Return if there are no tests in testRefs available
        for testResultRef in testResultRefs{
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/testResults/\(testResultRef).json")
            getFile(ref: refJson, pdf: false){jsonD in
                guard let jsonData = jsonD else {return}
                let testResuult = Test(jsonData: jsonData)
                self.testResults.append(testResuult)
                count += 1
                if count == self.testResultRefs.count {completionHandler(true)}
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
    
    func createResulut(test: Test, index: Int){
        print("BEN")
        var overall = BarEntry(xLabel: "\(test.testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(test.overallScore), color: Color.orange)], index: index)
        var sectionsOverall = [String : BarEntry]()
        var subSectionGraphs = [String: BarData]()
        //var scatterTiming = BarData(title: "\(section.name) by sub section", xAxisLabel: "Categories", yAxisLabel: "Questions", yAxisSegments: 5, yAxisTotal: 30, barEntries: [])
        for section in test.sections{
            var data = [String:(r: CGFloat, w: CGFloat, o: CGFloat)]()
            let subSectionEntry = BarEntry(xLabel: "\(test.testFromJson!.dateTaken!)", yEntries: [(height: CGFloat(section.scaledScore!), color: Color.orange)], index: index)
            sectionsOverall[section.name] = subSectionEntry
            for question in section.questions{
                switch question.finalState{
                    case .right:
                    
                        if data[question.officialSub] != nil{
                            data[question.officialSub]?.r+=1
                        }else{
                            data[question.officialSub] = (r:1, w: 0, o: 0)
                        }
                    case .wrong:
                        if data[question.officialSub] != nil{
                            data[question.officialSub]?.w+=1
                        }else{
                            data[question.officialSub] = (r:0, w: 1, o: 0)
                        }
                    default:
                        print(question)
                        print(question.finalState)
                        print(question.userAnswer)
                        if data[question.officialSub] != nil{
                            data[question.officialSub]?.o+=1
                        }else{
                            data[
                                question.officialSub] = (r:0, w: 0, o: 1)
                        }
                    }
                }
            var barData = BarData(title: "\(section.name) by sub section", xAxisLabel: "Categories", yAxisLabel: "Questions", yAxisSegments: 5, yAxisTotal: 0, barEntries: [])
            var yAxisTotalArray = [Int]()
            for (subSectionString, values) in data{
                yAxisTotalArray.append(Int(values.r +  values.w + values.o))
                let barEntry = BarEntry(xLabel: subSectionString, yEntries: [(height: values.r, color: Color.green), (height: values.w, color: Color.red), (height: values.o, color: Color.gray)])
                
                barData.barEntries.append(barEntry)
            }
            barData.yAxisTotal = yAxisTotalArray.max()!
            print(barData.barEntries)
            
            subSectionGraphs[section.name] = barData
            
        }
        let formatedTestResulut = ACTFormatedTestData(overall: overall, sectionsOverall: sectionsOverall, subSectionGraphs: subSectionGraphs)
        fullTestResults.append(formatedTestResulut)
        
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




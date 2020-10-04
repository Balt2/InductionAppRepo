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
    @Published var allPSATPerformanceData: AllACTData?
    

    @Published var showTestType: TestType?
    var currentPerformanceData: AllACTData?{
        if showTestType == .act {
            return allACTPerformanceData
        }else if showTestType == .sat {
            return allSATPerformanceData
        }else if showTestType == .psat {
            return allPSATPerformanceData
        }else{
            return nil
        }
    }
    
    var currentQuickData: QuickData {
        if showTestType == .act {
            return quickDataACT
        }else if showTestType == .sat {
            return quickDataSAT
        }else { //SAT or PSAT or Nil
            return quickDataPSAT
        }
        
    }
    

    
    
    
    
    
    
    @Published var getTestsComplete = false
    @Published var getPerformanceDataComplete = false
    var performancePDF = [PageModel]()
    
    //var testRefsMap: [String: Bool] = [:]
    @ObservedObject var testRefsMap: ObservableDict
    var testResultRefs: [String]
    var studyRefs: [String] = []
    var studyResultRefs: [String] = []
    var showInstructions: Bool = false
    
    @ObservedObject var quickDataSAT: QuickData
    @ObservedObject var quickDataACT: QuickData
    @ObservedObject var quickDataPSAT: QuickData
    
    
    init(fn: String, ln: String, id: String, association: Association, testResultRefs: [String], testRefsMap: [String: Bool]) {//, completionHandler: @escaping (_ succsess: Bool) -> ()){
        print("INIT USER begin")
        self.id = id
        self.firstName = fn
        self.lastName = ln
        self.association = association
        self.testResultRefs = testResultRefs
        self.testRefsMap = ObservableDict(dict: testRefsMap)
        
        quickDataSAT = QuickData(testType: .sat)
        quickDataACT = QuickData(testType: .act)
        quickDataPSAT = QuickData(testType: .psat)
        
        //Getting Associations image
//        let imageRef: StorageReference = Storage.storage().reference().child(association.imagePath)
//
//
//        self.getFile(ref: imageRef, pdf: false){image in
//            //Image is data, the UI will turn it into a UIImage
//            if let imageData = image{
//                print("Got Association Image")
//                self.association.image = UIImage(data: imageData)
//            }
//        }
        
        //Get the test pdf and json pairs
//        self.getPdfJsonPair(isTestResult: false, searchArray: Array(testRefsMap.keys)){testsData in
//
//            print (!testsData.isEmpty)
//            if !testsData.isEmpty{
//                print("TEST DATA NOT EMPTY")
//                DispatchQueue.global(qos: .utility).async {
//                   var tempArray: [Test] = []
//                    for test in testsData{
//                           let tempTest = Test(jsonData: test.json, pdfData: test.pdf, corrections: false)
//                           tempArray.append(tempTest)
//                       }
//                       //If boolean is false then no tests exist
//                       print("Got Tests, User Init")
//                       DispatchQueue.main.sync {
//                           self.tests.append(contentsOf: tempArray)
//                           self.getTestsComplete = true
//                       }
//               }
//            }else{
//                print("ERROR Getting tests")
//                DispatchQueue.main.sync {
//                    self.getTestsComplete = true
//                }
//            }
//        }
        
        //Getting the real tests without the pdf/png. Will wait to do this.
        self.getTestJsons(searchArray: Array(testRefsMap.keys)){jsons in
            if !jsons.isEmpty{
                DispatchQueue.global(qos: .utility).async {
                    var tempJsonArray: [Test] = []
                    for json in jsons{
                        let tempTest = Test(jsonData: json, corrections: false, user: self)
                        tempJsonArray.append(tempTest)
                    }
                    DispatchQueue.main.sync {
                        self.tests.append(contentsOf: tempJsonArray)
                        self.getTestsComplete = true
                    }
                }
            }else{
                print("ERROR Getting tests")
                DispatchQueue.main.sync {
                    self.getTestsComplete = true
                }
            }
        }
        
        
        
        //Getting the real tests
//        self.getPngsJsonPair(isTestResult: false, searchArray: Array(testRefsMap.keys)){testsData in
//            if !testsData.isEmpty{
//                print("TEST DATA NOT EMPTY")
//                DispatchQueue.global(qos: .utility).async {
//                   var tempArray: [Test] = []
//                    for test in testsData{
//                        let tempTest = Test(jsonData: test.json, pngData: test.pngs, corrections: false)
//                           //let tempTest = Test(jsonData: test.json, pdfData: test.pdf, corrections: false)
//                           tempArray.append(tempTest)
//                       }
//                   //If boolean is false then no tests exist
//                   print("Got Tests, User Init")
//                   DispatchQueue.main.sync {
//                    self.tests.append(contentsOf: tempArray)
//                       self.getTestsComplete = true
//                   }
//               }
//            }else{
//                print("ERROR Getting tests")
//                DispatchQueue.main.sync {
//                    self.getTestsComplete = true
//                }
//            }
//
//        }

        //Get the test result pdf and json pairs
        self.getPdfJsonPair(isTestResult: true, searchArray: testResultRefs){dataArr in
            var actPerformanceTests: [ACTFormatedTestData] = []
            if !dataArr.isEmpty{
                print("Getting test result JSONS")
                DispatchQueue.global(qos: .utility).async {
                    for test in dataArr {
                        let tempNewPerformanceTest = ACTFormatedTestData(pdfData: test.pdf, jsonData: test.json)
                        actPerformanceTests.append(tempNewPerformanceTest)
                    }
                    
                    //                        ACTFormatedTestData(data: data, index: index, pdfPages: associatedTestPages!, tutorPDFName: "BreiteJ-CB1")
                    DispatchQueue.main.async{
                        //Loading in the performance PDFs
                        let actTests = actPerformanceTests.filter {$0.testType! == .act}
                        let satTests = actPerformanceTests.filter {$0.testType! == .sat}
                        let psatTests = actPerformanceTests.filter {$0.testType! == .psat}
                        
                        if actTests.count != 0 {
                            self.allACTPerformanceData = AllACTData(tests: actTests, user: self)
                        }
                        
                        if satTests.count != 0 {
                            self.allSATPerformanceData = AllACTData(tests: satTests, user: self)
                        }
                        
                        if psatTests.count != 0{
                            self.allPSATPerformanceData = AllACTData(tests: psatTests, user: self)
                        }
                        
                        
                        if self.allACTPerformanceData != nil {
                            if self.showTestType == nil{
                                self.showTestType = .act
                            }
                            print("SHOW ACT TRUE")
                        }else if self.allSATPerformanceData != nil {
                            if self.showTestType == nil{
                                self.showTestType = .sat
                            }
                            print("SHOW SAT TRUE")
                        }else if self.allPSATPerformanceData != nil{
                            if self.showTestType == nil{
                                self.showTestType = .psat
                            }
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
    
    func getPDFForTest(urlPath: URL, refPdf: StorageReference, completionHandler: @escaping (_ pdfData: Data?) -> ()){
        print("GETTING PDF FOR TEST")
        if FileManager.default.fileExists(atPath: urlPath.path){
            do{
                let pdfData = try Data(contentsOf: urlPath)
                completionHandler(pdfData)
                print("Succses Getting PDF Data from local storage")
            }catch{
                print("ERROR retriving PDF Data from local Storage")
            }
        }else{
            self.getFile(ref: refPdf, pdf: true){pdfD in
                if pdfD == nil{
                    print("PDF FROM DATABASE is NIL")
                    completionHandler(nil) //RETURNING NIL
                }else{
                    do{
                        try pdfD!.write(to: urlPath)
                        print("Success Writing PDF Document to file manager")
                    }catch{
                        print("ERROR WRITING PDF DOCUMENT")
                    }
                    completionHandler(pdfD!)
                }
            }
        }
    }
    
    
    
    func getPdfJsonPair(isTestResult: Bool, searchArray: [String], completionHandler: @escaping (_ completion: [(pdf: Data, json: Data)]) -> ()){
        print("GETTTING PDF JSON PAIR")
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        var dataArray = [(pdf: Data, json: Data)]()
        if searchArray.count == 0 {completionHandler(dataArray)} //Return if there are no tests in testRefs available
        for testRef in searchArray{
            
            let testRefOriginal = testRef.components(separatedBy: "-").first
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/\(isTestResult ? "testResults" : "tests")/\(testRef).json")
            let refPdf: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(isTestResult ? testRefOriginal! : testRef).pdf")
               let jsonURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef).json")
               let pdfURL = self.getDocumentsDirectory().appendingPathComponent("\(isTestResult ? testRefOriginal! : testRef).pdf")
            
            getPDFForTest(urlPath: pdfURL, refPdf: refPdf){pdfD in
                guard let pdfData = pdfD else {return}
                print("Is Testresult: \(isTestResult)...\(testRef)")
                self.getFile(ref: refJson, pdf: false){jsonD in
                    guard let jsonData = jsonD else {return}
                    dataArray.append((pdf: pdfData, json: jsonData))
                    count += 1
//                    do {
//                        print("Writing document to file manager")
//                        try jsonData.write(to: jsonURL)
//                        print("Success Writing Document to file manager")
//                    }
//                    catch {
//                        print("ERROR WRITING DOCUMENT")
//                    }
                    if count == searchArray.count {completionHandler(dataArray)}
                }
            }
        }
    }
    
    func getTestJsons(searchArray: [String], completionHandler: @escaping (_ completion: [Data]) -> ()){
        var dataArray = [Data]()
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        if searchArray.count == 0 {completionHandler(dataArray)}
        for testRef in searchArray{
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef).json")
            self.getFile(ref: refJson, pdf: false){jsonD in
                guard let jsonData = jsonD else {return}
                dataArray.append(jsonData)
                count += 1
                if count == searchArray.count {completionHandler(dataArray)}
            }
            
        }
    }
    
    
    func getPngsJsonPair(isTestResult: Bool, searchArray: [String], completionHandler: @escaping (_ completion: [(pngs: [Data], json: Data)]) -> ()){
        var count = 0 //Used to determine if the array has been searched and we can have the completion handler
        var dataArray = [(pngs: [Data], json: Data)]()
        if searchArray.count == 0 {completionHandler(dataArray)} //Return if there are no tests in testRefs available
        for testRef in searchArray {
            let testRefOriginal = testRef.components(separatedBy: "-").first
            let refJson: StorageReference = Storage.storage().reference().child("\(association.associationID)/\(isTestResult ? "testResults" : "tests")/\(testRef).json")
            //let refPngs: StorageReference = Storage.storage().reference().child("\(association.associationID)/tests/\(isTestResult ? testRefOriginal! : testRef)")
           //let jsonURL = self.getDocumentsDirectory().appendingPathComponent("\(testRef).json")
            getPngs(testRef: isTestResult ? testRefOriginal! : testRef){pngData in
                self.getFile(ref: refJson, pdf: false){jsonD in
                    guard let jsonData = jsonD else {return}
                    dataArray.append((pngs: pngData, json: jsonData))
                    count += 1
                    if count == searchArray.count {completionHandler(dataArray)}
                }
                
            }
           
        }
        
    }
    
    func setInstructionsToFalse(){
        self.db.collection("users").document(self.id).updateData(["showInstructions" : false]){error in
            if let error = error{
                print("ERROR UPDATING Show Instructions: \(error)")
            }else{
                print("SUCCESS UPDATING Show instructions")
            }
        }
    }

    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //Get file from FIrebase storage
    func getFile(ref: StorageReference, pdf: Bool, completionHandler: @escaping (_ completion: Data?) -> ()) {
        ref.getData(maxSize: pdf == true ? (40 * 1024 * 1024) : (1 * 1024 * 1024)){data, error in
            if let error = error {
                print("error retriving file at: \(ref.fullPath) with error: \(error)")
                completionHandler(nil)
            }else{
                completionHandler(data!)
            }
        }
    }
    
    func uploadedTestPDF(testRef: String, completionHander: @escaping (_ completition: Bool) -> ()){
        self.testRefsMap.dict[testRef] = true
        self.db.collection("users").document(self.id).updateData([
            "testRefsMap": self.testRefsMap.dict
        ]){error in
            if let error = error{
                self.testRefsMap.dict[testRef] = false
                print("ERROR Updating testRefsMap")
                completionHander(false)
            }else{
                completionHander(true)
                //self.testRefsMap.dict = self.testRefsMap.dict
            }
        }
    }
    
    
    //Returns all pngs for a given testRef (similar to returning a whole pdf of a test, but photos for each page iinstead)
    func getPngs(testRef: String, completionHander: @escaping (_ completion: [Data]) -> ()){
        //var pngs: [Data] = []
        var pngsWName: [(name: String, data: Data)] = []
        let storageRef = Storage.storage().reference().child("\(association.associationID)/tests/\(testRef)")
        print("GETTING PNGSSSS")
        storageRef.listAll { (result, error) in
            if let error = error {
                print("ERROR GETTTING PNGs")
                //Probably want to revert back to PDFs
            }else{
                print("PRINTING ITEMS")
               
//                let sortedResults = result.items.sorted(by: {$0.name < $1.name})
//                print(sortedResults)
                //let sortedResults = result.items.sorted(by: <)
                
                for (index, item) in result.items.enumerated(){
                    self.getFile(ref: item, pdf: false) {data in
                        if data == nil{
                            print("ERROR GETTING SPECIFIC Png")
                            //Probably want to revert back to PDFs
                        }else{
//                            print("GOT PNG")
//                            print(item)
                            pngsWName.append((name: item.name, data: data!))
                            //pngs.append(data!)
                            if index == result.items.count  - 1 {
                                print("COMPLETE HANDLER")
                                let sortedpngsWName = pngsWName.sorted(by: {$0.name < $1.name})
                                let pngDataArray = sortedpngsWName.map({$0.data})
                                print("GOT ALL PNG DATA FOR TEST")
                                completionHander(pngDataArray)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createSectionsForStudyTable() -> [TestType: [Test]] {
        var sectionDict = [TestType: [Test]]()
        for test in self.tests{
            if sectionDict[test.testType!] == nil{
                sectionDict[test.testType!] = [test]
            }else if self.testRefsMap.dict[test.testFromJson!.testRefName] == false{
                sectionDict[test.testType!]!.append(test)
            }else{
                sectionDict[test.testType!]!.insert(test, at: 0)
            }
        }
    return sectionDict
        
    }
    
}

enum TestType: String {
    case sat = "SAT"
    case act = "ACT"
    case psat = "PSAT"
    
    func getTotalScore() -> Int{
        switch self{
        case .sat:
            return 1600
        case .act:
            return 36
        case .psat:
            return 1520
        }
    }
    
    func getSubSectionTotalScore() -> Int{
        switch self {
        case .sat:
            return 800
        case .act:
            return 36
        case .psat:
            return 760
        }
    }
    
    func getPreTestSurvey() -> MindsetSurveyModel{
        var preTestModel = MindsetSurveyModel(name: "What's your mindset?", sections: [MindsetSectionModel(headers: ["Strongly Disagree", "Disagree", "Agree", "Strongly Agree"],
                                           questions: [MindsetQuestionModel(questionIndex: 1, question: "I feel tense during tests"),
        MindsetQuestionModel(questionIndex: 2, question: "I wish exams did not bother me so much"),
        MindsetQuestionModel(questionIndex: 3, question: "I defeat myself on tests"),
        MindsetQuestionModel(questionIndex: 4, question: "I feel panicky during tests"),
        MindsetQuestionModel(questionIndex: 5, question: "During the exam I am nervous and forget facts")
        ]), MindsetSectionModel(headers: ["Not Much",
         "A Little",
         "Decent Amount",
         "A Lot"], subHeaders: ["Less than 2hrs", "Between 2 and 4hrs", "Between 4 and 8hrs", "More than 8hrs"], questions: [
        MindsetQuestionModel(questionIndex: 6,
                             question: "How much time have you spent on other work today?")]),
            MindsetSectionModel(headers: ["Not Much",
             "A Little",
             "Decent Amount",
             "A Lot"], subHeaders: ["Less than 4hrs", "Between 4 and 6hrs", "Between 6 and 8hrs", "More than 8hrs" ], questions: [
            MindsetQuestionModel(questionIndex: 7,
                                 question: "How much did you sleep last night?")]),
            MindsetSectionModel(headers: ["", "Yes","No",""], questions: [
            MindsetQuestionModel(questionIndex: 8,
                                 question: "Have you worked out today?")])
            
        ])
        return preTestModel
    }
    
    func getPostTestSurvey() -> MindsetSurveyModel{
        switch self {
        case .act:
            var postTestACT = MindsetSurveyModel(name: "How Was the Test?", sections: [MindsetSectionModel(headers: ["Strongly Disagree", "Disagree", "Agree", "Strongly Agree"],
                                               questions: [MindsetQuestionModel(questionIndex: 1, question: "I feel tense during tests"),
            MindsetQuestionModel(questionIndex: 2, question: "I wish exams did not bother me so much"),
            MindsetQuestionModel(questionIndex: 3, question: "I defeat myself on tests"),
            MindsetQuestionModel(questionIndex: 4, question: "I feel panicky during tests"),
            MindsetQuestionModel(questionIndex: 5, question: "During the exam I am nervous and forget facts")
            ]), MindsetSectionModel(headers: ["Really Bad",
             "Bad",
             "Good",
             "Really Good"], questions: [
            MindsetQuestionModel(questionIndex: 6,
                                 question: "How did you feel while taking the test?")]),
                MindsetSectionModel(headers: ["Reading",
                 "English",
                 "Math",
                 "Science"], questions: [
                MindsetQuestionModel(questionIndex: 7,
                                     question: "Which Section felt the best?"),
                MindsetQuestionModel(questionIndex: 8,
                question: "Which Section felt the worst?")
                ])])
            
            //,
//            MindsetSectionModel(headers: [], questions: [
//            MindsetQuestionModel(questionIndex: 9,
//                                 question: "Is there anything you think could have affected your performacne?")])
            return postTestACT
        default:
            var postTestSAT = MindsetSurveyModel(name: "How was the Test?", sections: [MindsetSectionModel(headers: ["Strongly Disagree", "Disagree", "Agree", "Strongly Agree"],
                                               questions: [MindsetQuestionModel(questionIndex: 1, question: "I feel tense during tests"),
            MindsetQuestionModel(questionIndex: 2, question: "I wish exams did not bother me so much"),
            MindsetQuestionModel(questionIndex: 3, question: "I defeat myself on tests"),
            MindsetQuestionModel(questionIndex: 4, question: "I feel panicky during tests"),
            MindsetQuestionModel(questionIndex: 5, question: "During the exam I am nervous and forget facts")
            ]), MindsetSectionModel(headers: ["Really Bad",
             "Bad",
             "Good",
             "Really Good"], questions: [
            MindsetQuestionModel(questionIndex: 6,
                                 question: "How did you feel while taking the test?")]),
                MindsetSectionModel(headers: ["English", "Reading",
                 "Math No Calc", "Math Calc"], questions: [
                MindsetQuestionModel(questionIndex: 7,
                                     question: "Which Section felt the best?"),
                MindsetQuestionModel(questionIndex: 8,
                question: "Which Section felt the worst?")
                ])
                
            ])
            
//            MindsetSectionModel(headers: [], questions: [
//            MindsetQuestionModel(questionIndex: 9,
//                                 question: "Is there anything you think could have affected your performacne?")])
            return postTestSAT
        }
    }
}

class ObservableDict: ObservableObject, Hashable{
    static func == (lhs: ObservableDict, rhs: ObservableDict) -> Bool {
        lhs.dict.keys == rhs.dict.keys
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    @Published var dict: [String: Bool]
    init(dict: [String: Bool]){
        self.dict = dict
    }
}






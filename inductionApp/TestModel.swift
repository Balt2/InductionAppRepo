//
//  TestModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase
import PencilKit
import Combine

class TestList: ObservableObject {
    @Published var tests = [Test]()
    
    func add(test: Test){
        tests.append(test)
    }
}

class TestSection: Hashable, Identifiable {
    
    static func == (lhs: TestSection, rhs: TestSection) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    var id = UUID()
    var allotedTime: Double
    var leftOverTime: Double
    var begunSection = false{
        didSet{
            if begunSection == true{
                sectionTimer.startTimer()
            }
        }
    }
    var sectionOver = false{
        didSet{
            if sectionOver == true{
                sectionTimer.endTimer()
                self.leftOverTime = sectionTimer.timeRemaining
                print("Section OVER")
            }
        }
    }
    var sectionTimer: CustomTimer
    
    var name: String
    var sectionIndex: Int
    var index: (start: Int, end: Int) //Index of pages in the pdf
    var pages = [PageModel]()
    var questions = [Question]()
    
    init(sectionFromJson: TestSectionFromJson, pages: [PageModel], name: String, questions: [Question] ) {
        self.allotedTime = Double(sectionFromJson.timeAllowed)
        self.leftOverTime = Double(sectionFromJson.timeAllowed)
        self.index = (start: sectionFromJson.startIndex, end: sectionFromJson.endIndex)
        self.pages = pages
        self.name = sectionFromJson.name
        self.sectionIndex = sectionFromJson.orderInTest
        self.questions = questions
        
        self.sectionTimer = CustomTimer(duration: Int(allotedTime))
    }
    
    init(testSection: TestSection){
        self.allotedTime = testSection.allotedTime
        self.leftOverTime = testSection.allotedTime
        self.index = testSection.index
        self.name = testSection.name
        self.sectionIndex = testSection.sectionIndex
        self.pages = testSection.pages.map {PageModel(page: $0)}
        self.questions = testSection.questions.map {Question(question: $0)}
        self.sectionTimer = CustomTimer(duration: Int(allotedTime))
    }
    
    func reset(){
        leftOverTime = allotedTime
        begunSection = false
        sectionOver = false
        questions.forEach {$0.reset() }
    }
    
}



class Test: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: Test, rhs: Test) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    var id = UUID()
    @Published var currentSectionIndex = 0
    @Published var begunTest = false
    @Published var taken = false
    @Published var showAnswerSheet = true
    @Published var testState: TestState = .notStarted
    var isEraserEnabled = false{
        didSet{
            for section in sections{
                for question in section.questions{
                    question.canvas?.tool = isEraserEnabled ? PKEraserTool(.bitmap) : PKInkingTool(.pen)
                }
                for page in section.pages{
                    page.canvas?.tool = isEraserEnabled ? PKEraserTool(.bitmap) : PKInkingTool(.pen)
                }
            }
        }
    }
    var isFullTest = true
    
    var testJsonFile: String = ""
    var testPDFFile: String = ""
    private var testFromJson: TestFromJson?  //Array Used to initially load the questions into the Test class
    
    
    var testPDFData: NSData?
    
    var pdfImages: [PageModel] = []
    var sections: [TestSection] = []
    var numberOfSections: Int?
    var name: String = ""
    var currentSection: TestSection?
    {
        return sections[currentSectionIndex]
    }
    var performanceData: Data {
        return self.createJsonQuestions()
    }
    var computedData: [[String:(r: Double, w: Double, o: Double)]] {
        return self.computeData()
    }
    
    
    @Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.

    //Create a test from Files on the computer
    init(jsonFile: String, pdfFile: String){
        
        
        self.testJsonFile = jsonFile
        self.testPDFFile = pdfFile
        self.pdfImages = TestPDF(name: pdfFile).pages
        self.testFromJson = self.createTestFromJson(fileName: jsonFile)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!)
        self.numberOfSections = self.sections.count
        self.name = self.testFromJson?.name as! String
     
        

        //self.sendJsonTestPerformanceData()
    }
    //Create a test fromo Data (coming from database mostly)
    init(jsonData: Data, pdfData: Data){
        self.pdfImages = TestPDF(data: pdfData).pages
        self.testFromJson = self.createTestFromJson(data: jsonData)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!)
        self.numberOfSections = self.sections.count
        self.name = self.testFromJson?.name as! String
    }
    
    //Creates a test from a section (or multiple ones) from a test
    init(testSections: [TestSection], test: Test) {
        for testSection in testSections{
            let newSection = TestSection(testSection: testSection)
            self.pdfImages.append(contentsOf: newSection.pages)
            self.questions.append(newSection.questions)
            self.sections.append(newSection)
            self.name = self.name + ": \(newSection.name)"
            
        }
        self.testFromJson = test.testFromJson
        self.numberOfSections = self.sections.count
        self.isFullTest = false
        
    }
    
    //Called when the test has not begun yet
    func startTest(){
        begunTest = true
        nextSection(fromStart: true)
        
    }
    
    //Called onnly if in an intermediaary section is over
    func endSection(){
        currentSection?.sectionOver = true
        testState = .betweenSection
    }
    
    //This is called when the user wants to begin the next section
    //The from start detemrines if we should incriment the currentSectionInndex
    func nextSection(fromStart: Bool){
         //Greater than or equal ensures if there is only one section
        if currentSectionIndex >= numberOfSections! - 2  {
            if fromStart == false {
                currentSectionIndex += 1
            }
            testState = .lastSection
        }else if currentSectionIndex < numberOfSections! - 2{
            if fromStart == false {
                currentSectionIndex += 1
            }
            testState = .inSection
        }
        currentSection?.begunSection = true
    }
    
    //Called when test (or section should be ended)
    func endTest(){
        taken = true
        endSection()
        testState = .testOver
    }
   
    
    func reset() {
        questions.forEach { $0.forEach {$0.reset() } }
        sections.forEach {$0.reset() }
        testState = .notStarted
        currentSectionIndex = 0
        begunTest = false
        taken = false
        showAnswerSheet = true
    }
    
    
    //Initalization Functions
    func createTestFromJson(fileName: String) -> TestFromJson? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do{
                let fileUrl = URL(fileURLWithPath: path)
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                let testFromJson = try decoder.decode(TestFromJson.self, from: data)
                return testFromJson
            }catch {
                print("ERROR loading IN TEST JSON")
                return nil
                //self.testFromJson = nil
            }
        }else{
            print("Failure reading JSON from File")
            return nil
            //self.testFromJson = nil
        }
        return nil
    }
    
    func createTestFromJson(data: Data) -> TestFromJson? {
        do{
            let decoder = JSONDecoder()
            let testFromJson = try decoder.decode(TestFromJson.self, from: data)
            return testFromJson
            //self.testFromJson = testFromJson
        }catch {
            print("Error loading IN Test from DATA")
            return nil
            //self.testFromJson = nil
        }
        return nil
    }
    
    
    func createSectionArray(testFromJson: TestFromJson) -> [TestSection]{
        var sections: [TestSection] = []
        
        for section in testFromJson.sections {
            
            var questionList: [Question] = []
            
            for question in section.questions{
                let splitArray = question.id.split(separator: "_")
                let questionNum = Int(splitArray[2])!
                let tempQuestion = Question(q: question, ip: IndexPath(row: questionNum - 1, section: section.orderInTest), act: testFromJson.act)
                questionList.append(tempQuestion)
            }
            
            let arraySlice = pdfImages[section.startIndex..<section.endIndex-1]

            let tempSection = TestSection(sectionFromJson: section, pages: Array(arraySlice), name: section.name , questions: questionList)
            sections.append(tempSection)
        }
        return sections
    }
    
    
    //Create Data to send from Test
    func computeData() -> [[String:(r: Double, w: Double, o: Double)]] {
        var dataForMathCalculator = [String:(r: Double, w: Double, o: Double)]()
        var dataForReading = [String:(r: Double, w: Double, o: Double)]()
        var dataForWriting = [String:(r: Double, w: Double, o: Double)]()
        var dataForMathNo = [String:(r: Double, w: Double, o: Double)]()
        var data = [dataForReading, dataForWriting, dataForMathNo, dataForMathCalculator]
        
        for (_, section) in self.questions.enumerated() {
            for question in section{
                print(question.currentState)
                print(question.secondsToAnswer)
                switch question.currentState {
                case .right:
                    if question.location.row == 0 {
                        
                    }
                    if data[question.location.section][question.tutorSub] != nil{
                        data[question.location.section][question.tutorSub]?.r+=1
                    }else{
                        data[question.location.section][question.tutorSub] = (r:1, w: 0, o: 0)
                    }
                case .wrong:
                    if data[question.location.section][question.tutorSub] != nil{
                        data[question.location.section][question.tutorSub]?.w+=1
                    }else{
                        data[question.location.section][question.tutorSub] = (r:0, w: 1, o: 0)
                    }
                default:
                    if data[question.location.section][question.tutorSub] != nil{
                        data[question.location.section][question.tutorSub]?.o+=1
                    }else{
                        data[question.location.section][question.tutorSub] = (r:0, w: 0, o: 1)
                    }
                }
            }
        }
        print(data)
        return data
    }
    
    func createJsonQuestions() -> Data {
        let tempData = Data()
        print("creating json file")

        var questionArray: [String : [[String: String]]] = [:]
        for (index, section) in self.questions.enumerated() {
            let indexString = String(index)
            questionArray[indexString] = []
            
            for question in section{
                var tempQuestionDict: [String: String] = [:]
                tempQuestionDict["id"] = question.officialID
                tempQuestionDict["officialSub"] = question.officialSub
                tempQuestionDict["answer"] = question.answer
                tempQuestionDict["reason"] = question.reason
                tempQuestionDict["currentState"] = question.currentState.rawValue
                tempQuestionDict["secondsToAnswer"] = String(question.secondsToAnswer)
                tempQuestionDict["row"] = String(question.location.row)
                tempQuestionDict["section"] = String(question.location.section)
                
                questionArray[indexString]?.append(tempQuestionDict)
            }
        }
        print(questionArray)
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return tempData }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("refl.json")
        do {
            let data = try JSONSerialization.data(withJSONObject: questionArray, options: [])
            try data.write(to: fileUrl, options: [])
            print("SUCCSESS CREATING JSON ARRAY")
            print(data)
            return data
        } catch {
            print("ERROR CREATING JSON ARRAY")
            print(error)
            return tempData
        }

    }
    
    func sendJsonTestPerformanceData() {
        let uploadRef = Storage.storage().reference(withPath: "performanceJSONS/cb1takenTestExample.json")
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "application/json"

        uploadRef.putData(performanceData, metadata: uploadMetadata){ (downloadMetadata, error) in
            if let error = error {
                print("Error uploading JSON data \(error.localizedDescription)")
                return
            }
            print("Upload of JSON Success: \(String(describing: downloadMetadata))")

        }
        
    }
    
}

enum TestState{
    case notStarted
    case inSection
    case betweenSection
    case lastSection
    case testOver
}


//Reading a Test JSON IN
struct TestFromJson: Codable {
    var numberOfSections: Int
    var act: Bool
    var name: String
    var sections: [TestSectionFromJson]
    var answerConverter: [ScoreConverter]
}

struct TestSectionFromJson: Codable {
    var name: String
    var timeAllowed: Int
    var startIndex: Int
    var endIndex: Int
    var orderInTest: Int
    var questions: [QuestionFromJson]
}

struct ScoreConverter: Codable {
    var rawScore: Int
    var readingSectionTestScore: Int
    var mathSectionTestScore: Int
    var writingAndLanguageTestScore: Int
    var scienceTestScore: Int
}

struct QuestionFromJson: Codable{
    let id: String
    let officialSub: String
    let tutorSub: String
    let answer: String
    let reason: String
    
    init(id: String, officialSub: String, tutorSub: String, answer: String, reason: String) {
        self.id = id
        self.officialSub = officialSub
        self.tutorSub = tutorSub
        self.answer = answer
        self.reason = answer
    }
}

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

class TestSection: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: TestSection, rhs: TestSection) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    @Published var leftOverTime: Double
    @Published var sectionOver = false{
        didSet{
            if sectionOver == true{
                sectionTimer.endTimer()
                self.leftOverTime = sectionTimer.timeRemaining
                print("Section OVER")
            }
        }
    }
    @Published var begunSection = false{
        didSet{
            if begunSection == true{
                sectionTimer.startTimer()
            }
        }
    }
    
    var id = UUID()
    var allotedTime: Double
    var sectionTimer: CustomTimer
    
    var rawScore: Int{
        var score = 0
        for question in questions {
            if question.currentState == .right{
                score += 1
            }
        }
        return score
    }
    var scaledScore:Int? //Only has a value after a test is taken
    
    
    
    
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
    
    func makeTestSectionForJson() -> TestSectionFromJson{
        var questionsForJson = [QuestionFromJson]()
        for question in self.questions{
            question.checkAnswer()
            let temp = QuestionFromJson(id: question.officialID,
                                        officialSub: question.officialSub, tutorSub: question.tutorSub,
                                        answer: question.answer, reason: question.reason,
                                        studentAnswer: question.userAnswer, secondsToAnswer: Int(question.secondsToAnswer),
                                        finalState: question.finalState.rawValue) //TODO: Missing order in test
            
            questionsForJson.append(temp)
        }
        //This is a var because we will be giving it a scaled score
        let sectionForJson = TestSectionFromJson(name: self.name,
                                                 timeAllowed:  Int(self.allotedTime), startIndex: self.index.start,
                                                 endIndex: self.index.end, orderInTest: self.sectionIndex,
                                                 questions: questionsForJson, rawScore: self.rawScore,
                                                 timeLeft: Int(self.leftOverTime), scaledScore: self.scaledScore!)
        
        return sectionForJson
    }
    
    func setScaledScore(test: Test){
        //ACT
        if name == "English"{
            scaledScore = test.scoreConvertDict[rawScore]?.writingAndLanguageTestScore
        }else if name == "Science"{
            scaledScore = test.scoreConvertDict[rawScore]?.scienceTestScore
        }else if name == "Math"{
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else if name == "Reading"{
            scaledScore = test.scoreConvertDict[rawScore]?.readingSectionTestScore
        }else{
            //TODO: SAT
            
        }
        
    }
    
    func reset(){
        leftOverTime = allotedTime
        begunSection = false
        sectionOver = false
        questions.forEach {$0.reset() }
    }
    
    
    
}



class Test: ObservableObject, Hashable, Identifiable {
    
    //Conform to protocal helpers
    static func == (lhs: Test, rhs: Test) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    var id = UUID()
    
    //Variables used in UI
    @Published var currentSectionIndex = 0
    var currentSection: TestSection?{
        return sections[currentSectionIndex]
    }
    @Published var begunTest = false
    @Published var taken = false
    @Published var showAnswerSheet = true
    @Published var testState: TestState = .notStarted
    @Published var isEraserEnabled = false{
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
    var name: String = ""
    
    //Model Variables
    var isFullTest = true
    var testJsonFile: String = ""
    var testPDFFile: String = ""
    var testPDFData: NSData?
    var pdfImages: [PageModel] = []
    var sections: [TestSection] = []
    var numberOfSections: Int?
    var act: Bool?
    private var testFromJson: TestFromJson?  //Array Used to initially load the questions into the Test class
    
    //Data about a test (probably just taken)
    var resultJson: Data{
        return self.createResultJson()
    }
    var computedData: [[String:(r: Double, w: Double, o: Double)]] {
        return self.computeData()
    }
    var overallScore: Int{
        if act == true{
            var sum = 0
            for section in sections{
                sum += section.scaledScore!
            }
            return sum / numberOfSections!
        }else{
            
            //TODO: SAT
            return 0
        }
    }
    var mathScore: Int?{
        //TODO: SAT
        return nil
    }
    
    var scienceScore: Int?{
        //TODO: SAT
        return nil
    }
    
    var scoreConvertDict = [Int: (readingSectionTestScore: Int, mathSectionTestScore: Int, writingAndLanguageTestScore: Int, scienceTestScore: Int)]()
    
    
    @Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.

    //Create a test from Files on the computer
    init(jsonFile: String, pdfFile: String){
        
        
        self.testJsonFile = jsonFile
        self.testPDFFile = pdfFile
        self.pdfImages = TestPDF(name: pdfFile).pages
        self.testFromJson = self.createTestFromJson(fileName: jsonFile)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.act = self.testFromJson?.act
            self.name = self.testFromJson!.name
            for convertEach in testFromJson!.answerConverter! {
                scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore)
            }
        }
                
        
     
        

        //self.sendJsonTestPerformanceData()
    }
    //Create a test fromo Data (coming from database mostly)
    init(jsonData: Data, pdfData: Data){
        self.pdfImages = TestPDF(data: pdfData).pages
        self.testFromJson = self.createTestFromJson(data: jsonData)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.act = self.testFromJson?.act
            self.name = self.testFromJson!.name
            for convertEach in testFromJson!.answerConverter! {
                scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore)
            }
        }
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
        self.act = test.act
        self.testFromJson = test.testFromJson
        self.numberOfSections = self.sections.count
        self.isFullTest = false
        self.scoreConvertDict = test.scoreConvertDict
        
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
        sendResultJson()
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
            }
        }else{
            print("Failure reading JSON from File")
            return nil
        }
        return nil
    }
    
    func createTestFromJson(data: Data) -> TestFromJson? {
        do{
            let decoder = JSONDecoder()
            let testFromJson = try decoder.decode(TestFromJson.self, from: data)
            return testFromJson
        }catch {
            print("Error loading IN Test from DATA")
            return nil
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
    
    func createResultJson() -> Data {
        //Creating encodable object from test
        var sectionsForJson = [TestSectionFromJson]()
        for section in sections {
            section.setScaledScore(test: self)
            let temp = section.makeTestSectionForJson()
            sectionsForJson.append(temp)
        }
        //Todo: SAT
        let testForJson = TestFromJson(numberOfSections: self.numberOfSections!, act: self.act!, name: self.name, sections: sectionsForJson, overallScore: overallScore, math: mathScore, science: scienceScore)
        //Encoding information
        let encoder = JSONEncoder()
        do{
            let tempData = try encoder.encode(testForJson)
            return tempData
            
        } catch let error {
            print("ERROR CREATING RESULT JSON: \(error)")
        }
        print("ERROR in crj")
        return Data() //ERROR
    }
    
    
    
    func sendResultJson() {
        let uploadRef = Storage.storage().reference(withPath: "performanceJSONS/newResultData.json")
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "application/json"

        uploadRef.putData(resultJson, metadata: uploadMetadata){ (downloadMetadata, error) in
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
    
    //Values only in template json
    var answerConverter: [ScoreConverter]?
    
    //Values only in the test result JSON
    var overallScore: Int? //SAT and ACT
    var math: Int? //SAT
    var science: Int? //SAT
    
}

struct TestSectionFromJson: Codable {
    var name: String
    var timeAllowed: Int
    var startIndex: Int
    var endIndex: Int
    var orderInTest: Int
    var questions: [QuestionFromJson]
    
    //Values only in the test result JSON
    var rawScore: Int?
    var timeLeft: Int?
    
    //Only ACT (scale scores for SAT will at the top level bc only 2 subscores are reported)
    var scaledScore: Int?
    
}

struct QuestionFromJson: Codable{
    var id: String
    var officialSub: String
    var tutorSub: String
    var answer: String
    var reason: String
    
    //Values only in the test result JSON
    var studentAnswer: String?
    var secondsToAnswer: Int?
    var finalState: String? //"R" for right, "W" for wrong, "O" for ommited
    var orderAnsweredInSection: Int?
}


struct ScoreConverter: Codable {
    var rawScore: Int
    var readingSectionTestScore: Int
    var mathSectionTestScore: Int
    var writingAndLanguageTestScore: Int
    var scienceTestScore: Int
}





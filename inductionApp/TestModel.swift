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

struct PageModel: Hashable {
    var uiImage: UIImage
    var id: Int
}

class TestPDF {
    var pages = [PageModel]()
    var pdfName = ""
    
    init(name: String){
        self.pdfName = name
        self.createPages(name: name)
    }
    init(data: Data){
        self.createPages(data: data)
    }
    
    func createPages(name: String){
        var pageCounter = 1
        let path = Bundle.main.path(forResource: name, ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        if let document = CGPDFDocument(url as CFURL) {
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                pages.append(PageModel(uiImage: pdfImage, id: pageCounter - 1))
                pageCounter = pageCounter + 1
//                if (pageCounter > 5){ //Get rid of this. Figure out why the PDF file is corrupted
//                    break
//                }
            }
        }
    }
    
    func createPages(data: Data){
        var pageCounter = 1
        let dataProvider = CGDataProvider(data: data as CFData)
        if let document = CGPDFDocument(dataProvider!){
            while let pdfImage = createUIImage(document: document, page: pageCounter){
                pages.append(PageModel(uiImage: pdfImage, id: pageCounter - 1))
                pageCounter = pageCounter + 1
            }
        }
    }
    
    private func createUIImage(document: CGPDFDocument, page: Int) -> UIImage?{
        
        guard let page = document.page(at: page) else {return nil}


        let pageRect = page.getBoxRect(.mediaBox) //Media box
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image{ ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y : -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
        return img
        
    }
    
    
    
}

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
    var begunSection = false
    var sectionOver = false
    var sectionTimer: SectionTimer
    
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
        
        self.sectionTimer = SectionTimer(duration: Int(allotedTime))
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
    var testJsonFile: String = ""
    var testPDFFile: String = ""
    private var testFromJson: TestFromJson?  //Array Used to initially load the questions into the Test class
    @Published var showAnswerSheet = true
    
    
    var testPDFData: NSData?
    
    var pdfImages: [PageModel]
    var sections: [TestSection] = []
    var name: String?
    var currentSection: TestSection{
        return sections[currentSectionIndex]
    }
    var performanceData: Data {
        return self.createJsonQuestions()
    }
    var computedData: [[String:(r: Double, w: Double, o: Double)]] {
        return self.computeData()
    }
    
    
    @Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.

    
    init(jsonFile: String, pdfFile: String){
        
        
        self.testJsonFile = jsonFile
        self.testPDFFile = pdfFile
        self.pdfImages = TestPDF(name: pdfFile).pages
        self.readJsonFile(fileName: jsonFile) //TODO: Make sure this is optional
        self.createTestData(testFromJson: self.testFromJson!)
        self.name = self.testFromJson?.name

        //self.sendJsonTestPerformanceData()
    }
    
    init(jsonData: Data, pdfData: Data){
        self.pdfImages = TestPDF(data: pdfData).pages
        self.readJsonFile(data: jsonData)
        self.createTestData(testFromJson: self.testFromJson!)
        self.name = self.testFromJson?.name
    }
    
    //Creates a test from a section
    init(testSection: TestSection, test: Test) {
        self.sections = [testSection]
        self.name = testSection.name
        self.pdfImages = testSection.pages
        self.questions = [testSection.questions]
    }
    

    func readJsonFile(fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json"){
            do{
                let fileUrl = URL(fileURLWithPath: path)
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                let testFromJson = try decoder.decode(TestFromJson.self, from: data)
                self.testFromJson = testFromJson
            }catch {
                print("ERROR loading IN TEST JSON")
                self.testFromJson = nil
            }
        }else{
            print("Failure reading JSON from File")
            self.testFromJson = nil
        }
    }
    
    func readJsonFile(data: Data) {
        do{
            let decoder = JSONDecoder()
            let testFromJson = try decoder.decode(TestFromJson.self, from: data)
            self.testFromJson = testFromJson
        }catch {
            print("Error loading IN Test from DATA")
            self.testFromJson = nil
        }
            
    }
    
    
    func createTestData(testFromJson: TestFromJson){
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
        self.sections = sections
    }
    
    
    
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
    
    func reset() {
        questions.forEach { $0.forEach {$0.reset() } }
    }
}

class SectionTimer: ObservableObject {
    private var endDate: Date?
    private var timer: Timer?
    var timeRemaining: Double {
        didSet {
            self.setRemaining()
        }
    }
    @Published var timeLeftFormatted = ""
    
    init(duration: Int) {
        self.timeRemaining = Double(duration)
        //self.startTimer()

    }
    

    func startTimer() {
        self.endDate = Date().advanced(by: Double(self.timeRemaining))
        
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer(timeInterval: 0.2, repeats: true) { (timer) in
            self.timeRemaining = self.endDate!.timeIntervalSince(Date())
            if self.timeRemaining < 0 {
                timer.invalidate()
                self.timer = nil
            }
        }
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    private func setRemaining() {
        let min = max(floor(self.timeRemaining / 60),0)
        let sec = max(floor((self.timeRemaining - min*60).truncatingRemainder(dividingBy:60)),0)
        self.timeLeftFormatted = "\(Int(min)):\(Int(sec))"
       // print(self.timeLeftFormatted)
        
    }

    func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}





class Question: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    var id = UUID()
    let officialID: String
    let officialSub: String
    let tutorSub: String
    let answer: String
    let reason: String
    let location: IndexPath
    let isACT: Bool
    var answerLetters = ["A", "B", "C", "D"]
    
    @Published var userAnswer = ""
    @Published var currentState = CurrentState.ommited
    @Published var secondsToAnswer = 0.0
    @Published var canvas: PKCanvasView?
    
    init(q: QuestionFromJson, ip: IndexPath, act: Bool) {
        self.officialID = q.id
        self.officialSub = q.officialSub
        self.tutorSub = q.tutorSub
        self.answer = q.answer
        self.reason = q.reason
        self.isACT = act
        self.location = ip
        
        if isACT && (ip.row + 1) % 2 == 1 {
            self.answerLetters = ["A", "B", "C", "D"]
        }else if isACT {
            self.answerLetters = ["F", "G", "H", "J"]
        }
      
    }
    
    func checkAnswer() {
        if (currentState == .invalidSelection || currentState == .ommited) {return}
        else if (userAnswer == answer) {
            currentState = .right
        }else{
            currentState = .wrong
        }
    
    }
    
    func reset() {
        self.userAnswer = ""
        self.currentState = .ommited
        self.secondsToAnswer = 0.0
    }
    
}


enum CurrentState : String{
    //Used when checking the answer and creating data
    case right = "R" //Right
    case wrong = "W" //Wrong
    case ommited = "O" //Ommited
    case invalidSelection = "I" //Invalid Selection
    
    //Used when still in test
    ///.ommited = "O" is used here too
    case selected = "S" //Selected
}


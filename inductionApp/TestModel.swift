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
    

    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    var id = UUID()
    
    
    @Published var sectionOver = false{
        didSet{
            if sectionOver == true{
                sectionTimer.endTimer()
                self.leftOverTime = sectionTimer.timeRemaining
                breakTimer.startTimer()
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
    
    
    var allotedTime: Double
    @Published var sectionTimer: CustomTimer
    @Published var leftOverTime: Double
    
    @Published var breakTimer: CustomTimer
    
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
    
    
    
    var inkingTool: PKInkingTool //= PKInkingTool(.pen, color: .black, width: 1)
    var eraserTool: PKEraserTool = PKEraserTool(.bitmap)
    var name: String
    var sectionIndex: Int
    var index: (start: Int, end: Int) //Index of pages in the pdf
    var pages = [PageModel]()
    var questions = [Question]()
    //Number of questions the student has answered in the section
    var numAnsweredQuestions = 0
    var timed: Bool?
    
    init(sectionFromJson: TestSectionFromJson, pages: [PageModel] = [PageModel](), name: String, questions: [Question], inkingTool: PKInkingTool) {
        self.allotedTime = Double(sectionFromJson.timeAllowed)
        self.leftOverTime = Double(sectionFromJson.timeAllowed)
        self.index = (start: sectionFromJson.startIndex, end: sectionFromJson.endIndex)
        self.pages = pages
        self.name = sectionFromJson.name
        self.sectionIndex = sectionFromJson.orderInTest
        self.questions = questions
        self.sectionTimer = CustomTimer(duration: Int(allotedTime))
        self.timed = sectionFromJson.timed
        self.scaledScore = sectionFromJson.scaledScore
        self.sectionTimer = CustomTimer(duration: Int(allotedTime))
        self.inkingTool = inkingTool
        
        if self.name == "Math"{
            self.breakTimer = CustomTimer(duration: 600)
        }else{
            self.breakTimer = CustomTimer(duration: 0)
        }
        
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
        self.timed = testSection.timed
        self.inkingTool = testSection.inkingTool
        if self.name == "Math"{
            self.breakTimer = CustomTimer(duration: 600)
        }else{
            self.breakTimer = CustomTimer(duration: 0)
        }
        
        
    }

    
    //scale up: bool
    func scalePages(){
       
        for page in pages{
            page.shouldScale = true
            
        }
    }
    
    func makeTestSectionForJson() -> TestSectionFromJson{
        print("MAKING TEST SECTION FOR JSON")
        var questionsForJson = [QuestionFromJson]()
        for question in self.questions{
            question.checkAnswer()
            print(question.finalState.rawValue)
            print(question.currentState)
            print(question.finalState)
            let temp = QuestionFromJson(id: question.officialID,
                                        officialSub: question.officialSub, tutorSub: question.tutorSub,
                                        answer: question.answer, reason: question.reason,
                                        studentAnswer: question.userAnswer, secondsToAnswer: Int(question.secondsToAnswer),
                                        finalState: question.finalState.rawValue, orderAnsweredInSection: question.answerOrdredIn) //TODO: Missing order in test
            
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
        if name == "English" && test.act == true{
            scaledScore = test.scoreConvertDict[rawScore]?.writingAndLanguageTestScore
        }else if name == "Science" && test.act == true{
            scaledScore = test.scoreConvertDict[rawScore]?.scienceTestScore
        }else if name == "Math" && test.act == true{
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else if name == "Reading" && test.act == true{
            scaledScore = test.scoreConvertDict[rawScore]?.readingSectionTestScore
        //SAT
        }else if name == "Reading" && test.act == false{
            scaledScore = test.scoreConvertDict[rawScore]?.readingSectionTestScore
        }else if name == "Writing" && test.act == false{
            scaledScore = test.scoreConvertDict[rawScore]?.writingAndLanguageTestScore
        }else if name == "Math No Calculator" && test.act == false{
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else if name == "Math Calculator" && test.act == false{
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else{
            print("ERROR PRONE MESSAGE")
            fatalError("ERRROR")
        }
        
    }
    
    func reset(){
        self.leftOverTime = allotedTime
        
        if self.name == "Math"{
            self.breakTimer = CustomTimer(duration: 600)
        }else{
            self.breakTimer = CustomTimer(duration: 0)
        }
        self.sectionTimer = CustomTimer(duration: Int(self.leftOverTime))
    
        begunSection = false
        sectionOver = false
        pages.forEach {$0.reset()}
        questions.forEach {$0.reset() }
        
    }
    
    
}



class Test: ObservableObject, Hashable, Identifiable {
    
    //Conform to protocal helpers
    static func == (lhs: Test, rhs: Test) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
  
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    var id = UUID()
    var db = Firestore.firestore() //Instance of database
    
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
                    question.canvas?.tool =  isEraserEnabled ? section.eraserTool : section.inkingTool
                    //question.canvas?.__tool = isEraserEnabled ? PKEraserToolReference(eraserType: PKEraserTool(.bitmap)) : MyInkingTool(inkType: .pen, color: .black) //TODO: CHange width of pencil
                }
                for page in section.pages{
                    page.canvas?.tool = isEraserEnabled ? section.eraserTool : section.inkingTool
                    //page.canvas?.__tool = isEraserEnabled ? PKEraserToolReference(eraserType: PKEraserTool(.bitmap)) : MyInkingTool(inkType: .pen, color: .black)
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
    var testFromJson: TestFromJson?  //Array Used to initially load the questions into the Test class
    var dateTaken: Date?
    var timed: Bool = true

    
    
    
    
    
    
    //Data about a test (probably just taken)
    var resultJson: Data{
        return self.createResultJson()
    }
    
    var overallScore: Int{
        if act == true{
            var sum = 0
            for section in sections{
                sum += section.scaledScore!
            }
            return sum / numberOfSections!
        }else{
            if let mScore = mathScore, let
                eScore = englishScore {
                return mScore + eScore
            }else{
                return 0
            }
        }
    }
    var mathScore: Int? = nil
    
    var englishScore: Int? = nil
    
    var scoreConvertDict = [Int: (readingSectionTestScore: Int, mathSectionTestScore: Int, writingAndLanguageTestScore: Int, scienceTestScore: Int)]()
    
    
    //@Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.

    //Create a test from Files on the computer
    init(jsonFile: String, pdfFile: String){
        
        
        self.testJsonFile = jsonFile
        self.testPDFFile = pdfFile
        self.pdfImages = TestPDF(name: pdfFile).pages
        self.testFromJson = self.createTestFromJson(fileName: jsonFile)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: false)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.act = self.testFromJson?.act
            self.name = self.testFromJson!.name
            for convertEach in testFromJson!.answerConverter! {
                scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
            }
        }
                


        //self.sendJsonTestPerformanceData()
    }
    //Create a test fromo Data (coming from database mostly)
    init(jsonData: Data, pdfData: Data){
        self.pdfImages = TestPDF(data: pdfData).pages
        
        self.testFromJson = self.createTestFromJson(data: jsonData)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: false)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.act = self.testFromJson?.act
            self.name = self.testFromJson!.name
            for convertEach in testFromJson!.answerConverter! {
                scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
            }
        }
        print("donne: \(self.name)")
    }
    
    //Create Test from performacne JSONS
    init(jsonData: Data){
        self.pdfImages = TestPDF(name: "1-ACT Exam 1904S").pages
        self.testFromJson = self.createTestFromJson(data: jsonData)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: true)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.act = self.testFromJson?.act
            self.name = self.testFromJson!.name
            self.englishScore = self.testFromJson?.english
            self.mathScore = self.testFromJson?.math
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date = dateFormatter.date(from: (self.testFromJson?.dateTaken)!)
            self.dateTaken = date
        }
        
        print("Loaded in Performance Data: \(self.testFromJson?.dateTaken! ?? "No Time")")
        
        //self.dateTaken = self.testFromJson?.dateTaken
        
        
    }
    
    //Creates a test from a section (or multiple ones) from a test
    init(testSections: [TestSection], test: Test) {
        self.timed = false
        for testSection in testSections{
            let newSection = TestSection(testSection: testSection)
            self.pdfImages.append(contentsOf: newSection.pages)
            //self.questions.append(newSection.questions)
            self.sections.append(newSection)
            self.name = self.name + ": \(newSection.name). Timed: \(self.timed)"
            
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
    
    //Called at the end of a section
    func endSection(user: User){
        
        isEraserEnabled = false
        currentSection?.sectionOver = true
        
        if currentSectionIndex == numberOfSections! - 1 {
            //Test is over
            testState = .testOver
            sendResultJson(user: user)
            taken = true
            self.reset()
        }else if currentSection!.breakTimer.timeRemaining != 0{
            testState = .inBreak
        }else{
            self.nextSection(fromStart: false)
        }
    }
    
    //This will only be called if the
    //user wants to leave the test early and not come back.
    func endTest(user: User){
        isEraserEnabled = false
        currentSection?.sectionOver = true
        testState = .testOver
        sendResultJson(user: user)
        taken = true
        print("ENDED")
        //self.saveWriting()
        self.reset()
    }
    
//    func saveWriting(){
//
//        let section1 = self.sections[0]
//        for page in section1.pages{
//            print("Inside Page loop")
//            if let data = page.canvas?.drawing.dataRepresentation(){
//                print("Inside if Let ")
//                let filename = getDocumentsDirectory().appendingPathComponent("drawingData\(page.pageID).png")
//                try? data.write(to: filename)
//                print("after try")
//            }
//        }
//    }
    
    //This is called when the user wants to begin the next section
    //The from start detemrines if we should incriment the currentSectionInndex
    func nextSection(fromStart: Bool){
         //Greater than or equal ensures if there is only one section
        if fromStart == false{
            currentSection?.questions.forEach{$0.canvas = nil}
            currentSection?.pages.forEach{$0.canvas = nil}
        }
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
    
    
    func reset() {
        //questions.forEach { $0.forEach {$0.reset() } }
        
        testState = .notStarted
        currentSectionIndex = 0
        begunTest = false
        taken = false
        showAnswerSheet = true
        sections.forEach {$0.reset() }
        englishScore = nil
        mathScore = nil
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
    }
    
    func createTestFromJson(data: Data) -> TestFromJson? {

        do{
            let decoder = JSONDecoder()
            let testFromJson = try decoder.decode(TestFromJson.self, from: data)
            return testFromJson
        }catch{
            print("Error loading IN Test from DATA")
            return nil
        }
    }
    
    
    func createSectionArray(testFromJson: TestFromJson, corrections: Bool) -> [TestSection]{
        var sections: [TestSection] = []
        for section in testFromJson.sections {
            
            var questionList: [Question] = []
            
            for question in section.questions{
                let splitArray = question.id.split(separator: "_")
                let questionNum = Int(splitArray[2])!
                let tempQuestion = Question(q: question, ip: IndexPath(row: questionNum - 1, section: section.orderInTest), act: testFromJson.act, isActMath: section.name == "Math" && testFromJson.act == true)
                print("CHECKING THE QUESTION FINAL STATE")
                print(tempQuestion.finalState)
                questionList.append(tempQuestion)
            }
                let arraySlice = pdfImages[section.startIndex..<section.endIndex-1]
                
            let tempSection = TestSection(sectionFromJson: section, pages: Array(arraySlice), name: section.name , questions: questionList, inkingTool: corrections ? PKInkingTool(.pen, color: .red, width: 1) : PKInkingTool(.pen, color: .black, width: 1))
                sections.append(tempSection)
            
            
        }
        return sections
    }
    

    
    func createResultJson() -> Data {
        //Creating encodable object from test
        var sectionsForJson = [TestSectionFromJson]()
        
        for section in sections {
            section.setScaledScore(test: self)
            if section.name == "Reading" || section.name == "Writing"{
                englishScore = englishScore ?? 0 + section.scaledScore!
            }else if section.name == "Math No Calculator" || section.name == "Math Calculator" {
                mathScore = mathScore ?? 0 + section.rawScore
            }
            let temp = section.makeTestSectionForJson()
            sectionsForJson.append(temp)
        }
        
        if englishScore != nil{
            englishScore = englishScore! * 10
        }
        
        if mathScore != nil{
            mathScore = self.scoreConvertDict[mathScore!]?.mathSectionTestScore
        }
        
        let testForJson = TestFromJson(numberOfSections: self.numberOfSections!, act: self.act!, name: self.name, sections: sectionsForJson, overallScore: overallScore, math: mathScore, english: englishScore, dateTaken: Date().toString(dateFormat: "MM-dd-yyyy"))
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
    
    
    
    func sendResultJson(user: User) {
        //Name of result: NameOfTest-UserID-Currentdate
        let nameOfFile = "\(name)-\(user.id)-\(Date().toString(dateFormat: "MM-dd-yyyy"))"
        let uploadRef = Storage.storage().reference(withPath:
            "\(user.association.associationID)/\(self.isFullTest == true ? "test" : "section")Results/\(nameOfFile).json")
        
        if self.isFullTest == true {
            user.testResultRefs.append(nameOfFile)
            self.db.collection("users").document(user.id).updateData([
                "testResultRefs" : user.testResultRefs
            ]){error in
                if let error = error {
                    user.testResultRefs.removeLast() 
                    print("Error updating document: \(error)")
                }else{
                    
                    print("Document successfully updated")
                }
            }
        }else{
            user.studyResultRefs.append(uploadRef.fullPath)
            self.db.collection("users").document(user.id).updateData([
                "studyResultRefs" : user.studyResultRefs
            ]){error in
                if let error = error {
                    user.testResultRefs.removeLast()
                    print("Error updating document: \(error)")
                }else{
                    print("Document successfully updated")
                }
            }
        }
        
        
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "application/json"
        let finalResultJson = resultJson
        uploadRef.putData(finalResultJson, metadata: uploadMetadata){ (downloadMetadata, error) in
            if let error = error {
                print("Error uploading JSON data \(error.localizedDescription)")
                return
            }
            print("Upload of JSON Success: \(String(describing: downloadMetadata))")

        }
        
        do{
          print("Writing performance document to file manager")
            let jsonURL = self.getDocumentsDirectory().appendingPathComponent("\(nameOfFile).json")
          try finalResultJson.write(to: jsonURL)
            
           print("Success Writing Document to file manager")
        }catch{
            print("ERROR Sending result json to local Storage")
        }
        
        user.getPerformanceDataComplete = false
        
        DispatchQueue.global(qos: .utility).async { //TODO: Make  functions to get rid of duplicate code
            print("START ASYNC ADDING TEST")
            
            let tempTest = self.getTempTest(finalResultJson: finalResultJson, user: user)
            
            
            DispatchQueue.main.async {
                print("START MAIN ADDING TEST")
                if self.act == true{
                    if user.allACTPerformanceData == nil{
                        print("ACT IS NIL")
                        print(user.allACTPerformanceData?.allTestData)
                        user.allACTPerformanceData = AllACTData(tests: [tempTest], isACT: false)
                        user.getPerformanceDataComplete = true
                    }else{
                        print("ACT IS NOT NIL")
                        print(user.allACTPerformanceData?.allTestData)
                        user.allACTPerformanceData!.addTest(test: tempTest , user: user)
                    }
                }else{
                    if user.allSATPerformanceData == nil{
                        user.allSATPerformanceData = AllACTData(tests: [tempTest], isACT: false)
                        user.getPerformanceDataComplete = true
                    }else{
                        user.allSATPerformanceData!.addTest(test: tempTest , user: user)
                    }
                }
            }
        }
    }
    
    func getTempTest(finalResultJson: Data, user: User) -> ACTFormatedTestData{
        if self.act == true{
            let tempTest = ACTFormatedTestData(data: finalResultJson, index: (user.allACTPerformanceData?.allTestData?.count) ?? 0, tutorPDFName: "BreiteJ-CB1")
            tempTest.createData(index: (user.allACTPerformanceData?.allTestData?.count) ?? 0)
            return tempTest
        }else{
            let tempTest = ACTFormatedTestData(data: finalResultJson, index: (user.allSATPerformanceData?.allTestData?.count) ?? 0, tutorPDFName: "BreiteJ-CB1")
            tempTest.createData(index: (user.allSATPerformanceData?.allTestData?.count) ?? 0)
            return tempTest
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

enum TestState{
    case notStarted
    case inSection
    case inBreak
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
    var english: Int? //SAT
    var dateTaken: String?
    
}

struct TestSectionFromJson: Codable {
    var name: String
    var timeAllowed: Int
    var startIndex: Int
    var endIndex: Int
    var orderInTest: Int
    var questions: [QuestionFromJson]
    var timed: Bool?
    
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
    var finalState: String? //"R" for right, "W" for wrong, "O" for omitted
    var orderAnsweredInSection: Int?
}


struct ScoreConverter: Codable {
    var rawScore: Int
    var readingSectionTestScore: Int
    var mathSectionTestScore: Int
    var writingAndLanguageTestScore: Int
    var scienceTestScore: Int?
    
    
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}





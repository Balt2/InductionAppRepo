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
    
    
    init(sectionFromJson: TestSectionFromJson, pages: [PageModel] = [PageModel](), name: String, questions: [Question], inkingTool: PKInkingTool, testType: TestType) {
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
        }else if self.name == "Reading" && testType == .sat  { //3900 corresponeds to the sat time for reading section (sectionFromJson.timeAllowed == 3900 || sectionFromJson.timeAllowed == 3600 || sectionFromJ)
            self.breakTimer = CustomTimer(duration: 600)
        }else if self.name == "Math No Calculator"{
            self.breakTimer = CustomTimer(duration: 300)
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
    
    func makeTestSectionForJson(test: Test) -> TestSectionFromJson{
        print("MAKING TEST SECTION FOR JSON")
        var questionsForJson = [QuestionFromJson]()
        for question in self.questions{
            question.checkAnswer()
            let temp = QuestionFromJson(id: question.officialID,
                                        officialSub: question.officialSub, tutorSub: question.tutorSub,
                                        answer: question.answer, reason: question.reason,
                                        studentAnswer: question.userAnswer, secondsToAnswer: Int(question.secondsToAnswer),
                                        finalState: question.finalState.rawValue, orderAnsweredInSection: question.answerOrdredIn) //TODO: Missing order in test
            
            questionsForJson.append(temp)
        }
        self.setScaledScore(test: test)
        //This is a var because we will be giving it a scaled score
        let sectionForJson = TestSectionFromJson(name: self.name,
                                                 timeAllowed:  Int(self.allotedTime), startIndex: self.index.start,
                                                 endIndex: self.index.end, orderInTest: self.sectionIndex,
                                                 questions: questionsForJson, rawScore: self.rawScore,
                                                 timeLeft: Int(self.leftOverTime), scaledScore: self.scaledScore)
        
        return sectionForJson
    }
    
    func setScaledScore(test: Test){
        //ACT
        if name == "English" && test.testType == .act{
            print("RAW SCORE ENGLISH ACT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.readingSectionTestScore
        }else if name == "Science" && test.testType == .act{
            print("RAW SCORE SCIENCE ACT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.scienceTestScore
        }else if name == "Math" && test.testType == .act{
            print("RAW SCORE MATH ACT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else if name == "Reading" && test.testType == .act{
            print("RAW SCORE READING ACT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.writingAndLanguageTestScore
        //SAT
        }else if name == "Reading" && test.testType == .sat || test.testType == .psat{
            print("RAW SCORE READING SAT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.readingSectionTestScore
        }else if name == "Writing" && test.testType == .sat || test.testType == .psat{
            print("RAW SCORE WRITING SAT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.writingAndLanguageTestScore
        }else if name == "Math No Calculator" && test.testType == .sat || test.testType == .psat{
            print("RAW SCORE MATH NO CALCULATOR SAT: \(rawScore)")
            
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else if name == "Math Calculator" && test.testType == .sat || test.testType == .psat{
            print("RAW MATH CALCULATOR SAT: \(rawScore)")
            scaledScore = test.scoreConvertDict[rawScore]?.mathSectionTestScore
        }else{
            print(name)
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
    @Published var loadedPDFIn = false
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
    var testType: TestType?
    var testFromJson: TestFromJson?  //Array Used to initially load the questions into the Test class
    var dateTaken: Date?
    var timed: Bool = true
    var preTestMindset: MindsetSurveyModel?
    var postTestMindset: MindsetSurveyModel?
    
    
    
    
    
    
    //Data about a test (probably just taken)
    var resultJson: Data{
        return self.createResultJson()
    }
    
    var overallScore: Int{
        if testType == .act{
            var sum = 0
            for section in sections{
                sum += section.scaledScore!
            }
            return sum / numberOfSections!
        }else if testType == .sat || testType == .psat{
            return englishScore + mathScore
        }else{
            return 0
        }
    }
    var mathScore = 0
    
    var englishScore = 0
    
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
            self.testType = TestType(rawValue: self.testFromJson!.testType)
            self.name = self.testFromJson!.name
            for convertEach in testFromJson!.answerConverter! {
                scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
            }
        }
                


        //self.sendJsonTestPerformanceData()
    }
    //Create a test fromo Data (coming from database mostly)
    init(jsonData: Data, pdfData: Data, corrections: Bool){
        

        self.testFromJson = self.createTestFromJson(data: jsonData)
        if self.testFromJson != nil{
            self.pdfImages = TestPDF(data: pdfData, testRef: self.testFromJson!.testRefName).pages
            self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: corrections)
            self.numberOfSections = self.sections.count
            self.testType = TestType(rawValue: self.testFromJson!.testType)!
            self.name = self.testFromJson!.name
            if corrections == true{
                print("CREATING CORRECTIONS: ACT: \(self.testType?.rawValue)")
                if self.testType == .sat{
                    self.englishScore = self.testFromJson?.english as! Int
                    self.mathScore = self.testFromJson?.mathScore as! Int
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let date = dateFormatter.date(from: (self.testFromJson?.dateTaken)!)
                self.dateTaken = date
            }else{
                for convertEach in testFromJson!.answerConverter! {
                    scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
                }
            }
        }
        
              
        print("donne: \(self.name)")
    }
    
    //Initiliaze a Test without the pdf yet
    init(jsonData: Data, corrections: Bool, user: User){
        self.testFromJson = self.createTestFromJson(data: jsonData)
        if self.testFromJson != nil{
            self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: corrections)
            self.numberOfSections = self.sections.count
            self.testType = TestType(rawValue: self.testFromJson!.testType)
            self.preTestMindset = self.testType?.getPreTestSurvey()
            self.postTestMindset = self.testType?.getPostTestSurvey()
            self.name = self.testFromJson!.name
            if corrections == true{
                if self.testType == .sat{
                    self.englishScore = self.testFromJson?.english as! Int
                    self.mathScore = self.testFromJson?.mathScore as! Int
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let date = dateFormatter.date(from: (self.testFromJson?.dateTaken)!)
                self.dateTaken = date
            }else{
                for convertEach in testFromJson!.answerConverter! {
                    scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
                }
            }
            
            self.getPngsU(user: user){pngs in
                DispatchQueue.global(qos: .utility).async {
                    let pdfModelImages = TestPDF(pngData: pngs).pages
                    DispatchQueue.main.sync {
                        self.setPDFForSection(images: pdfModelImages)
                        self.loadedPDFIn = true
                    }
                }
            }
            
//            user.getPngs(testRef: self.testFromJson!.testRefName){pngs in
//                DispatchQueue.global(qos: .utility).async {
//                let pdfModelImages = TestPDF(pngData: pngs).pages
//                    if pdfModelImages.count <= self.sections.last?.index.end {
//
//                    }
//                    DispatchQueue.main.sync {
//                        self.setPDFForSection(images: pdfModelImages)
//                        self.loadedPDFIn = true
//                    }
//                }
//
//            }
            
        }
        
              
        print("donne: \(self.name)")
    }
    
    func getPngsU(user: User, completionHandler: @escaping (_ completion: [Data])  -> ()){
        user.getPngs(testRef: self.testFromJson!.testRefName){pngs in
            if pngs.count <= (self.sections.last?.index.end)!{
                print("RECURSIVE PNGS CALLED")
                self.getPngsU(user: user){pngsNext in
                    
                    completionHandler(pngsNext)
                }
            }else{
                completionHandler(pngs)
            }
            //completionHandler(pngs)
        }
    }
    
    func setPDFForSection(images: [PageModel]){
        print(self.testFromJson?.testRefName)
        pdfImages = images
        for section in self.sections{
            print(section.index)
            print(images.count)
            let arraySlice = images[section.index.start..<section.index.end - 1]
            section.pages = Array(arraySlice)
            
        }
            
    }
    
    //Create a test fromo Data (coming from database mostly) and png data
    init(jsonData: Data, pngData: [Data], corrections: Bool){
        

        self.testFromJson = self.createTestFromJson(data: jsonData)
        if self.testFromJson != nil{
            //self.pdfImages = TestPDF(pngData: pngData).pages
            self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: corrections)
            self.numberOfSections = self.sections.count
            self.testType = TestType(rawValue: self.testFromJson!.testType)
            self.name = self.testFromJson!.name
            if corrections == true{
                if self.testType == .sat{
                    self.englishScore = self.testFromJson?.english as! Int
                    self.mathScore = self.testFromJson?.mathScore as! Int
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let date = dateFormatter.date(from: (self.testFromJson?.dateTaken)!)
                self.dateTaken = date
            }else{
                for convertEach in testFromJson!.answerConverter! {
                    scoreConvertDict[convertEach.rawScore] = (readingSectionTestScore: convertEach.readingSectionTestScore, mathSectionTestScore: convertEach.mathSectionTestScore, writingAndLanguageTestScore: convertEach.writingAndLanguageTestScore, scienceTestScore: convertEach.scienceTestScore ?? 0)
                }
            }
        }
        
              
        print("donne: \(self.name)")
    }
    
    
    
    
    
    //Create a test result right after somebody submits a test
    init(jsonData: Data, pdfImages: [PageModel]){
        self.pdfImages = pdfImages
        self.testFromJson = self.createTestFromJson(data: jsonData)
        self.sections = self.createSectionArray(testFromJson: self.testFromJson!, corrections: true)
        self.numberOfSections = self.sections.count
        if self.testFromJson != nil {
            self.testType = TestType(rawValue: self.testFromJson!.testType)
            self.name = self.testFromJson!.name
            self.englishScore = self.testFromJson!.english!
            self.mathScore = self.testFromJson!.mathScore!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let date = dateFormatter.date(from: (self.testFromJson?.dateTaken)!)
            self.dateTaken = date
        }

        print("Loaded in Performance Data: \(self.testFromJson?.dateTaken! ?? "No Time")")
        
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
        
        self.testType = test.testType
        self.testFromJson = test.testFromJson
        self.numberOfSections = self.sections.count
        self.isFullTest = false
        self.scoreConvertDict = test.scoreConvertDict
        
    }
    
    
    //Called when the test has not begun yet
    func startTest(){
        print("BEGUN TEST")
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
    func endTest(){
        isEraserEnabled = false
        currentSection?.sectionOver = true
        testState = .testOver
        
        taken = true
        print("ENDED")
        //self.saveWriting()

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
    
    //Changes the section for the correction view
    func setCorrectionTestView(index: Int){
        currentSection?.questions.forEach{$0.canvas = nil}
        currentSection?.pages.forEach{$0.canvas = nil}
        currentSectionIndex = index
    }
    
    
    func reset() {
        //questions.forEach { $0.forEach {$0.reset() } }
        
        testState = .notStarted
        currentSectionIndex = 0
        begunTest = false
        taken = false
        showAnswerSheet = true
        sections.forEach {$0.reset() }
        englishScore = 0
        mathScore = 0
        print("RESET PRESSED")
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
                let tempQuestion = Question(q: question, ip: IndexPath(row: questionNum - 1, section: section.orderInTest), testType: TestType(rawValue: testFromJson.testType)!, isActMath: section.name == "Math" && testFromJson.testType == "ACT")
                tempQuestion.userAnswer = question.studentAnswer ?? ""
                questionList.append(tempQuestion)
            }
            print(testFromJson.name)
            
            var arraySlice = ArraySlice<PageModel>()
            if !pdfImages.isEmpty{
                arraySlice = pdfImages[section.startIndex..<section.endIndex-1]
            }

            let tempSection = TestSection(sectionFromJson: section, pages: Array(arraySlice), name: section.name , questions: questionList, inkingTool: corrections ? PKInkingTool(.pen, color: .red, width: 1) : PKInkingTool(.pen, color: .black, width: 1), testType: TestType(rawValue: testFromJson.testType)!)
            
                sections.append(tempSection)
            
            
        }
        return sections
    }
    

    
    func createResultJson() -> Data {
        //Creating encodable object from test
        var sectionsForJson = [TestSectionFromJson]()
        
        for section in sections {
            let tempSection = section.makeTestSectionForJson(test: self)
            
            if tempSection.name == "Reading" || tempSection.name == "Writing" && (testType == .sat || testType == .psat){
                englishScore += tempSection.scaledScore!
                //englishScore = englishScore ?? 0 + tempSection.scaledScore!
            }else if tempSection.name == "Math No Calculator" || tempSection.name == "Math Calculator" && (testType == .sat || testType == .psat) {
                mathScore += tempSection.rawScore!
                mathScore = mathScore ?? 0 + tempSection.rawScore!
            }
            
            sectionsForJson.append(tempSection)
        }
        
        if (testType == .psat || testType == .sat){
            englishScore = englishScore * 10
        }
        
        if (testType == .psat || testType == .sat){
            mathScore = self.scoreConvertDict[mathScore]?.mathSectionTestScore as! Int
        }
        
        print("TESTING TestType BOOLEAN")
        print(self.testType?.rawValue)
        let testForJson = TestFromJson(numberOfSections: self.numberOfSections!, testType: self.testType!.rawValue, name: self.name, testRefName: self.testFromJson!.testRefName, sections: sectionsForJson, overallScore: overallScore, mathScore: mathScore, english: englishScore, dateTaken: Date().toString(dateFormat: "MM-dd-yyyy HH:mm:ss"), preTestMindset: self.preTestMindset, postTestMindset: self.postTestMindset)
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
        let nameOfFile = "\(testFromJson!.testRefName)-\(user.id)-\(Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss"))"
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
        
        //Updating quick data
        if testType == .act{
            user.quickDataACT.addNewTest(test: self, testResultName: nameOfFile)
            self.db.collection("users").document(user.id).updateData(["quickDataMapACT" : user.quickDataACT.databaseDictionary]){error in
                if let error = error{
                    print("ERROR UPDATING QUICK DATA: \(error)")
                    //probably should delete new entry in quick mapACT
                }else{
                    print("SUCCESS UPDATING QUICK DATA")
                }
            }
        }else if testType == .sat{
            user.quickDataSAT.addNewTest(test: self, testResultName: nameOfFile)
            self.db.collection("users").document(user.id).updateData(["quickDataMapSAT" : user.quickDataSAT.databaseDictionary]){error in
                if let error = error{
                    print("ERROR UPDATING QUICK DATA: \(error)")
                    //probably should delete new entry in quick mapACT
                }else{
                    print("SUCCESS UPDATING QUICK DATA")
                }
            }
        }else if testType == .psat{
            user.quickDataPSAT.addNewTest(test: self, testResultName: nameOfFile)
            self.db.collection("users").document(user.id).updateData(["quickDataMapPSAT" : user.quickDataPSAT.databaseDictionary]){error in
                if let error = error{
                    print("ERROR UPDATING QUICK DATA: \(error)")
                    //probably should delete new entry in quick mapACT
                }else{
                    print("SUCCESS UPDATING QUICK DATA")
                }
            }
        }
        
        user.getPerformanceDataComplete = false
        
        DispatchQueue.global(qos: .utility).async { //TODO: Make  functions to get rid of duplicate code
            print("START ASYNC ADDING TEST to performance")
            
            let tempTest = self.getTempTest(finalResultJson: finalResultJson, user: user)
            
            
            DispatchQueue.main.async {
                print("START MAIN ADDING TEST")
                if self.testType == .act{
                    if user.allACTPerformanceData == nil{
                        user.allACTPerformanceData = AllACTData(tests: [tempTest], user: user)
                        if user.showTestType == nil{
                            user.showTestType = .act
                        }
                        user.getPerformanceDataComplete = true
                    }else{
                        user.allACTPerformanceData!.addTest(test: tempTest)
                    }
                }else if self.testType == .sat{
                    if user.allSATPerformanceData == nil{
                        user.allSATPerformanceData = AllACTData(tests: [tempTest], user: user)
                        if user.showTestType == nil{
                            user.showTestType = .sat
                        }
                        user.getPerformanceDataComplete = true
                    }else{
                        user.allSATPerformanceData!.addTest(test: tempTest)
                    }
                }else if self.testType == .psat{
                    if user.allPSATPerformanceData == nil{
                        user.allPSATPerformanceData = AllACTData(tests: [tempTest], user: user)
                        if user.showTestType == nil{
                            user.showTestType = .psat
                        }
                        user.getPerformanceDataComplete = true
                    }else{
                        user.allPSATPerformanceData!.addTest(test: tempTest)
                    }
                }
            }
        }
        self.reset()
    }
    
    func getTempTest(finalResultJson: Data, user: User) -> ACTFormatedTestData{
        if self.testType == .act{
            let tempTest = ACTFormatedTestData(pdfImages: pdfImages, jsonData: finalResultJson)
            tempTest.createData(index: (user.allACTPerformanceData?.allTestData?.count) ?? 0)
            return tempTest
        }else { // if self.testType == .sat || self.testType == .psat { //TODO Make for psat
            let tempTest = ACTFormatedTestData(pdfImages: pdfImages, jsonData: finalResultJson)
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
    var testType: String
    var name: String
    var testRefName: String
    var sections: [TestSectionFromJson]
    
    //Values only in template json
    var answerConverter: [ScoreConverter]?
    
    //Values only in the test result JSON
    var overallScore: Int? //SAT and ACT
    var mathScore: Int? //SAT
    var english: Int? //SAT
    var dateTaken: String?
    var preTestMindset: MindsetSurveyModel?
    var postTestMindset: MindsetSurveyModel?
    
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
    var reason: String?
    
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





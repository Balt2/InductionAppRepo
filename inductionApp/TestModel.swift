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
    var pdfName: String
    
    init(name: String){
        self.pdfName = name
        self.createPages(name: name)
        
    }
    
    func createPages(name: String){
        var pageCounter = 1
        let path = Bundle.main.path(forResource: name, ofType: "pdf")
        print(path)
        print(name)
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

class TestSection {
    //var name: String
    var allotedTime: Double
    var leftOverTime: Double
    var begunSection = false
    var sectionOver = false
    var index: (start: Int, end: Int)
    var pages = [PageModel]()
    
    init(alloted: Double, start: Int, end: Int, pages: [PageModel] ) {
        self.allotedTime = alloted
        self.leftOverTime = alloted
        self.index = (start: start, end: end)
        self.pages = pages
    }
    
    
}

class Test: ObservableObject {
    var timers = [(alottedTime: 30, leftOverTime: 0), (alottedTime: 50, leftOverTime: 0), (alottedTime: 60, leftOverTime: 0), (alottedTime: 10, leftOverTime: 0) ]
    @Published var currentSection = 0
    @Published var begunTest = false
    @Published var taken = false
    var testJsonFile: String = ""
    var testPDFFile: String = ""
    private var questionsFromJson: [QuestionFromJson] = [] //Array Used to initially load the questions into the Test class
    @Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.
    var testPDFData: NSData?
    @Published var showAnswerSheet = true
    var pdfImages: [PageModel]
    var sections: [TestSection] = []
    var currentSeection: TestSection{
        return sections[currentSection]
    }
    var performanceData: Data {
        return self.createJsonQuestions()
    }
    var computedData: [[String:(r: Double, w: Double, o: Double)]] {
        return self.computeData()
    }
    
    
    init(jsonFile: String, pdfFile: String){
        
        
        self.testJsonFile = jsonFile
        self.testPDFFile = pdfFile
        self.pdfImages = TestPDF(name: pdfFile).pages
        self.createTestSections()
        self.questionsFromJson = readJSONFromFile(fileName: jsonFile)
        self.questions = createQuestionsArray(qsFromJson: questionsFromJson)
        
        
        //self.sendJsonTestPerformanceData()
    }
    
    func createTestSections(){
        for i in [(0, 18), (19, 34), (36, 42), (44, 57)] {
            print("CREATING SECTIONS")
            print(pdfImages.count)
            let arraySlice = pdfImages[i.0..<i.1]
            //let pdfArray = Array(arraySlice) as! [PageModel]
            let t = TestSection(alloted: 30, start: 0, end: 15, pages: Array(arraySlice))
            sections.append(t)
            
        }
    }
    

    
    func createQuestionsArray(qsFromJson: [QuestionFromJson]) -> [[Question]]{
        var qs: [[Question]] = []
        var section = -1
        for question in qsFromJson{
            let splitArray = question.id.split(separator: "_")
            let questionNum = Int(splitArray[2])!
            if questionNum == 1{ //New section code
                //timers.append(SectionTimer(duration: 30*30)) //Adding a new timer for the new section
                section = section + 1
                qs.append([Question(q: question, ip: IndexPath(row: questionNum-1, section: section))])
            }else{
                qs[section].append(Question(q: question, ip: IndexPath(row: questionNum-1, section: section)))
            }
        }
        //print(qs)
        return qs
        
    }
    
    func readJSONFromFile(fileName: String) -> [QuestionFromJson] {
        print("READING FROM JSON")
        var returnArray: [QuestionFromJson] = []
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return []}
                if let dictionary = json as? [String: Any] {
                    if let questions = dictionary["questions"] as? [[String: String]] {
                        returnArray = questions.map {QuestionFromJson(id: $0["id"]!, satSub: $0["satSub"]!, sub: $0["sub"]!, answer: $0["answer"]!, reason: $0["reason"]!)}
                    }
                }
                return returnArray
            } catch {
                print("Error Loading in Test from JSON")
            }
            
        }
        return returnArray
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
                    if data[question.location.section][question.sub] != nil{
                        data[question.location.section][question.sub]?.r+=1
                    }else{
                        data[question.location.section][question.sub] = (r:1, w: 0, o: 0)
                    }
                case .wrong:
                    if data[question.location.section][question.sub] != nil{
                        data[question.location.section][question.sub]?.w+=1
                    }else{
                        data[question.location.section][question.sub] = (r:0, w: 1, o: 0)
                    }
                default:
                    if data[question.location.section][question.sub] != nil{
                        data[question.location.section][question.sub]?.o+=1
                    }else{
                        data[question.location.section][question.sub] = (r:0, w: 0, o: 1)
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
                tempQuestionDict["id"] = question.satID
                tempQuestionDict["satSub"] = question.satSub
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
        self.endDate = Date().advanced(by: Double(self.timeRemaining))

        self.startTimer()

    }
    

    func startTimer() {
        
        guard self.timer == nil else {
            return
        }
        
        self.timer = Timer(timeInterval: 0.2, repeats: true) { (timer) in
            self.timeRemaining = self.endDate!.timeIntervalSince(Date())
            print(self.timeRemaining)
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
        print(self.timeLeftFormatted)
        
    }

    func endTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}


struct QuestionFromJson: Decodable{
    let id: String
    let satSub: String
    let sub: String
    let answer: String
    let reason: String
    
    init(id: String, satSub: String, sub: String, answer: String, reason: String) {
        self.id = id
        self.satSub = satSub
        self.sub = sub
        self.answer = answer
        self.reason = answer
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
    let satID: String
    let satSub: String
    let sub: String
    let answer: String
    let reason: String
    let location: IndexPath
    var answerLetters = ["A", "B", "C", "D"]
    
    @Published var userAnswer = ""
    @Published var currentState = CurrentState.ommited
    @Published var secondsToAnswer = 0.0
    @Published var canvas: PKCanvasView = PKCanvasView()
    
    init(q: QuestionFromJson, ip: IndexPath) {
        self.satID = q.id
        self.satSub = q.satSub
        self.sub = q.sub
        self.answer = q.answer
        self.reason = q.reason
        
        self.location = ip
        
//        if act && (ip.row + 1) % 2 == 1 {
//            self.answerLetters = ["A", "B", "C", "D"]
//        }else if act {
//            self.answerLetters = ["F", "G", "H", "J"]
//        }
      
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


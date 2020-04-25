//
//  TestModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
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

class Test: ObservableObject {
    @Published var timers = [SectionTimer]()
    @Published var currentSection = -1
    @Published var taken = false
    var testJsonFile: String = ""
    private var questionsFromJson: [QuestionFromJson] = [] //Array Used to initially load the questions into the Test class
    @Published var questions: [[Question]] = [] //A 2 dimensional array with a list of questions for each section of the test.
    var testPDFData: NSData?
    
    var performanceData: Data {
        return self.createJsonQuestions()
    }
    
    var computedData: [[String:(r: Double, w: Double, o: Double)]] {
        get {
            return self.computeData()
        }
    }
    init(jsonFile: String){
        
        self.testJsonFile = jsonFile
        self.questionsFromJson = readJSONFromFile(fileName: jsonFile)
        self.questions = self.createQuestionsArray(qsFromJson: questionsFromJson)
        //self.sendJsonTestPerformanceData()
    }
    
    func createQuestionsArray(qsFromJson: [QuestionFromJson]) -> [[Question]]{
        var qs: [[Question]] = []
        var section = -1
        for question in qsFromJson{
            let splitArray = question.id.split(separator: "_")
            let questionNum = Int(splitArray[2])!
            if questionNum == 1{ //New section code
                timers.append(SectionTimer(timeAllowed: 65*60)) //Adding a new timer for the new section
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
    
    func computeData() -> [[String:(r: Double, w: Double, o: Double)]]{
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
    //All times in seconds
    //let didChange = PassthroughSubject<SectionTimer, Never>()
    var timeAllowed: Float
    @Published var timeLeft: Float //If the section is currently being taken this will count down.
    var timeNotUsed: Float? //Once the section is finished this will contain the value of time they did not use.
    @Published var isDone = false //If this is nil then the timer as not started. If it is false the timer is going. If it is true the section is over.
    @Published var started = false
    var timeLeftFormated: (min: Int, sec: Int) {
        get{
            return ((Int(timeLeft) / 60), Int(timeLeft.truncatingRemainder(dividingBy: 60)))
        }
    }
    
    init(timeAllowed: Float) {
        self.timeAllowed = timeAllowed
        self.timeLeft = timeAllowed

    }
    
    func startTimer() {
        self.started = true
    }
    
    
    func endTimer() {
        self.isDone = true
        self.timeNotUsed = timeLeft
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
    
    @Published var userAnswer: String?
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
        else if (userAnswer! == answer) {
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


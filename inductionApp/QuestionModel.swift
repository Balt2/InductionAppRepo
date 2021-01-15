//
//  QuestionModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/17/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import Firebase
import PencilKit
import Combine

class Question: ObservableObject, Hashable, Identifiable {
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    //Unique ID for hashable protocal
    var id = UUID()
    //ID of question from JSON file
    let officialID: String
    //Sub section as given by the college board or some other governering body
    let officialSub: String
    //Tutor sub for costumization
    let tutorSub: String
    //Students answer
    let answer: String
    //Reason for answer as given by json
    let reason: String
    //Locaiton in test
    let location: IndexPath
    let testType: TestType
    let isACTMath: Bool
    let freeResponse: Bool //This variable determines whether a the question needs a free response answer sheet cell
    var answerLetters = ["A", "B", "C", "D"] //Default for SAT. Reset if you have a ACT or other type of test
    
   
    var answerOrdredIn = 0
    
    @Published var userAnswer = ""
    @Published var currentState = QuestionState.omitted
    //This is the value that we send as the result
    var finalState: QuestionState {
           get{
               return self.currentState
           }
           set{
            self.currentState = newValue
           }
       }
    //Initialize the question. We dont create a canvas until the section is started.
    @Published var secondsToAnswer = 0.0
    @Published var canvas: PKCanvasView?
    
    init(q: QuestionFromJson, ip: IndexPath, testType: TestType, isActMath: Bool) {
        self.officialID = q.id
        self.officialSub = q.officialSub
        self.tutorSub = q.tutorSub
        self.answer = q.answer
        if q.answer.isDouble || q.answer.count > 1{
            self.freeResponse = true
        }else{
            self.freeResponse = false
        }
        self.reason = q.reason ?? ""
        self.testType = testType
        self.location = ip
        self.isACTMath = isActMath
        self.secondsToAnswer = Double(q.secondsToAnswer ?? 0)
        self.finalState = QuestionState(rawValue: q.finalState ?? "O") ?? QuestionState.omitted
        //ip = indexPath of question. + 1 because it starts at (0,0)
        if self.isACTMath && (ip.row + 1) % 2 == 1 {
            self.answerLetters = ["A", "B", "C", "D", "E"]
        }else if self.isACTMath {
            self.answerLetters = ["F", "G", "H", "J", "K"]
        }else if testType == .act && (ip.row + 1) % 2 == 1 {
            self.answerLetters = ["A", "B", "C", "D"]
        }else if testType == .act {
            self.answerLetters = ["F", "G", "H", "J"]
        }
    
    }
    
    init(question: Question){
        self.officialID = question.officialID
        self.officialSub = question.officialSub
        self.tutorSub = question.tutorSub
        self.answer = question.answer
        self.freeResponse = question.freeResponse
        self.reason = question.reason
        self.testType = question.testType
        self.location = question.location
        self.isACTMath = question.isACTMath

        //Setting the letters for questions based on what type of ttest
        if self.isACTMath && (question.location.row + 1) % 2 == 1 {
            self.answerLetters = ["A", "B", "C", "D", "E"]
        }else if self.isACTMath {
            self.answerLetters = ["F", "G", "H", "J", "K"]
        }else if testType == .act && (question.location.row + 1) % 2 == 1 {
            self.answerLetters = ["A", "B", "C", "D"]
        }else if testType == .act {
            self.answerLetters = ["F", "G", "H", "J"]
        }
    }
    
    func checkAnswer() {
        
        if (currentState == .invalidSelection || currentState == .omitted)
            {return}
        else if (userAnswer == answer) {
            currentState = .right
        }else {
            print("CHECKING WRONG ANSWER")
            //Checking free response questions as the answer to those comes as a list of strings
            let answerArray = answer.split(separator: ",")
            let answerArrayStr = answerArray.map {String($0)}
            if answerArrayStr.contains(userAnswer) {
                currentState = .right
            }else{
                currentState = .wrong
            }
        }
    
    }
    
    func reset() {
        self.answerOrdredIn = 0
        self.userAnswer = ""
        self.currentState = .omitted
        self.secondsToAnswer = 0.0
        self.canvas = nil
    }
    
}


enum QuestionState : String {
    //Used when checking the answer and creating data
    case right = "R" //Right
    case wrong = "W" //Wrong
    case omitted = "O" //omitted
    case invalidSelection = "I" //Invalid Selection
    
    //Used when still in test
    ///.omitted = "O" is used here too
    case selected = "S" //Selected
}

extension String {
    var isInteger: Bool { return Int(self) != nil }
    var isFloat: Bool { return Float(self) != nil }
    var isDouble: Bool { return Double(self) != nil }
}

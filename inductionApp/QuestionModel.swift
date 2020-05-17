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
    var finalState: QuestionState{
        self.checkAnswer()
        return self.currentState
    }
    
    @Published var userAnswer = ""
    @Published var currentState = QuestionState.ommited
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
    
    init(question: Question){
        self.officialID = question.officialID
        self.officialSub = question.officialSub
        self.tutorSub = question.tutorSub
        self.answer = question.answer
        self.reason = question.reason
        self.isACT = question.isACT
        self.location = question.location
        
        if isACT && (question.location.row + 1) % 2 == 1 {
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
        self.canvas = nil
    }
    
}


enum QuestionState : String {
    //Used when checking the answer and creating data
    case right = "R" //Right
    case wrong = "W" //Wrong
    case ommited = "O" //Ommited
    case invalidSelection = "I" //Invalid Selection
    
    //Used when still in test
    ///.ommited = "O" is used here too
    case selected = "S" //Selected
}

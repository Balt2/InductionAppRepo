//
//  MindsetModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/7/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation

//MODEL FOR MINDESET SURVEYS
class MindsetSurveyModel: Codable{
    var id = UUID()
    var name: String
    //SECTIONS FOR MINDSET MODULE
    var sections: [MindsetSectionModel]
    
    init(name: String, sections: [MindsetSectionModel]){
        self.name = name
        self.sections = sections
    }
}

//SECTION MODEL
class MindsetSectionModel: Codable{
    var id = UUID()
    
    var headers: [String]
    var subHeaders: [String]?
    var questions: [MindsetQuestionModel]
    init(headers: [String], subHeaders: [String]? = nil, questions: [MindsetQuestionModel] ){
        self.headers = headers
        self.subHeaders = subHeaders
        self.questions = questions
    }
}

//QUESTION MODEL
class MindsetQuestionModel: Codable, Hashable{
    
    static func == (lhs: MindsetQuestionModel, rhs: MindsetQuestionModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    var questionIndex: Int
    var question: String
    
    var answer: String?
    
    init(questionIndex: Int, question: String){
        self.questionIndex = questionIndex
        self.question = question
    }
}

//
//  MindsetModel.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/7/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation

struct MindsetSurveyModel{
    var id = UUID()
    var name: String
    var sections: [MindsetSectionModel]
}

struct MindsetSectionModel{
    var id = UUID()
    
    var headers: [String]
    var questions: [MindsetQuestionModel]
}

struct MindsetQuestionModel: Hashable{
    
    var questionIndex: Int
    var question: String
    
    var answer: String?
}

//
//  MindsetView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/7/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct MindsetView: View {
    
    var testData = MindsetSurveyModel(name: "Before Test", sections: [MindsetSectionModel(headers: ["Strongly Disagree", "Disagree", "Agree", "Strongly Agree"],
                                       questions: [MindsetQuestionModel(questionIndex: 1, question: "I feel tense during tests"),
    MindsetQuestionModel(questionIndex: 2, question: "I wish exams did not bother me so much"),
    MindsetQuestionModel(questionIndex: 3, question: "I defeat myself on tests"),
    MindsetQuestionModel(questionIndex: 4, question: "I feel panicky during tests"),
    MindsetQuestionModel(questionIndex: 5, question: "During the exam I am nervous and forget facts")
    ]), MindsetSectionModel(headers: ["Not Much (less than 2hrs)",
     "A Little (between 2 and 4hrs)",
     "Decent Amount (between 4 and 8hrs)",
     "A Lot (more than 8hrs)"], questions: [
    MindsetQuestionModel(questionIndex: 6,
                         question: "How much time have you spent on other work today?")]),
        MindsetSectionModel(headers: ["Not Much (less than 4hrs)",
         "A Little (between 4 and 6hrs)",
         "Decent Amount (between 6 and 8hrs)",
         "A Lot (more than 8hrs)"], questions: [
        MindsetQuestionModel(questionIndex: 7,
                             question: "How much did you sleep last night?")]),
        MindsetSectionModel(headers: ["", "Yes","No",""], questions: [
        MindsetQuestionModel(questionIndex: 8,
                             question: "Have you worked out today?")])
        
    ])
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Text("What's your mindset?").font(.largeTitle).padding([.top, .bottom], 10).frame(maxWidth: .infinity)
                ScrollView(.vertical){
                    
                    ForEach(self.testData.sections, id: \.id){section in
                        Group{
                            HStack (spacing: 20){
                                ForEach(section.headers, id: \.self){header in
                                    Text(header).fontWeight(.bold).lineLimit(nil).frame(width: 80).multilineTextAlignment(.center)
                                }
                            }.offset(x: 100, y: 0)
                            VStack{
                                ForEach(section.questions, id: \.self){question in
                                    MindsetQuestionView(questionNumber: question.questionIndex, questionText: question.question, headers: section.headers)
                                        .frame(maxWidth: .infinity).background(Color.white)
                                }
                            }//.frame(maxWidth: .infinity).background(Color.white).padding([.top, .bottom], 10)
                        }
                    }
                }
            }.background(Color(red: 0.82, green: 0.82, blue: 0.82))
        }.navigationViewStyle((StackNavigationViewStyle())).navigationBarItems(trailing: Text("SUBMIT"))
    }
}

struct MindsetQuestionView: View {
    var questionNumber: Int
    var questionText: String
    var headers: [String]
    @State var chosenString: String = "N/A"
    var body: some View {
        HStack{
            HStack{
                ZStack(){
                    Circle().stroke().frame(width: 30, height: 30).foregroundColor(Color.blue)
                        
                    Text(String(questionNumber))
                        .foregroundColor(Color.blue)
                }
                Text(questionText).fontWeight(.bold).foregroundColor(Color.orange).multilineTextAlignment(.center)
            }.frame(width: 200)
            
            ForEach(headers, id: \.self){string in
                ZStack{
                       Text(string)
                        .multilineTextAlignment(.center).lineLimit(nil).frame(width: 80).opacity(0.0)
                    Circle().fill(Color.blue).opacity(self.chosenString == string ? 1 : 0.01).overlay(Circle().stroke(Color.black)).frame(width: 20, height: 20).onTapGesture {
                        self.chosenString = string
                    }
                }.padding(5).opacity(string == "" ? 0.0 : 1.0)
                
            }
            
            }.frame(height: 75)
    }
}


//
//struct MindsetView_Previews: PreviewProvider {
//    static var previews: some View {
//        MindsetView()
//    }
//}

//
//  MindsetView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/7/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct MindsetView: View {
    @Binding var presentView: Bool
    @State var responseString: String = ""
    var test: Test
    var model: MindsetSurveyModel
    var preTest: Bool
    @ObservedObject var user: User
    @Binding var shouldPopToRoot: Bool
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                Text(model.name).font(.largeTitle).padding([.top, .bottom], 10).frame(maxWidth: .infinity)
                ScrollView(.vertical){
                    
                    ForEach(self.model.sections, id: \.id){section in
                        Group{
                            HStack (spacing: 20){
                                ForEach(section.headers, id: \.self){header in
                                    Text(header).fontWeight(.bold).lineLimit(nil).frame(width: 80).multilineTextAlignment(.center)
                                }
                            }.offset(x: 100, y: 0)
                            VStack{
                                ForEach(section.questions, id: \.self){question in
                                    MindsetQuestionView(question: question, headers: section.headers, responseString: self.$responseString)
                                        .frame(maxWidth: .infinity).background(Color.white)
                                }
                            }//.frame(maxWidth: .infinity).background(Color.white).padding([.top, .bottom], 10)
                        }
                    }
                }.navigationBarTitle(Text("Mindset Module: \(preTest ? "pre-test" : "post-test")"), displayMode: .inline).navigationBarItems(trailing: Button(action: {
                    print("SUBMIT PRESSED")
                    if (self.model.sections.last?.headers.isEmpty)! {
                        self.model.sections.last?.questions.last?.answer = self.responseString
                    }
                    if self.preTest {
                        self.test.preTestMindset = self.model
                    }else{
                        self.test.postTestMindset = self.model
                        self.test.sendResultJson(user: self.user)
                        self.shouldPopToRoot = false
                    }
                    self.presentView = false
                }) {
                    Text("Submit")
                })
            }.background(Color(red: 0.82, green: 0.82, blue: 0.82))
        }.navigationViewStyle((StackNavigationViewStyle()))
    }
}

struct MindsetQuestionView: View {
    var question: MindsetQuestionModel
    var headers: [String]
    
    @State var chosenString: String = "N/A"
    @Binding var responseString: String
    var body: some View {
        HStack{
            HStack{
                ZStack(){
                    Circle().stroke().frame(width: 30, height: 30).foregroundColor(Color.blue)
                        
                    Text(String(question.questionIndex))
                        .foregroundColor(Color.blue)
                }
                Text(question.question).fontWeight(.bold).foregroundColor(Color.orange).multilineTextAlignment(.center)
            }.frame(width: 200)
            Group{
                if !headers.isEmpty{
                
                    ForEach(headers, id: \.self){string in
                        ZStack{
                               Text(string)
                                .multilineTextAlignment(.center).lineLimit(nil).frame(width: 80).opacity(0.0)
                            Circle().fill(Color.blue).opacity(self.chosenString == string ? 1 : 0.01).overlay(Circle().stroke(Color.black)).frame(width: 20, height: 20).onTapGesture {
                                self.question.answer = string
                                self.chosenString = string
                            }
                        }.padding(5).opacity(string == "" ? 0.0 : 1.0)
                        
                    }
                }else{
                    TextField("Respond Here", text: self.$responseString).frame(width: 350).padding([.top, .bottom], 5).padding(.leading, 50) //TODO, can make TextEditor for ios 14
                
                }
            }
            .frame(height: 75)
        }
    }
}


//
//struct MindsetView_Previews: PreviewProvider {
//    static var previews: some View {
//        MindsetView()
//    }
//}

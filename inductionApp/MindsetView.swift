//
//  MindsetView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 8/7/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

//MODULE FOR PRE AND POST TEST MODULES
struct MindsetView: View {
    //WILL BE FALSE ONCE THE SHEET IS DISMISSED BY USER
    @Binding var presentView: Bool
    //FREE RESPONSE STRING
    @State var responseString: String = ""
    //DATA FOR TEST
    @ObservedObject var test: Test
    //INFORMATION ABOUT THE QUESTIONS TO ASK
    var model: MindsetSurveyModel
    //BOOLEAN TO DETERMIEN IF THIS IS PRE OR POST TEST
    var preTest: Bool
    //USER
    @ObservedObject var user: User
    @Binding var shouldPopToRoot: Bool
    @Binding var surveySubmitted: Bool
    
    var body: some View {
        Group{
            if test.loadedPDFIn == false && surveySubmitted == true{
                //ONCE THEY HAVE SUBMITED THE PRE-SURVEY THIS WILL LOAD. IF THE TEST HAS NOT LOADED YET THIS LOGIC WILL RUN
                VStack{
                    ActivityIndicator(isAnimating: (test.loadedPDFIn == false && surveySubmitted == true))
                    Text("Loading Test...")
                }.onReceive(test.$loadedPDFIn){newValue in
                    if newValue == true{
                        self.presentView = false
                    }
                }.opacity(0.5)
            }else if surveySubmitted == false{
                //IF THE SURVEY HAS NOT BEEN SUBMITED WE WILL SHOW IT
                NavigationView{
                    VStack(alignment: .leading){
                       //PRESENTING INFORMATION FROM THE SURVEY
                        Text(model.name).font(.largeTitle).padding([.top, .bottom], 10).frame(maxWidth: .infinity)
                        ScrollView(.vertical){
                            
                            ForEach(self.model.sections, id: \.id){section in
                                Group{
                                    HStack (spacing: 20){
                                        ForEach(0..<section.headers.count){i in
                                            ComplexHeaderView(header: section.headers[i], subHeader: (section.subHeaders != nil) ? section.subHeaders![i] : "" )
                                            .lineLimit(nil).frame(width: 80).multilineTextAlignment(.center)
                                        }
                                    }.offset(x: 160, y: 0) //TODO: Understand the 160
                                    VStack{
                                        ForEach(section.questions, id: \.self){question in
                                            MindsetQuestionView(question: question, headers: section.headers, responseString: self.$responseString)
                                                .background(Color.white).frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }.navigationBarTitle(Text("Mindset Module: \(preTest ? "pre-test" : "post-test")"), displayMode: .inline).navigationBarItems(trailing: Button(action: {
                            print("SUBMIT PRESSED for Survey")
                            self.surveySubmitted = true
                            
                            //For Free response
                            if (self.model.sections.last?.headers.isEmpty)! {
                                self.model.sections.last?.questions.last?.answer = self.responseString
                            }
                            
                            //Sending test data and poping out to the homescreen
                            if !self.preTest {
                                self.test.sendResultJson(user: self.user)
                                self.shouldPopToRoot = false
                            }
                            
                            //Pulling the model down
                            if self.test.loadedPDFIn{
                                self.surveySubmitted = false
                                self.presentView = false
                            }
                        }) {
                            Text("Submit")
                        })
                    }.background(Color(red: 0.82, green: 0.82, blue: 0.82))
                }.navigationViewStyle((StackNavigationViewStyle()))
            }
        }
    }
}

//STRUCTURE FOR EACH QUESTION IN THE MODULE
struct MindsetQuestionView: View {
    //QUESTION MODEL
    var question: MindsetQuestionModel
    //POSSIBLE ANSWERS FOR THIS QUESTION
    var headers: [String]
    var subHeaders: [String]?
    //WHAT DID THE USER SELECT. THEY ALSO MAY NOT SELECT ANY VALUE
    @State var chosenString: String = "N/A"
    @Binding var responseString: String
    var body: some View {
        HStack{
            HStack{
                ZStack(){
                    Circle().stroke().frame(width: 30, height: 30).foregroundColor(Color.blue)
                    //DISPLAYING THE QUESTION NUMBER
                    Text(String(question.questionIndex))
                        .foregroundColor(Color.blue)
                }
                //DISPLAYING THE QUESTION TEXT
                Text(question.question).fontWeight(.bold).foregroundColor(Color.orange).multilineTextAlignment(.center).frame(width: 170)
            }.frame(maxWidth: .infinity)
            Group{
                if !headers.isEmpty{
                
                    ForEach(0..<headers.count){i in
                        ZStack{
                            ComplexHeaderView(header: self.headers[i], subHeader: self.subHeaders == nil ? "" : self.subHeaders![i])
                                .multilineTextAlignment(.center).lineLimit(nil).frame(width: 80).opacity(0.0)
                            
                            Circle().fill(Color.blue).opacity(self.chosenString == self.headers[i] ? 1 : 0.01).overlay(Circle().stroke(Color.black)).frame(width: 20, height: 20).onTapGesture {
                                self.question.answer = self.headers[i]
                                self.chosenString = self.headers[i]
                            }
                        }.padding(5).opacity(self.headers[i] == "" ? 0.0 : 1.0) //If there is no header for a spcific spot it gets a ""
                        
                    }
                }else{
                    TextField("Respond Here", text: self.$responseString).padding(10).border(Color.black).frame(width: 300) //.frame(width: 350).padding([.top, .bottom], 5).padding(.leading, 50) //TODO, can make TextEditor for ios 14
                
                }
            }
            .frame(height: 75)
        }
    }
    
}

//USES HEADERS AND SUBHEADERS TO MAKE THINGS BOLD
struct ComplexHeaderView: View {
    var header: String
    var subHeader: String
    var body: some View {
        Group{
            if subHeader == ""{
                Text("\(header)")
                           .fontWeight(.bold)
            }else{
                
                Text("\(header)\n")
                    .fontWeight(.bold)
                +
                    Text(subHeader)
                        .fontWeight(.light)
            }
        }
    }
}


//
//struct MindsetView_Previews: PreviewProvider {
//    static var previews: some View {
//        MindsetView()
//    }
//}

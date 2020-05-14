//
//  TestView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import PencilKit
import Combine

struct TestView: View {
    @EnvironmentObject var tests: TestList
    //@ObservedObject var testData = Test(jsonFile: "satPracticeTest1", pdfFile: "pdf_sat-practice-test-1")
    @ObservedObject var testData: Test
    
    var body: some View {
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.black)
            VStack{
                HStack{
                    if testData.showAnswerSheet == true{
                        AnswerSheetList(test: testData).frame(width: 300)
                    }
                    GeometryReader {scrollGeo in
                        ScrollView {
                            VStack {
                                ForEach(self.testData.currentSection.pages, id: \.self){ page in
                                    PageView(model: page).blur(radius: self.testData.begunTest ? 0 : 20)
                                        .disabled(self.testData.begunTest ? false : true)
                                }
                            }
                        }.navigationBarItems(trailing: TimerNavigationView(test: self.testData))
                            //.offset( y: -scrollGeo.frame(in: .global).minY)
                    }
                }
            }
        }
    }
}



struct PageView: View{
    var model: PageModel
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        
        ZStack{
            Image(uiImage: model.uiImage).resizable().aspectRatio(contentMode: .fill)
            
            CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", officialSub: "", tutorSub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), act: true), isAnswerSheet: false, protoRect: CGRect())
        }
    }
}

struct TimerNavigationView: View {
    @ObservedObject var test: Test
    @State private var now = ""
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View{
        HStack{
            
            //Answer Sheet button
            if test.showAnswerSheet == false {
                Button(action: {
                    self.test.showAnswerSheet = true
                }){
                    Text("Show Answer Sheet")
                }
            } else {
                Button(action: {
                    self.test.showAnswerSheet = false
                }){
                    Text("Hide Answer Sheet")
                }
            }
            
            
            //Contrl of test buttons
            if test.begunTest == false && test.taken == false {
                Button(action: {
                    self.test.currentSection.sectionTimer.startTimer()
                    self.test.begunTest = true
                    self.test.currentSection.begunSection = true
                    
                    print("STARTING TIMER")
                   }){
                       Text("Start Test")
                   }
            }else if self.test.taken == true{
                Text("Test Over")
            }
            else if test.currentSectionIndex < 3 {
               Button(action: {
                self.test.currentSection.sectionOver = true
                self.test.currentSection.sectionTimer.endTimer()
                self.test.currentSection.leftOverTime = self.test.currentSection.sectionTimer.timeRemaining
                
                self.test.currentSectionIndex += 1
                self.test.currentSection.sectionTimer.startTimer()
                self.test.currentSection.begunSection = true
                self.now = self.test.currentSection.sectionTimer.timeLeftFormatted
                
               }) {
                   Text("Start Next section")
               }
            } else if test.currentSectionIndex == 3 {
               Button(action: {
                self.test.taken = true
                self.test.currentSection.sectionOver = true
                self.test.currentSection.leftOverTime = self.test.currentSection.sectionTimer.timeRemaining
                //TODO: SEND DATAs
               }){
                Text("End Test and Check")
               }
            }
            
            Spacer()
            //Shows time text
            if self.test.begunTest == true && self.test.taken == false {
            
                Text("\(now) left")
                    .onReceive(timer) { _ in
                        self.now = self.test.currentSection.sectionTimer.timeLeftFormatted
                    }
            }

            Spacer()
        }
    }
}

struct TestTable: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    var body: some View {
        List(currentAuth.currentUser!.tests){test in
            NavigationLink(destination: TestView(testData: test)){
                Text(test.name!)
            }.frame(height: 90)
        }.navigationBarTitle(Text("Choose Test to Take"))
        
    }
}

struct StudyTable: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    var body: some View {
        List{
            ForEach(currentAuth.currentUser?.tests ?? [], id: \.self){test in
                ForEach(test.sections, id: \.self){section in
                    NavigationLink(destination: TestView(testData: Test(testSection: section, test: test))){
                           Text(" \(section.name) from \(test.name!)")
                       }.frame(height: 90)
                }
            }
        }.navigationBarTitle(Text("Choose Section to Study"))
    }
}

//struct TestView_Previews: PreviewProvider {
//    static let tests = TestList()
//    static var previews: some View {
//        TestView(, testData: <#Test#>).environmentObject(tests)
//    }
//}





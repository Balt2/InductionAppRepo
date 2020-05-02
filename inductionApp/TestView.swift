//
//  TestView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import PencilKit

struct TestView: View {
    @EnvironmentObject var tests: TestList
    @ObservedObject var testData = Test(jsonFile: "satPracticeTest1", pdfFile: "pdf_sat-practice-test-1")

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
                        }.navigationBarItems(trailing: TimerNavigationView(test: self.testData, timer: SectionTimer(duration: Int(self.testData.currentSection.allotedTime))))
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
            
            CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", satSub: "", sub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), act: true), isAnswerSheet: false, protoRect: CGRect())
        }
    }
}

struct TimerNavigationView: View {
    @ObservedObject var test: Test
    @ObservedObject var timer: SectionTimer

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
                    self.timer.startTimer()
                    self.test.begunTest = true
                    self.test.currentSection.begunSection = true
                    print("STARTING TIMER")
                   }){
                       Text("Start Test")
                   }
            } else if test.currentSectionIndex < 3 {
               Button(action: {
                self.test.currentSection.sectionOver = true
                self.timer.startTimer()
                self.test.currentSectionIndex += 1
                self.test.currentSection.begunSection = true
                
               }) {
                   Text("Start Next section")
               }
            } else if test.currentSectionIndex == 3 {
               Button(action: {
                self.test.taken = true
                self.test.currentSection.sectionOver = true
                //TODO: SEND DATA
               }){
                Text("End Test and Check")
               }
            } else if self.test.taken == true{
                Text("Test Over")
            }
            
            Spacer()
            //Shows time text
            if self.test.begunTest == true && self.test.taken == false {
                Text("\(self.timer.timeLeftFormatted) left")
            }

            Spacer()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static let tests = TestList()
    static var previews: some View {
        TestView().environmentObject(tests)
    }
}





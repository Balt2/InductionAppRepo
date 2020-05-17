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
                                ForEach(self.testData.currentSection!.pages, id: \.self){ page in
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
            
            CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", officialSub: "", tutorSub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), act: true), page: model, isAnswerSheet: false, protoRect: CGRect())
        }
    }
}

struct TimerNavigationView: View {
    @ObservedObject var test: Test
    @State private var now = ""
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View{
        HStack{
            
            //Universal Eraser
            Button(action: {
                //This toggle changes the tool on all canves within the test
                self.test.isEraserEnabled.toggle()
                print("Toggle Eraser")
            }){
                if self.test.isEraserEnabled == true{
                    Image(systemName: "pencil").frame(width: 40, height: 40)
                }else{
                    Image(systemName: "minus.circle").frame(width: 40, height: 40)
                }
            }
            Spacer()
            
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
            
            Button(action: {
                switch self.test.testState{
                case .notStarted:
                    self.test.startTest()
                case .inSection:
                    self.test.endSection()
                case .betweenSection:
                    self.test.nextSection(fromStart: false)
                case .lastSection:
                    self.test.endTest()
                    //TODO: SEND DATAs
                case .testOver:
                    print("Should never get here")
                }
            }){
                HStack{
                   getControlButton()
                }
            }
            
            //Shows time text
            
            if self.test.testState == .inSection
            || self.test.testState == .lastSection {
                Text("\(now) left")
                    .onReceive(timer) { _ in
                        self.now = self.test.currentSection!.sectionTimer.timeLeftFormatted
                }.foregroundColor(self.test.currentSection!.sectionTimer.timeRemaining < 10.0 ? .red : .black)
            }

            Spacer()
        }
    }
    func getControlButton() -> Text {
        switch self.test.testState{
        case .notStarted:
            if test.isFullTest == true {
                return Text("Start Test")
            }else{
                return Text("Start Section")
            }
        case .inSection: return Text("End Section")
        case .betweenSection: return Text("Start Next Section")
        case .lastSection:
            if test.isFullTest == true {
                return Text("End Test")
            }else{
                return Text("End Study Section")
            }
        case .testOver:
            if test.isFullTest == true {
                return Text("Test Over")
            }else{
                return Text("Study Section Over")
            }
        }
    }
}

//Tables that are presented before the TestView
struct TestTable: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    var body: some View {
        List(currentAuth.currentUser!.tests){test in
            NavigationLink(destination: TestView(testData: test)){
                Text(test.name)
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
                    NavigationLink(destination: TestView(testData: Test(testSections: [section], test: test))){
                        Text(" \(section.name) from \(test.name)")
                       }.frame(height: 90)
                }
            }
        }.navigationBarTitle(Text("Choose Section to Study"))
    }
}

struct PastPerformanceTable: View {
    @EnvironmentObject var currentAuth: FirebaseManager
        var body: some View {
            ScrollView {
                VStack {
                    ForEach(self.currentAuth.currentUser!.performancePDF, id: \.self){ page in
                        PageView(model: page)
                    }
                }
            }
    }
}


//struct TestView_Previews: PreviewProvider {
//    static let tests = TestList()
//    static var previews: some View {
//        TestView(, testData: <#Test#>).environmentObject(tests)
//    }
//}





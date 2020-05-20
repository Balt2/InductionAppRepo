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
    //@EnvironmentObject var tests: TestList
    //@ObservedObject var testData = Test(jsonFile: "satPracticeTest1", pdfFile: "1-ACT Exam 1906")
    @ObservedObject var testData: Test
    //@ObservedObject var user: User
    @EnvironmentObject var currentAuth: FirebaseManager
    
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
                    GeometryReader {outsideProxy in
                        ScrollView(.vertical) {
                            ForEach(self.testData.currentSection!.pages, id: \.self){ page in
                                PageView(model: page).blur(radius: self.testData.begunTest ? 0 : 20)
                                    .disabled( (self.testData.testState == .inSection || self.testData.testState == .lastSection ) ? false : true)
//                                    .onTapGesture {
//                                    print(outsideProxy.frame(in: .local))
                                        //}
                            }.navigationBarItems(leading: EndTestNavigationView(test: self.testData), trailing: TimerNavigationView(test: self.testData))
                            
                        }
                    }
                }
                //.offset( y: -scrollGeo.frame(in: .global).minY)
                
            }
        }
    }
}





struct PageView: View{
    var model: PageModel
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        
        ZStack{
            Image(uiImage: self.model.uiImage).resizable().aspectRatio(contentMode: .fill)
            
            GeometryReader { geo in
                CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", officialSub: "", tutorSub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), act: true), page: self.model, isAnswerSheet: false, protoRect: CGRect(), canvasGeo: geo.size)
            }
        }
    }
}

struct EndTestNavigationView: View {
    //Used to go back
   // @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentAuth: FirebaseManager
    @EnvironmentObject var navControl: NavigationFlowObject
    @ObservedObject var test: Test
    @State private var showAlert = false
    var body: some View {
         Button(action: {
            self.showAlert = true
       }){
        Text("End Test")
            .foregroundColor(.red)
         }.alert(isPresented: $showAlert){
            Alert(title: Text("Are you sure you want to end the test?"),
                  message: Text("You will not be able to edit this test, but results will be calculated"),
                  primaryButton: .default(Text("Cancel")),
                  secondaryButton: .default(Text("OK")){
                    //self.presentationMode.wrappedValue.dismiss()
                    self.navControl.isActive = true
                    self.test.endTest()
                    //Ideally it goes all the way back to
                    
                })
        }
        
    }
    
    ////
//    struct RootView: View {
//
//        @EnvironmentObject var navigationFlow: NavigationFlowObject
//
//        var body: some View {
//            NavigationView {
//                ZStack {
//                    NavigationLink(destination: SecondView()
//                        .navigationBarTitle("second", displayMode: .inline)
//                    , isActive: $navigationFlow.isActive){
//                        EmptyView()
//                    }.isDetailLink(false)
//                    Button(action: {
//                        self.navigationFlow.isActive = true
//                    }) {
//                        Text("Push me")
//                    }
//                }
//            }
//        }
//    }
    
    
    ////
    
}

struct TimerNavigationView: View {
    @ObservedObject var test: Test
    //@ObservedObject var user: User
    @State private var now = ""
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        
        HStack (spacing: 200){
            HStack {
                
                //Pencil Button - Enables the pencil
                Button(action: {
                    if self.test.isEraserEnabled == true{
                        self.test.isEraserEnabled = false
                    }
                }){
                    Image(systemName: "pencil")
                        .foregroundColor(self.test.isEraserEnabled == false ? .blue : .gray)
                        .font(self.test.isEraserEnabled == false ? .largeTitle : .title)
                }.disabled(self.test.isEraserEnabled == false)
                    .padding()
                
                
                //Eraser Button - Enables the eraser
                Button(action: {
                    if self.test.isEraserEnabled == false{
                        self.test.isEraserEnabled = true
                    }
                }){
                    Image(systemName: "trash")
                        .foregroundColor(self.test.isEraserEnabled == true ? .blue : .gray)
                        .font(self.test.isEraserEnabled == true ? .largeTitle : .title)
                }.disabled(self.test.isEraserEnabled == true)
                    .padding()
                
                
                //Plus Magnifying glass - Makes test larger
                Button(action: {
                    if self.test.showAnswerSheet == true {
                        self.test.showAnswerSheet = false
                        self.test.currentSection?.scalePages()
                    }
                }){
                    Image(systemName: "plus.magnifyingglass")
                        .foregroundColor(self.test.showAnswerSheet == false ? .blue : .gray)
                        .font(self.test.showAnswerSheet == false ? .largeTitle : .title)
                }.disabled(self.test.showAnswerSheet == false)
                    .padding()
                
                
                //Minus Magnifying glass - Shows Answer Sheet
                Button(action: {
                    if self.test.showAnswerSheet == false {
                        self.test.showAnswerSheet = true
                        self.test.currentSection?.scalePages()
                    }
                }){
                    Image(systemName: "minus.magnifyingglass")
                        .foregroundColor(self.test.showAnswerSheet == true ? .blue : .gray)
                        .font(self.test.showAnswerSheet == true ? .largeTitle : .title)
                }.disabled(self.test.showAnswerSheet == true)
                    .padding()
                
            }
            HStack {
                Button(action: {
                    switch self.test.testState{
                    case .notStarted:
                        self.test.startTest()
                    case .inSection:
                        self.test.endSection()
                    case .betweenSection:
                        self.test.nextSection(fromStart: false)
                        if self.test.showAnswerSheet == true {
                            self.test.currentSection?.scalePages()
                        }
                    case .lastSection:
                        self.test.endSection()
                        //Naviagate back to the user hompage
                        //UserHomepageView(user: self.user)
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
                            if self.test.currentSection!.sectionTimer.done == true{
                                self.test.endSection()
                            }
                            self.now = self.test.currentSection!.sectionTimer.timeLeftFormatted
                    }.foregroundColor(self.test.currentSection!.sectionTimer.timeRemaining < 10.0 ? .red : .black)
                }
                
            }
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
    @ObservedObject var user: User
    var body: some View {
        List(user.tests){test in
            NavigationLink(destination: TestView(testData: test)){
                Text(test.name)
            }.isDetailLink(false).frame(height: 90)
        }.navigationBarTitle(Text("Choose Test to Take"))
    }
}

struct StudyTable: View {
    @ObservedObject var user: User
    var body: some View {
        List{
            ForEach(user.tests ?? [], id: \.self){test in
                ForEach(test.sections, id: \.self){section in
                    NavigationLink(destination: TestView(testData: Test(testSections: [section], test: test))){
                        Text(" \(section.name) from \(test.name)")
                    }.isDetailLink(false).frame(height: 90)
                    
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





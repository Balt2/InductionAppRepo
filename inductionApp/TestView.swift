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
    @Binding var shouldPopToRootView : Bool
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
                            }.navigationBarItems(leading: self.testData.isFullTest == true ? AnyView(EndTestNavigationView(test: self.testData, shouldPopToRootFromNav: self.$shouldPopToRootView, submitComplete: false)) : AnyView(EmptyView()) ,
                                        trailing: TimerNavigationView(test: self.testData, shouldPopToRootView: self.$shouldPopToRootView))
                            
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
                CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", officialSub: "", tutorSub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), act: true, isActMath: false), page: self.model, isAnswerSheet: false, protoRect: CGRect(), canvasGeo: geo.size)
            }
        }
    }
}
//Helpful links: Alert  - https://www.hackingwithswift.com/books/ios-swiftui/showing-alert-messages
//Workaround for popToRootView - https://stackoverflow.com/questions/57334455/swiftui-how-to-pop-to-root-view

struct EndTestNavigationView: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: Test
    @State private var showAlert = false
    @Binding var shouldPopToRootFromNav: Bool
    var submitComplete: Bool
    var body: some View {
         Button(action: {
            self.showAlert = true
       }){
        Text(submitComplete == true ? "Submit" : "End Test")
            .foregroundColor(.red)
         }.alert(isPresented: $showAlert){
            Alert(title: Text(submitComplete == true ? "Submit Assessment" : "Are you sure you want to end the test?"),
                  message: Text("You will not be able to edit this \(test.isFullTest == true ? "test" : "assignment") again"),
                  primaryButton: .default(Text("Cancel")),
                  secondaryButton: .default(Text("OK")){
                    //self.presentationMode.wrappedValue.dismiss()
                    self.test.endTest(user: self.currentAuth.currentUser!) //TODO: Dont force
                    self.shouldPopToRootFromNav = false
                })
        }
        
    }

}

struct TimerNavigationView: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: Test
    @Binding var shouldPopToRootView : Bool
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
                        self.test.endSection(user: self.currentAuth.currentUser!)
                    case .betweenSection:
                        self.test.nextSection(fromStart: false)
                        if self.test.showAnswerSheet == true {
                            self.test.currentSection?.scalePages()
                        }
                    case .lastSection:
                        self.test.endSection(user: self.currentAuth.currentUser!)
                        //Naviagate back to the user hompage
                        //UserHomepageView(user: self.user)
                    case .testOver:
                        print("Should never get here")
                    }
                }){
                    HStack{
                        getControlButton(test: self.test, shouldPopToRootFromNav: self.$shouldPopToRootView)
                    }
                }
                
                //Shows time text
                
                if self.test.testState == .inSection
                    || self.test.testState == .lastSection {
                    Text("\(now) left")
                        .onReceive(timer) { _ in
                            if self.test.currentSection!.sectionTimer.done == true{
                                self.test.endSection(user: self.currentAuth.currentUser!)
                            }
                            self.now = self.test.currentSection!.sectionTimer.timeLeftFormatted
                    }.foregroundColor(self.test.currentSection!.sectionTimer.timeRemaining < 10.0 ? .red : .black)
                }
                
            }
        }
    }
    func getControlButton(test: Test, shouldPopToRootFromNav: Binding<Bool>) -> AnyView {
        
        switch self.test.testState{
        case .notStarted:
            if test.isFullTest == true {
                return AnyView(Text("Start Test"))
            }else{
                return AnyView(Text("Start Section"))
            }
        case .inSection: return AnyView(Text("End Section"))
        case .betweenSection: return AnyView(Text("Start Next Section"))
        case .lastSection:
            return AnyView(EndTestNavigationView(test: self.test, shouldPopToRootFromNav: $shouldPopToRootView, submitComplete: true))
//            if test.isFullTest == true {
//                return Text("End Test")
//            }else{
//                return Text("End Study Section")
//            }
        case .testOver:
            if test.isFullTest == true {
                return AnyView(Text("Test Over"))
            }else{
                return AnyView(Text("Study Section Over"))
            }
        }
    }
}

//Tables that are presented before the TestView
struct TestTable: View {
    @ObservedObject var user: User
    @Binding var rootIsActive: Bool
    var body: some View {
        List(user.tests){test in
            NavigationLink(destination: TestView(shouldPopToRootView: self.$rootIsActive, testData: test)){
                Text(test.name)
            }.isDetailLink(false).frame(height: 90)
        }.navigationBarTitle(Text("Choose Test to Take"))
    }
}

struct StudyTable: View {
    @ObservedObject var user: User
    @Binding var rootIsActive: Bool
    var body: some View {
        List{
            ForEach(user.tests ?? [], id: \.self){test in
                ForEach(test.sections, id: \.self){section in
                    NavigationLink(destination: TestView(shouldPopToRootView: self.$rootIsActive, testData: Test(testSections: [section], test: test))){
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





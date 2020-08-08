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
import Introspect
import MobileCoreServices

struct TestView: View {
    @State var shouldScroll: Bool = true
    @State var shouldScrollToTop: Bool = false
    @State var showSheet: Bool = true
    @State var neverUseIndex: Int = -1
    @Binding var shouldPopToRootView : Bool
    @ObservedObject var testData: Test
    @EnvironmentObject var currentAuth: FirebaseManager
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.black)
            VStack{
                HStack{
                    if testData.showAnswerSheet == true{
                        
                        List{
                            Section(header: Text("Section \(self.testData.currentSection!.sectionIndex + 1)")) {
                                ForEach(self.testData.currentSection!.questions, id: \.self){question in
                                    AnswerSheetRow(question: question, section: self.testData.currentSection!, actMath: self.testData.currentSection!.name == "Math" && self.testData.testType! == .act, shouldScroll: self.$shouldScroll, showPopUp: self.$shouldScroll, popUpQuestionIndex: self.$neverUseIndex)
                                }
                            }.disabled(!(self.testData.testState == .inSection || self.testData.testState == .lastSection ))
                            
                        }.frame(width: 300 + offset.width)
                            .gesture(self.shouldScroll == false ? nil : DragGesture()
                                .onChanged{gesture in
                                    print(gesture)
                                    //                                    if gesture.translation.width < 0{
                                    //                                        self.offset = CGSize(width: gesture.translation.width, height: 0)
                                    //                                    }else if gesture.translation.width > 15 && self.testData.showAnswerSheet == false{
                                    //                                        self.offset = CGSize(width: gesture.translation.width, height: 0)
                                    //                                    }//Conditions to bring it back.
                                    
                            }.onEnded{gesture in
                                
                                if gesture.predictedEndLocation.x < -100 {
                                    self.testData.showAnswerSheet = false
                                    self.testData.currentSection?.scalePages()
                                    
                                }
                                
                                //                                if gesture.translation.width < -150 {
                                //                                    self.offset = CGSize(width: -299, height: 0)
                                //                                    self.testData.showAnswerSheet = false
                                //                                }else if gesture.translation.width < 0{
                                //                                    self.offset = CGSize.zero
                                //                                }else if gesture.translation.width > 15 && self.testData.showAnswerSheet == false{
                                //                                    self.offset = CGSize.zero
                                //                                }
                                
                                })
                            
                            .offset(self.offset)
                            .introspectScrollView{tableView in
                                tableView.contentInsetAdjustmentBehavior = .always
                                if self.shouldScroll != tableView.isScrollEnabled{
                                    tableView.isScrollEnabled = self.shouldScroll
                                }
                                //print("Before Table Content Inset: \(tableView.contentInset)")
                                //print("Befeore TABLE CONTEENT OFFSET: \(tableView.contentOffset)")
                                //print("Before Table Adjected Content: \(tableView.adjustedContentInset)")
                                
                        }
                        
                    }
                    
                    
                    ScrollView() {
                        
                        VStack{
                            ForEach(self.testData.currentSection!.pages, id: \.self){ page in
                                PageView(model: page, section: self.testData.currentSection!).blur(radius: self.testData.begunTest ? 0 : 20)
                                    .disabled( !(self.testData.testState == .inSection || self.testData.testState == .lastSection ) )
                                
                            }.navigationBarItems(trailing: TimerNavigationView(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData, shouldPopToRootView: self.$shouldPopToRootView, showSheet: self.$showSheet))
                                .navigationBarBackButtonHidden(self.testData.timed && self.testData.begunTest)
                                //.foregroundColor(self.shouldScroll == true || self.shouldScrollToTop ? .none : .none) //Forground color modifier jusut to indicate to the view that shouldscroll is being looked at and the view should change.
                            
                            
                            
                        }
                    }.gesture(self.shouldScroll == false ? nil : DragGesture()
                        .onChanged{_ in
                            //Should be be changing locations and scaling?
                    }.onEnded(){gesture in
                        if self.testData.showAnswerSheet == false && gesture.predictedEndLocation.x > 400{
                            self.testData.showAnswerSheet = true
                            self.testData.currentSection?.scalePages()
                        }
                        }).introspectScrollView{scrollView in //In the future the scrollView should be made UIViewRepresentable
                            scrollView.contentInsetAdjustmentBehavior = .always
                            scrollView.isScrollEnabled = self.shouldScroll
                            if self.shouldScrollToTop == true{
                                scrollView.scrollToTop(adjustedContentOffset: scrollView.adjustedContentInset.top)
                                self.shouldScrollToTop = false
                            }
                    }
                    
                }
                
            }
        }
        .sheet(isPresented: self.$showSheet, onDismiss: {
            if self.testData.currentSectionIndex > 0 {
                self.testData.sendResultJson(user: self.currentAuth.currentUser!) //TODO: Dont force
                self.shouldPopToRootView = false
            }
        }){
            if self.testData.currentSectionIndex < 1{ //Should be test.bugan. TODO testData.begunTest
                MindsetView(presentView: self.$showSheet, test: self.testData, model: self.testData.testType!.getPreTestSurvey(), preTest: true, user: self.currentAuth.currentUser!, shouldPopToRoot: self.$shouldPopToRootView)
            }else{
                MindsetView(presentView: self.$showSheet, test: self.testData, model: self.testData.testType!.getPostTestSurvey(), preTest: false, user: self.currentAuth.currentUser!, shouldPopToRoot: self.$shouldPopToRootView)
            }
        }
            
    }
}





struct PageView: View{
    var model: PageModel
    var section: TestSection?
    
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        
        ZStack{
            Image(uiImage: self.model.uiImage).resizable().aspectRatio(contentMode: .fill)
            
            GeometryReader { geo in
                CanvasRepresentable(question: Question(q: QuestionFromJson(id: "", officialSub: "", tutorSub: "", answer: "", reason: ""), ip: IndexPath(row: 600, section: 600), testType: TestType(rawValue: "ACT")!, isActMath: false), page: self.model, section: self.section, isAnswerSheet: false, protoRect: CGRect(), canvasGeo: geo.size)
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
    @Binding var showSheet: Bool
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
                    self.showSheet = true
                    self.test.endTest()
                })
        }
        
    }
    
}

struct TimerNavigationView: View {
    @Binding var shouldScrollNav: Bool
    @Binding var shouldScrollToTopNav: Bool
    
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: Test
    @Binding var shouldPopToRootView : Bool
    @Binding var showSheet: Bool
    @State private var now = ""
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        
        HStack (spacing: 200){
            HStack {
                
                //Hand draw - Enables hand
                
                Button(action: {
                    self.shouldScrollNav.toggle()
                }){
                    Image(systemName: "hand.draw")
                        .foregroundColor(self.shouldScrollNav == true ? .gray : .blue)
                        .font(.title)
                    
                }.padding()
                //.disabled(currentAuth.pencilManager.isPencilAvailable)
                
                //Pencil Button - Enables the pencil
                Button(action: {
                    if self.test.isEraserEnabled == true{
                        self.test.isEraserEnabled = false
                    }
                }){
                    Image(systemName: "pencil")
                        .foregroundColor(self.test.isEraserEnabled == false ? .blue : .gray)
                        .font(.title)
                }.disabled(self.test.isEraserEnabled == false)
                    .padding()   
                
                
                //Eraser Button - Enables the eraser
                Button(action: {
                    if self.test.isEraserEnabled == false{
                        self.test.isEraserEnabled = true
                    }
                }){
                    
                    Image("SingleEraser")
                        .foregroundColor(self.test.isEraserEnabled == true ? .blue : .gray)
                        .font(.title)
                }.disabled(self.test.isEraserEnabled == true)
                    .padding()
                
                
                //Minus means minimize answer sheet. Plus means show it
                Button(action: {
                    self.test.showAnswerSheet.toggle()
                    self.test.currentSection?.scalePages()
                    
                }){
                    Image(systemName: self.test.showAnswerSheet == true ? "minus.circle" : "plus.circle")
                        .foregroundColor(.blue)
                        .font(.title)
                }.padding()
                
            }
            HStack {
                Button(action: {
                    switch self.test.testState{
                    case .notStarted:
                        self.test.startTest()
                    case .inSection:
                        self.shouldScrollToTopNav = true
                        self.test.endSection(user: self.currentAuth.currentUser!)
                    case .inBreak:
                        self.shouldScrollToTopNav = true
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
                        getControlButton(test: self.test, showSheet: self.$showSheet)
                    }
                }
                
                //Shows time text
                
                if (self.test.testState == .inSection
                    || self.test.testState == .lastSection || self.test.testState == .inBreak) && (self.test.timed == true) {
                    Text("\(now) left")
                        .onReceive(timer) { _ in
                            
                            if self.test.currentSection!.sectionTimer.done == true{
                                self.test.endSection(user: self.currentAuth.currentUser!)
                            }else if self.test.currentSection!.breakTimer.done == true{
                                self.test.nextSection(fromStart: false)
                            }
                            
                            if self.test.testState == .inBreak{
                                self.now = self.test.currentSection!.breakTimer.timeLeftFormatted
                            }else{
                                self.now = self.test.currentSection!.sectionTimer.timeLeftFormatted
                            }
                    }.foregroundColor(self.test.currentSection!.sectionTimer.timeRemaining < 10.0 ? .red : .black)
                }
                Spacer()
            }
        }
    }
    func getControlButton(test: Test, showSheet: Binding<Bool>) -> AnyView {
        
        switch self.test.testState{
        case .notStarted:
            if test.isFullTest == true {
                return AnyView(Text("Start Test"))
            }else{
                return AnyView(Text("Start Section"))
            }
        case .inSection: return AnyView(Text("End Section"))
        case .inBreak: return AnyView(Text("End Break, Next Section"))
        case .lastSection:
            return AnyView(EndTestNavigationView(test: self.test, showSheet: $showSheet, submitComplete: true))
            
            
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
    @State var showPicker = false
    @State var showErrorPDF = false
    
    var body: some View {
        List(user.tests){test in
            if self.user.testRefsMap[test.testFromJson!.testRefName] == false{
                Button(action: {
                    self.showPicker.toggle()
                }){
                    Text("Download: \(test.name)").frame(minWidth: 0, maxWidth: .infinity).frame(height: 90).background(Color.gray)
                }.sheet(isPresented: self.$showPicker){
                    DocumentPicker(testRefString: test.testFromJson!.testRefName, user: self.user, showErrorPDF: self.$showErrorPDF)
                }.alert(isPresented: self.$showErrorPDF) {
                    Alert(title: Text("You uploaded the wrong test PDF"),
                          message: Text("Please upload the correct PDF for the chosen test."),
                          dismissButton: .default(Text("OK")))
                }
                    
                
            }else{
//                Button(action: {
//                    self.showMindsetSheet = true
//                }){
//                    Text(test.name)
//                }.frame(height: 90)
//                    .sheet(isPresented: self.$showMindsetSheet){
//                    MindsetView()
//                }
                
                NavigationLink(destination: TestView(shouldPopToRootView: self.$rootIsActive, testData: test)){
                    Text(test.name)
                    }.isDetailLink(false).frame(height: 90)
            }
        }.navigationBarTitle(Text("Choose Test to Take"))
    }
}

struct StudyTable: View {
    @ObservedObject var user: User
    @Binding var rootIsActive: Bool
    var body: some View {
        List{
            ForEach(user.tests, id: \.self){test in
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

extension UIScrollView {
    func scrollToTop(adjustedContentOffset: CGFloat) {
        //Adjusted Contentoffset is the distance the navigation bar takes up
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top - adjustedContentOffset)
        setContentOffset(desiredOffset, animated: true)
    }
}

struct DocumentPicker: UIViewControllerRepresentable{
    var testRefString: String
    var user: User
    @Binding var showErrorPDF: Bool
    func makeCoordinator() -> Coordinator {
        return DocumentPicker.Coordinator(parent1: self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .open)
        //kUTYPEITEM - Anything
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(parent1: DocumentPicker){
            parent = parent1
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if "\(parent.testRefString).pdf" == urls[0].lastPathComponent{
                parent.user.uploadedTestPDF(testRef: parent.testRefString){b in
                    print("UPdated testRefMap: \(b)")
                }
            }else{
                print("WRONG PDF UPLOADED")
                parent.showErrorPDF = true
            }
            
            print(urls)
            print(urls[0].baseURL)
            print(urls[0].lastPathComponent)
            //This is where we upload and do all that stuff.
        }
    }
    
    
}


//struct TestView_Previews: PreviewProvider {
//    static let tests = TestList()
//    static var previews: some View {
//        TestView(, testData: <#Test#>).environmentObject(tests)
//    }
//}





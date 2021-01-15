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

//The test view displays the test
struct TestView: View {
    //Should the test and answer sheet be scrollable or not. If not, the user can draw with finger
    @State var shouldScroll: Bool = true
    //Used to instruct the UICollectionView to scroll to the top after a section is finished
    @State var shouldScrollToTop: Bool = false
    //Used to determine if the pre or post test module sheets should show up.
    @State var showSheet: Bool = true
    //End of test alert
    @State var showAlert: Bool = false
    //Dummy variable that is used to have the screen re-draw itself. could probably be gotten rid
    @State var neverUseIndex: Int = -1
    //Boolean value telling you if the pre survey has been submitted. If it has then when showSheet = true, the post survey will show.
    @State var preSurveySubmitted: Bool = false
    //If you should leave the test
    @Binding var shouldPopToRootView : Bool
    //Actual data for test
    @ObservedObject var testData: Test
    //Has login and user information from firebase
    @EnvironmentObject var currentAuth: FirebaseManager
    //Used for the offset of the answer sheet. This is used if drag is re-implemented
    @State private var offset = CGSize.zero
    //Used to re-draw the screen when the user flips the orientation of the screen
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(.black)
            VStack{
                HStack{
                    //DISPLAYS THE ANSWER SHEET
                    if testData.showAnswerSheet == true{
                        
                        List{
                            //SECTION HEADER TELLING YOU WAHT THE CURRENT SECTION IS
                            Section(header: Text("Section \(self.testData.currentSection!.sectionIndex + 1)")) {
                                //LOOOP THROUGH EACH SECTION OF THE TEST
                                ForEach(self.testData.currentSection!.questions, id: \.self){question in
                                    //CREATE INSTANCE OF ANSWER SHEET ROW
                                    AnswerSheetRow(question: question, section: self.testData.currentSection!, actMath: self.testData.currentSection!.name == "Math" && self.testData.testType! == .act, shouldScroll: self.$shouldScroll, showPopUp: self.$shouldScroll, popUpQuestionIndex: self.$neverUseIndex)
                                }
                                //LOGIC TO DISABLE DRAWING ON THE ANSWER SHEET IF THE USER IS NOT IN A SECTION OR THEY HAVE SUUBMITED THE LAST SECTION
                            }.disabled(!(self.testData.testState == .inSection || self.testData.testState == .lastSection ))
                            
                        }.frame(width: 300 + offset.width)
                        //DRAG LOGIC. NEEDS TO BE REFINED
//                            .gesture(self.shouldScroll == false ? nil : DragGesture()
//                                .onChanged{gesture in
//                                    print(gesture)
//                                    //                                    if gesture.translation.width < 0{
//                                    //                                        self.offset = CGSize(width: gesture.translation.width, height: 0)
//                                    //                                    }else if gesture.translation.width > 15 && self.testData.showAnswerSheet == false{
//                                    //                                        self.offset = CGSize(width: gesture.translation.width, height: 0)
//                                    //                                    }//Conditions to bring it back.
//
//                            }.onEnded{gesture in
//
//                                if gesture.predictedEndLocation.x < -100 {
//                                    self.testData.showAnswerSheet = false
//                                    self.testData.currentSection?.scalePages()
//
//                                }
//
//                                //                                if gesture.translation.width < -150 {
//                                //                                    self.offset = CGSize(width: -299, height: 0)
//                                //                                    self.testData.showAnswerSheet = false
//                                //                                }else if gesture.translation.width < 0{
//                                //                                    self.offset = CGSize.zero
//                                //                                }else if gesture.translation.width > 15 && self.testData.showAnswerSheet == false{
//                                //                                    self.offset = CGSize.zero
//                                //                                }
//
//                                })
                            
                        .offset(self.shouldScroll ? self.offset : self.offset)
                            .introspectScrollView{tableView in
                                
                                tableView.contentInsetAdjustmentBehavior = .always
                                print("SHOULD SCROLL?")
                                print(self.shouldScroll)
                                if self.shouldScroll == false {
                                    tableView.panGestureRecognizer.minimumNumberOfTouches = 2
                                }else{
                                    tableView.panGestureRecognizer.minimumNumberOfTouches = 1
                                }
//                                if self.shouldScroll != tableView.isScrollEnabled{
//                                    tableView.isScrollEnabled = self.shouldScroll
//                                }
                                
                                //print("Before Table Content Inset: \(tableView.contentInset)")
                                //print("Befeore TABLE CONTEENT OFFSET: \(tableView.contentOffset)")
                                //print("Before Table Adjected Content: \(tableView.adjustedContentInset)")
                                
                        }
                        
                    }
                    //COLLECTION VIEW THAT PRESENTS THE TEST PAGES. WE USE A COLLECTION VIEW REPRESENTABLE SO THAT WE HAVE MORE CONTROL OVER HOW THE VIEW ACTS (SCROLLING TO TOP, DRAWING WITH FINER)
                    CollectionViewRepresentable(test: self.testData, twoFingerScroll: self.$shouldScroll, scrollToTop: self.$shouldScrollToTop)
                        .disabled(!(self.testData.testState == .inSection || self.testData.testState == .lastSection ))
                        //WE HAVE BLUR BEFORE THE TEST BEGINS
                        .blur(radius: self.testData.begunTest == false ? 30 : 0.0)
                        //THESE ITEMS INCLUDE THE SECTION TIMER AND BUTTONS TO GO THE NEXT SECTION
                        .navigationBarItems(trailing: TimerNavigationView(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData, shouldPopToRootView: self.$shouldPopToRootView, showAlert: self.$showAlert, showSheet: self.$showSheet))
                        //HIDE BACK BUTTON ONCE THEY HAVE BEGUN THE TEST
                        .navigationBarBackButtonHidden(self.testData.timed && self.testData.begunTest)
                        .opacity(orientationInfo.orientation.rawValue == "BEN" ? 1.0 : 1.0)
                        
                        
                    
                }
                
            }.blur(radius: (!self.showSheet) ? 0 : 50.0) //TODO: Add a loading if they finish //self.testData.loadedPDFIn && 
        }
    
        .sheet(isPresented: self.$showSheet, onDismiss: {
            //THEY HAVE FINSIHED THE TEST
            if self.testData.currentSectionIndex > 0 {
                self.testData.sendResultJson(user: self.currentAuth.currentUser!) //TODO: Dont force
                self.shouldPopToRootView = false
                
            }else{
                //THE HAVE JUST SUBMITED THE PRE-TEST MODULE
                if !self.testData.loadedPDFIn {
                    self.preSurveySubmitted = true
                    self.showSheet = true
                }else{
                    self.preSurveySubmitted = false
                }
            }
        }){
            if self.testData.currentSectionIndex < 1{ //Should be test.bugan. TODO testData.begunTest
                //DISPLAY PRE-TEST MODULE
                MindsetView(presentView: self.$showSheet, test: self.testData, model: self.testData.preTestMindset!, preTest: true, user: self.currentAuth.currentUser!, shouldPopToRoot: self.$shouldPopToRootView, surveySubmitted: self.$preSurveySubmitted)
            }else{
                //POST TEST MODULE
                MindsetView(presentView: self.$showSheet, test: self.testData, model: self.testData.postTestMindset!, preTest: false, user: self.currentAuth.currentUser!, shouldPopToRoot: self.$shouldPopToRootView, surveySubmitted: self.$preSurveySubmitted)
            }
        }.alert(isPresented: self.$showAlert){
                if self.testData.begunTest == true {
                    return Alert(title: Text("Are you sure you want to end the test?"),
                      message: Text("You will not be able to edit this \(testData.isFullTest == true ? "test" : "assignment") again"),
                      primaryButton: .default(Text("Cancel")),
                      secondaryButton: .default(Text("OK")){
                        self.showSheet = true
                        self.testData.endTest()
                    })
                }else{
                    return Alert(title: Text("Once you start the test you can’t pause or quit"),
                      message: Text("Are you ready to take the test?"),
                      primaryButton: .default(Text("Cancel")),
                      secondaryButton: .default(Text("Yes")){
                        self.testData.startTest()
                    })
                }
        }
        
    }
}






//RE-USABLE STRUCTURE USED FOR EACH PAGE
struct PageView: View{
    var model: PageModel
    var section: TestSection?
    
    @State private var canvas: PKCanvasView = PKCanvasView()
    
    var body: some View {
        
        //DISPLAYS ONE PAGE
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

//THE VIEW THAT APPEARS WHEN THE USER
struct EndTestNavigationView: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: Test
    @Binding var showAlert: Bool
    var submitComplete: Bool
    var body: some View {
        Button(action: {
            self.showAlert = true
        }){
            Text(submitComplete == true ? "Submit" : "End Test")
                .foregroundColor(.red)
        }
    }
    
}

//VIEW THAT CONTAINS ALL THE BUTTONS AND VIEW FOR TIMING
struct TimerNavigationView: View {
    //VALUE THAT DETERMINED IF THE VIEWS SHOULD BE SCROLLALABLE (OR NTO SO PEOPLE CAN DRAW WITH THEIR FINGER)
    @Binding var shouldScrollNav: Bool
    //SAME AS TESTVIEW
    @Binding var shouldScrollToTopNav: Bool
    
    //SAME AST TESTVIEW
    @EnvironmentObject var currentAuth: FirebaseManager
    //DATA FOR TEST
    @ObservedObject var test: Test
    //IF THE VIEW SHOULD CHANGE
    @Binding var shouldPopToRootView : Bool
    //TIME
    @State private var now = ""
    @Binding var showAlert: Bool
    @Binding var showSheet: Bool
    //WE DISABLE THE BUTTON FOR 5 SECONDS AFTER A SECTION HAS BEGUN
    @State var disableButton: Bool = false
    //START THE TIMMER
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
//                Button(action: {
//                    self.test.showAnswerSheet.toggle()
//                    self.test.currentSection?.scalePages()
//
//                }){
//                    Image(systemName: self.test.showAnswerSheet == true ? "minus.circle" : "plus.circle")
//                        .foregroundColor(.blue)
//                        .font(.title)
//                }.padding()
                
            }
            HStack {
                //ACTION OF BUTTON THE FAR RIGHT
                Button(action: {
                    
                    //DISABLE BUTTON IMMIDAILTLY WHEN IT IS PRESSED SO IT CANT BE TWICED BY ACCIDENT
                    self.disableButton = true
                    switch self.test.testState{
                    case .notStarted:
                        self.showAlert = true
                        //self.test.startTest()
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
                        print("Test over")
                    }
                    self.disableButton = false
                    
                }){
                    
                    HStack{
                        //DETERMINE WHAT THE BUTTON SAYS
                        getControlButton(test: self.test, showSheet: self.$showSheet)
                    }
                }.disabled(self.disableButton || self.test.currentSection!.sectionTimer.fourSecondIn) //()!
                
                //Shows time text
                //LOGIC FOR TIMER
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
    //LOGIC FOR WHAT THE RIGHT HAND BUTTON SAYS
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
            return AnyView(EndTestNavigationView(test: self.test, showAlert: $showAlert, submitComplete: true))
            
            
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
    @State var isActiveF = false
    @State var sectionDict: [TestType: [Test]]
    
    var body: some View {
        //ORDER ALL THE TESTS THE USER CAN TAKE
        List{
            //LOOPING OVER ALL USERS TESTS
            ForEach(self.getOrderedKeys(), id: \.self){key in
                Section(header: Text(key.rawValue)){
                    ForEach(self.sectionDict[key]!){test in
                        //DETERMINING IF THE USER HAS "DOWNLOADED" THE TEST OR NOT
                        if self.user.testRefsMap.dict[test.testFromJson!.testRefName] == false{
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
                            //IF THE HAVE DOWNLAODED THE TEST THEN IF THEY CLICK A SPECIFIC TEST IT WILL SEND THEM TO THE TEST VIEW WITH THAT TEST AS THE TESTDATA
                            NavigationLink(destination: TestView(shouldPopToRootView: self.$rootIsActive, testData: test)){
                                Text(test.name)
                            }.isDetailLink(false).frame(height: 90)
                        }
                    }
                }.opacity(self.user.testRefsMap.dict == [:] ? 1.0 : 1.0)
            }
        }.navigationBarTitle(Text("Choose Test to Take"))
        
    }
    
    func getOrderedKeys() -> [TestType]{
        var newList = Array(sectionDict.keys)
        newList = newList.sorted(by: {$0.rawValue < $1.rawValue})
        return newList
    }
    
}

//NEEDS TO BE UPDATED WHEN STUDY IS IMPLEMENTED
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

//NOT IMPLMENTED FULLY
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
//STRUCTURE TO PICK A DOCUMENT FROM THE USERS FILES. MOSTLY COPIED FROM OTHER SOURCES.
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
                
                //A Hack to re-draw the view
                parent.showErrorPDF = true
                parent.showErrorPDF = false
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





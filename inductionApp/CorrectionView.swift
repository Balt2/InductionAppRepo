//
//  CorrectionView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 6/15/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//



import SwiftUI
import PencilKit
import Combine
import Introspect

struct CorrectionView: View {
    @State var shouldScroll: Bool = true
    @State var shouldScrollToTop: Bool = false
    @ObservedObject var testData: ACTFormatedTestData
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
                                    AnswerSheetRow(question: question, section: self.testData.currentSection!, actMath: self.testData.currentSection!.name == "Math" && self.testData.act == true, disabled: question.finalState == .right)
                                }
                            }.disabled(!(self.testData.testState == .inSection || self.testData.testState == .lastSection ))

                        }.frame(width: 300 + offset.width)
                            .gesture(self.shouldScroll == false ? nil : DragGesture()
                                .onChanged{gesture in
                                    print(gesture)

                            }.onEnded{gesture in
                                print("END")
                                print(gesture)

                                if gesture.predictedEndLocation.x < -100 {
                                    self.testData.showAnswerSheet = false
                                    self.testData.currentSection?.scalePages()

                                }
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
                    
                    //Text("DNAIEL")
                    ScrollView() {
                        VStack{
                            ForEach(self.testData.currentSection!.pages, id: \.self){ page in
                                PageView(model: page, section: self.testData.currentSection!)

                            }
                                .foregroundColor(self.shouldScroll == true || self.shouldScrollToTop ? .none : .none) //Forground color modifier jusut to indicate to the view that shouldscroll is being looked at and the view should change.


                        }.navigationBarItems(leading: EmptyView(),
                        trailing: CorrectionNavigationBar(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData))
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
    }
}




//Helpful links: Alert  - https://www.hackingwithswift.com/books/ios-swiftui/showing-alert-messages
//Workaround for popToRootView - https://stackoverflow.com/questions/57334455/swiftui-how-to-pop-to-root-view


struct CorrectionNavigationBar: View {
    @Binding var shouldScrollNav: Bool
    @Binding var shouldScrollToTopNav: Bool
    
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: ACTFormatedTestData
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
                        .font(self.shouldScrollNav == true ? .title : .largeTitle)
                    
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
                        .font(self.test.isEraserEnabled == false ? .largeTitle : .title)
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
                        .font(self.test.isEraserEnabled == true ? .largeTitle : .title)
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
                        self.shouldScrollNav = true
                        self.test.endSection(user: self.currentAuth.currentUser!)
                    case .inBreak:
                        self.shouldScrollToTopNav = true
                        self.test.nextSection(fromStart: false)
                        if self.test.showAnswerSheet == true {
                            self.test.currentSection?.scalePages()
                        }
                    case .betweenSection:
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
                    getControlButton(test: self.test).padding(.trailing, 15)
                }
            }
        }
    }
    func getControlButton(test: Test) -> AnyView {
        
        switch self.test.testState{
        case .notStarted:
            if test.isFullTest == true {
                return AnyView(Text("Start Test"))
            }else{
                return AnyView(Text("Start Section"))
            }
        case .inSection: return AnyView(Text("End Section"))
        case .inBreak: return AnyView(Text("End Break, Next Section"))
        case .betweenSection: return AnyView(Text("Start Next Section"))
        case .lastSection:
            return AnyView(Text("Last Section"))
            
        case .testOver:
            if test.isFullTest == true {
                return AnyView(Text("Test Over"))
            }else{
                return AnyView(Text("Study Section Over"))
            }
        }
    }
}





//struct CorrectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CorrectionView()
//    }
//}

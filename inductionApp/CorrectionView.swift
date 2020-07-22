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
    @Binding var shouldScroll: Bool
    @Binding var shouldScrollToTop: Bool
    
    @Binding var showPopUp: Bool
    @State var popUpQuestionIndex: Int = 0
    
    @ObservedObject var testData: ACTFormatedTestData
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(self.shouldScrollToTop ? .black : .black)
            
            VStack{
                HStack{
                    if testData.showAnswerSheet == true{

                        List{
                            Section(header: Text("Section \(self.testData.currentSection!.sectionIndex + 1)")) {
                                ForEach(self.testData.currentSection!.questions, id: \.self){question in
                                    AnswerSheetRow(question: question, section: self.testData.currentSection!, actMath: self.testData.currentSection!.name == "Math" && self.testData.act == true, disabled: true, shouldScroll: self.$shouldScroll, showPopUp: self.$showPopUp, popUpQuestionIndex: self.$popUpQuestionIndex)
//                                    .onTapGesture {
//                                            print("CORRECTION CELL TAPPED")
//                                            self.popUpQuestionIndex = question.location.row
//                                            self.togglePopUp(showPopUp: true)
//                                        print(self.showPopUp)
//                                    }
                                }
                            }

                        }.frame(width: 300 + offset.width)
                            
//                            .gesture(self.shouldScroll == false ? nil : DragGesture()
//                                .onChanged{gesture in
//                                    print(gesture)
//
//                            }.onEnded{gesture in
//
//                                if gesture.predictedEndLocation.x < -100 {
//                                    self.testData.showAnswerSheet = false
//                                    self.testData.currentSection?.scalePages()
//
//                                }
//                            })

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
                                PageView(model: page, section: self.testData.currentSection!)

                            }


                        }
                    }.onTapGesture {
                        if self.showPopUp == true{
                            self.togglePopUp(showPopUp: false)
                        }
                    }.introspectScrollView{scrollView in //In the future the scrollView should be made UIViewRepresentable
                            scrollView.contentInsetAdjustmentBehavior = .always
                            scrollView.isScrollEnabled = self.shouldScroll
                            if self.shouldScrollToTop == true{
                                scrollView.scrollToTop(adjustedContentOffset: scrollView.adjustedContentInset.top)
                                self.shouldScrollToTop = false
                        }
                    }
                }
            }
            if self.showPopUp {
                ZStack {
                    Color.white
                    ScrollView(.vertical) {
                        Text("Question \(popUpQuestionIndex + 1)")
                        Spacer()
                        HStack{
                            Text("Your Answer: \(self.testData.currentSection!.questions[popUpQuestionIndex].userAnswer)")
                            Text("Time to Answer: \(self.testData.currentSection!.questions[popUpQuestionIndex].secondsToAnswer)")
                        }
                        Spacer()
                        HStack{
                            Text("Correct Answer: \(self.testData.currentSection!.questions[popUpQuestionIndex].answer)")
                            Text("Order of Answer: \(self.testData.currentSection!.questions[popUpQuestionIndex].secondsToAnswer)")
                        }
                        Spacer()
                        Text("Official Sub Section: \(self.testData.currentSection!.questions[popUpQuestionIndex].officialSub)")
                        Spacer()
                        if testData.act == false{
                            Text(self.testData.currentSection!.questions[popUpQuestionIndex].reason).lineLimit(nil)
                        }
                        
                    }.padding()
                }
                .frame(width: 700, height: 400)
                .cornerRadius(20).shadow(radius: 25)
            .offset(x: 120, y: 0)
            }
        }
       
    }
    
    func togglePopUp(showPopUp: Bool){
        self.shouldScroll = !showPopUp
        self.showPopUp = showPopUp
    }
}




//Helpful links: Alert  - https://www.hackingwithswift.com/books/ios-swiftui/showing-alert-messages
//Workaround for popToRootView - https://stackoverflow.com/questions/57334455/swiftui-how-to-pop-to-root-view


struct CorrectionNavigationBar: View {
    @Binding var shouldScrollNav: Bool
    @Binding var shouldScrollToTop: Bool
    @Binding var showPopUp: Bool
    
    @EnvironmentObject var currentAuth: FirebaseManager
    @ObservedObject var test: ACTFormatedTestData

    
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
                ForEach(self.test.sections, id: \.self){section in
                    Button(action:{
                        self.showPopUp = false
                        self.shouldScrollNav = true
                        self.shouldScrollToTop = true
                        self.test.setCorrectionTestView(index: section.sectionIndex)
                    }){
                        Text(section.name)
                    }.disabled(self.test.currentSectionIndex == section.sectionIndex)
                }
            }
        }
    }
}







//struct CorrectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CorrectionView()
//    }
//}

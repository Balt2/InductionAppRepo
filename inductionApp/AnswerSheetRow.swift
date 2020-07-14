//
//  AnswerSheetRow.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import PencilKit



struct AnswerSheetRow: View {
    
   //@State private var canvas: PKCanvasView = PKCanvasView()
    @ObservedObject var question: Question
    @ObservedObject var section: TestSection
    var xStepper: CGFloat = CGFloat(54.0)
    var actMath: Bool
    var disabled: Bool = false //is it for correction view? if true it is
    @Binding var shouldScroll: Bool
    @Binding var showPopUp: Bool
    @Binding var popUpQuestionIndex: Int
    
    
    
    var body: some View {
        
        ZStack{
            GeometryReader { geo in
                Group{
                   
                    
                    
                    if self.actMath == true && self.question.answer.count == 1 {
                        Group{
                            self.showAnswerButton()
                            Text(String(self.question.location.row + 1))
                            .frame(width: 25, height: 10, alignment: .trailing)
                            .position(CGPoint(x: 10, y: geo.size.height / 2))
                                
                            
                            
                            
                            Group{
                                Text(self.question.answerLetters[0]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper, y: geo.size.height / 4.37))
                                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper, y: geo.size.height/1.5))

                                Text(self.question.answerLetters[1]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 41, y: geo.size.height / 4.37))
                                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 41, y: geo.size.height/1.5))

                                Text(self.question.answerLetters[2]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 82, y: geo.size.height / 4.37))
                                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 82, y: geo.size.height/1.5))

                                Text(self.question.answerLetters[3]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 123, y: geo.size.height / 4.37))
                                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 123, y: geo.size.height/1.5))
                                
                                Text(self.question.answerLetters[4]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 164, y: geo.size.height / 4.37))
                                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 164, y: geo.size.height/1.5))
                            }
                        }
                    }else if self.question.freeResponse == false{
                        Group{
                            self.showAnswerButton()
                               Text(String(self.question.location.row + 1))
                               .frame(width: 25, height: 10, alignment: .trailing)
                               .position(CGPoint(x: 10, y: geo.size.height / 2))
                            
                            
                            Text(self.question.answerLetters[0]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[1]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 55, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 55, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[2]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 110, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 110, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[3]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 165, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 165, y: geo.size.height/1.5))
                        }
                    }else{
                        self.showAnswerButton()
                        SatFreeResponse(question: self.question, section: self.section, disabled: self.disabled)
                    }
                    
                }
                
                if (self.question.currentState == .invalidSelection && self.disabled == false){
                    Image(systemName: "nosign").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.red)
                }else if (self.question.freeResponse == false && self.disabled == false)  {
                    Text(self.question.userAnswer).frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }
                
                if self.disabled == false && self.question.freeResponse == false{
                    CanvasRepresentable(question: self.question, page: PageModel(image: UIImage(), pageID: -1), section: self.section, isAnswerSheet: true, protoRect: CGRect(x: 20, y: 20, width: (self.actMath == true ? 40 : 54), height: geo.size.height/1.5), canvasGeo: CGSize())
                }
                
                if self.disabled == true && self.question.freeResponse == false{
                    if self.question.finalState == .right {
                        Image(systemName: "checkmark.circle").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.green)
                    }else if self.question.finalState == .wrong{
                        Image(systemName: "xmark.circle").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.red)
                    }else{
                        Image(systemName: "nosign").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.gray)
                    }
                }
                
            }

        }.frame(width: 270, height: self.question.freeResponse == false ? 80 : 530)
    }
    
    func showAnswerButton() -> AnyView {
        if self.disabled == true {
            return AnyView(
                Button(action: {
                    self.shouldScroll = false
                    self.showPopUp = true
                    self.popUpQuestionIndex = self.question.location.row
                }){
                    Text(self.question.freeResponse ? "" : "Show Answer").lineLimit(2).foregroundColor(Color.blue).font(.system(size: 13.0))
                }.frame(width: 50, alignment: .trailing)
                    .position(CGPoint(x: 7, y: 11))
            )
        }else{
            return AnyView(EmptyView())
        }
        
    }
}

struct SatFreeResponse: View {
    
    @ObservedObject var question: Question
    @ObservedObject var section: TestSection
    var disabled: Bool
    
    @State var firstCircle = ""
    @State var secondCircle = ""
    @State var thirdCircle = ""
    @State var fourthCicle = ""
    var symbols = ["/", ".", "0", "1", "2", "3", "4", "5",
    "6", "7", "8", "9"]
    

    var body: some View {
        VStack{
            HStack(spacing: 0){
                Text(String(question.location.row + 1)).padding(.trailing, 15)
                ZStack{
                    Rectangle().stroke()
                    Text(self.disabled ? question.userAnswer[0] : firstCircle).font(.system(size: 20))
                }
                ZStack{
                    Rectangle().stroke()
                    Text(self.disabled ? question.userAnswer[1] : secondCircle).font(.system(size: 20))
                }
                ZStack{
                    Rectangle().stroke()
                    Text(self.disabled ? question.userAnswer[2] : thirdCircle).font(.system(size: 20))
                }
                ZStack{
                    Rectangle().stroke()
                    Text(self.disabled ? question.userAnswer[3] : fourthCicle).font(.system(size: 20))
                }
                if self.disabled == true{
                    if self.question.finalState == .right {
                        Image(systemName: "checkmark.circle").frame(width: 20, height: 20).foregroundColor(.green).padding(.leading, 5)
                    }else if self.question.finalState == .wrong{
                        Image(systemName: "xmark.circle").frame(width: 20, height: 20).foregroundColor(.red).padding(.leading, 5)
                    }else{
                        Image(systemName: "nosign").frame(width: 20, height: 20).foregroundColor(.gray).padding(.leading, 5)
                    }
                }
            }.frame(width: 270, height: 50)
            HStack{
                VStack(){
                    ForEach(symbols, id: \.self){symbol in
                        Group{
                            Text(symbol).font(.body).fontWeight(.regular).frame(width: 10, height: 15).padding([.top, .bottom], 11.5)
                        }
                    }
                }
                Group{
                    VStack {
                        ForEach(symbols, id: \.self){symbol in
                            Circle().fill(symbol == "/" ? Color.clear : Color.black).opacity(self.firstCircle == symbol ? 1.0 : 0.01).overlay(Circle().stroke(symbol == "/" ? Color.clear : Color.black)).onTapGesture {
                                self.firstCircle = symbol
                                self.questionAnswered()
                            }.frame(width: 30, height: 30)
                        }
                    }.padding([.leading, .trailing], 10)
                    VStack {
                        ForEach(symbols, id: \.self){symbol in
                            Circle().fill(Color.black).opacity(self.secondCircle == symbol ? 1.0 : 0.01).overlay(Circle().stroke(Color.black)).onTapGesture {
                                self.secondCircle = symbol
                                self.questionAnswered()
                               }.frame(width: 30, height: 30)
                        }
                    }.padding([.leading, .trailing], 10)
                    VStack {
                        ForEach(symbols, id: \.self){symbol in
                            Circle().fill(Color.black).opacity(self.thirdCircle == symbol ? 1.0 : 0.01).overlay(Circle().stroke(Color.black)).onTapGesture {
                                self.thirdCircle = symbol
                                self.questionAnswered()
                               }.frame(width: 30, height: 30)
                        }
                    }.padding([.leading, .trailing], 10)
                    VStack{
                        ForEach(symbols, id: \.self){symbol in
                            Circle().fill(symbol == "/" ? Color.clear : Color.black).opacity(self.fourthCicle == symbol ? 1.0 : 0.01).overlay(Circle().stroke(symbol == "/" ? Color.clear : Color.black)).onTapGesture {
                                self.fourthCicle = symbol
                                self.questionAnswered()
                                
                            }.frame(width: 30, height: 30)
                        }
                    }.padding([.leading, .trailing], 10)
                }.disabled(self.disabled)
            }.frame(width: 270)
        }.frame(width: 270)
        
    }
    
    func questionAnswered(){
        question.userAnswer = self.firstCircle + self.secondCircle + self.thirdCircle + self.fourthCicle
        question.currentState = .selected
        question.secondsToAnswer += section.sectionTimer.timeDelta
        
        //Logic to set the order Answered in. The numbers will have jumps
        //but the order will represent the correct order based on erasing as well
        section.numAnsweredQuestions += 1
        question.answerOrdredIn += section.numAnsweredQuestions
    }
}





//struct AnswerSheetRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
////            AnswerSheetRow().previewLayout(.fixed(width: 300, height: 70))
////            AnswerSheetRow().previewLayout(.fixed(width: 300, height: 70))
//        }
//    }
//}


extension String{
    func getQuestionIndex() -> Int{
        if self == "A" || self == "F" {
            return 0
        } else if self == "B" || self == "G" {
            return 1
        } else if self == "C" || self == "H" {
            return 2
        } else {
            return 3
        }
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


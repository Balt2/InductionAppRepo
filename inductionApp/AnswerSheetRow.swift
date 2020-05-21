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
    
    
    var body: some View {
        
        ZStack{
            GeometryReader { geo in
                Group{
                   
                    Text(String(self.question.location.row + 1))
                        .frame(width: 25, height: 10, alignment: .trailing)
                        .position(CGPoint(x: 10, y: geo.size.height / 2))
                    
//                    ForEach(0..<self.question.answerLetters.count, id: \.self) { letter in
//
//                        Group{
//                            Text(self.question.answerLetters[letter]).frame(width: 15, height: 10, alignment: .center)
//                                .position(CGPoint(x: self.xStepper * letter  , y: geo.size.height / 4.37))
//
//                            Circle().stroke().frame(width: 20, height: 20)
//                                .position(CGPoint(x: self.xStepper * letter  , y: geo.size.height/1.5))
//                                .onAppear(){
//                                    print(54 + 55 * letter)
//                                    //self.xStepper = self.xStepper + CGFloat(55)
//                                    //print(CGFloat(self.question.answerLetters.firstIndex(of: String(letter))!))
//                            }
//                        }
//
//
//                    }
                    
                    if self.actMath == true {
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
                    }else{
                        Group{
                            Text(self.question.answerLetters[0]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[1]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 55, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 55, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[2]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 110, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 110, y: geo.size.height/1.5))
        
                            Text(self.question.answerLetters[3]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: self.xStepper + 165, y: geo.size.height / 4.37))
                            Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: self.xStepper + 165, y: geo.size.height/1.5))
                        }
                    }
                    
                }
                
                if(self.question.currentState == .invalidSelection){
                    Image(systemName: "nosign").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.red)
                }else {
                    Text(self.question.userAnswer).frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }
                
                CanvasRepresentable(question: self.question, page: PageModel(image: UIImage(), pageID: -1), section: self.section, isAnswerSheet: true, protoRect: CGRect(x: 20, y: 20, width: 54, height: geo.size.height/1.5), canvasGeo: CGSize())
                
            }

        }.frame(width: 270, height: 80)
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


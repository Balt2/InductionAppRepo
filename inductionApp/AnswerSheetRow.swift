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
    
    //@ObservedObject var test: Test
    
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
//                            Text(String(letter)).frame(width: 15, height: 10, alignment: .center)
//                                .position(CGPoint(x: 5, y: geo.size.height / 4.37))
//
//                            Circle().stroke().frame(width: 20, height: 20)
//                                .position(CGPoint(x: 54 , y: geo.size.height/1.5))
//                        }
//
//                    }
                    
                    Text(self.question.answerLetters[0]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 54, y: geo.size.height / 4.37))
                    Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 54, y: geo.size.height/1.5))

                    Text(self.question.answerLetters[1]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 109, y: geo.size.height / 4.37))
                    Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 109, y: geo.size.height/1.5))

                    Text(self.question.answerLetters[2]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 163, y: geo.size.height / 4.37))
                    Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 163, y: geo.size.height/1.5))

                    Text(self.question.answerLetters[3]).frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 217, y: geo.size.height / 4.37))
                    Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 217, y: geo.size.height/1.5))
                }
                
                if(self.question.currentState == .invalidSelection){
                    Image(systemName: "nosign").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.red)
                }else {
                    Text(self.question.userAnswer).frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }
                
                CanvasRepresentable(question: self.question, page: PageModel(image: UIImage(), pageID: -1), section: self.section, isAnswerSheet: true, protoRect: CGRect(x: 20, y: 20, width: 54, height: geo.size.height/1.5))
                
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


//
//  AnswerSheetRow.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI
import PencilKit



struct AnswerSheetRow: View {
    
   //@State private var canvas: PKCanvasView = PKCanvasView()
    @ObservedObject var question: Question
    
    var body: some View {
        ZStack{
           
            Group{
                Text(String(question.location.row + 1)).frame(width: 20, height: 10, alignment: .center).position(CGPoint(x: 10, y: 40))
                
                Text("A").frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 54, y: 18.3))
                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 54, y: 53.3))
                
                Text("B").frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 109, y: 18.3))
                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 109, y: 53.3))
                
                Text("C").frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 163, y: 18.3))
                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 163, y: 53.3))
                
                Text("D").frame(width: 15, height: 10, alignment: .center).position(CGPoint(x: 217, y: 18.3))
                Circle().stroke().frame(width: 20, height: 20).position(CGPoint(x: 217, y: 53.3))
            }
            
            if(question.currentState == .invalidSelection){
                Image(systemName: "nosign").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40)).foregroundColor(.red)
            }else if (question.userAnswer != nil){
                if question.userAnswer == "0" {
                    Text("A").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }else if question.userAnswer == "1" {
                    Text("B").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }
                else if question.userAnswer == "2" {
                    Text("C").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }else{
                    Text("D").frame(width: 20, height: 20).position(CGPoint(x: 250, y: 40))
                }
                
            }
            
            CanvasRepresentable(question: question, isAnswerSheet: true)

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


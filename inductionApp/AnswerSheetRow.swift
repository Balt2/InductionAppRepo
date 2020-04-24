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
    
   @State private var canvas: PKCanvasView = PKCanvasView()
    @ObservedObject var question: Question
    
    var body: some View {
        ZStack{
           
           
            HStack {
                HStack(alignment: .bottom) {
                    Text(String(question.location.row + 1))
                    Spacer()
                    VStack {
                        Text("A")
                        Circle()
                            .stroke()
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    VStack {
                        Text("B")
                        Circle()
                            .stroke()
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    VStack {
                        Text("C")
                        Circle()
                            .stroke()
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    VStack {
                        Text("D")
                        Circle()
                            .stroke()
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                }
                Spacer()
                if (question.currentState == .invalidSelection){
                    Image(systemName: "nosign").foregroundColor(.red)
                } else if (question.userAnswer != nil){
                    Text("\(question.userAnswer!)")
                }
                //Image(systemName: "checkmark.circle")
                Spacer()
            }
            CanvasRepresentable(canvasToDraw: $canvas, question: question, isAnswerSheet: true)
        }
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


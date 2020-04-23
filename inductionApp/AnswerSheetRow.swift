//
//  AnswerSheetRow.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI



struct AnswerSheetRow: View {
    
   // var answerCell: AnswerCell
    
    var body: some View {
        HStack {
            HStack(alignment: .bottom) {
                Text("1")
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
            Image(systemName: "checkmark.circle")
            Spacer()
        }
    }
}


struct AnswerSheetRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnswerSheetRow().previewLayout(.fixed(width: 300, height: 70))
            AnswerSheetRow().previewLayout(.fixed(width: 300, height: 70))
        }
    }
}


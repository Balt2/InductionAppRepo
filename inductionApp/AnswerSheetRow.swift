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
        VStack{

            
            HStack{
                Text("A")
                Spacer()
                Text("B")
                Spacer()
                Text("C")
                Spacer()
                Text("D")
            }.padding()
            HStack {
                Circle().stroke().frame(width: 20, height: 20 )
                Spacer()
                Circle().stroke().frame(width: 20, height: 20 )
                Spacer()
                Circle().stroke().frame(width: 20, height: 20 )
                Spacer()
                Circle().stroke().frame(width: 20, height: 20 )
            }.padding()
        }.frame(height: 70)
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

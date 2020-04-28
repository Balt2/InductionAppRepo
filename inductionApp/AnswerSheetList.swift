//
//  AnswerSheetList.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct AnswerSheetList: View {
    @ObservedObject var test: Test
    
    var body: some View {
        GeometryReader { g in
            List {
                Section(header: Text("Section 1")) {
                    ForEach(self.test.questions[0], id: \.self){ question in
                        AnswerSheetRow(question: question)
                    }
                    
                }.disabled( self.test.currentSection != 0 || self.test.begunTest == false )
                Section(header: Text("Section 2")) { //Section(header: TimerHeader(timer: self.test.timers[1], text: "Section 2")){
                    ForEach(self.test.questions[1], id: \.self){ question in
                        AnswerSheetRow(question:question)
                    }
                }.disabled(self.test.currentSection != 1)
                Section(header: Text("Section 3")) {// Section(header: TimerHeader(timer: self.test.timers[2], text: "Section 3")){
                    ForEach(self.test.questions[2], id: \.self){ question in
                        AnswerSheetRow(question:question)
                    }
                } .disabled(self.test.currentSection != 2)
                Section(header: Text("Section 4")) {//Section(header: TimerHeader(timer: self.test.timers[3], text: "Section 4")){
                    ForEach(self.test.questions[3], id: \.self){ question in
                        AnswerSheetRow(question:question)
                        
                    }
                }.disabled(self.test.currentSection != 3)
            }
        }
    }
}






struct AnswerSheetList_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSheetList(test: Test(jsonFile: "test1json", pdfFile: "pdf_sat-practice-test-1"))
    }
}

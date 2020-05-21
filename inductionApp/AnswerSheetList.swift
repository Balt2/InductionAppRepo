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
                
                ForEach(self.test.sections, id: \.self){ section in
                    Section(header: Text("Section \(section.sectionIndex + 1)")){
                        ForEach(section.questions, id: \.self){ question in
                            AnswerSheetRow(question: question, section: section, actMath: section.name == "Math" && self.test.act == true)
                        }
                    }.disabled( self.test.begunTest == false
                        || self.test.taken == true
                        || self.test.currentSection!.begunSection == false
                        || self.test.currentSection!.sectionOver == true
                        || self.test.currentSection != section) //If any of these conditions are true we disable

                }
                
                
//                Section(header: Text("Section 1")) {
//                    ForEach(self.test.sections[0].questions, id: \.self){ question in
//                        AnswerSheetRow(question: question)
//                    }
//
//                }.disabled( self.test.currentSectionIndex != 0 || self.test.begunTest == false )
//                Section(header: Text("Section 2")) { //Section(header: TimerHeader(timer: self.test.timers[1], text: "Section 2")){
//                    ForEach(self.test.sections[1].questions, id: \.self){ question in
//                        AnswerSheetRow(question:question)
//                    }
//                }.disabled(self.test.currentSectionIndex != 1)
//                Section(header: Text("Section 3")) {// Section(header: TimerHeader(timer: self.test.timers[2], text: "Section 3")){
//                    ForEach(self.test.sections[2].questions, id: \.self){ question in
//                        AnswerSheetRow(question:question)
//                    }
//                }.disabled(self.test.currentSectionIndex != 2)
//                Section(header: Text("Section 4")) {//Section(header: TimerHeader(timer: self.test.timers[3], text: "Section 4")){
//                    ForEach(self.test.sections[3].questions, id: \.self){ question in
//                        AnswerSheetRow(question:question)
//
//                    }
//                }.disabled(self.test.currentSectionIndex != 3)
            }
        }
    }
}






struct AnswerSheetList_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSheetList(test: Test(jsonFile: "satPracticeTest1", pdfFile: "pdf_sat-practice-test-1"))
    }
}

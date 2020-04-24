//
//  AnswerSheetList.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI

struct AnswerSheetList: View {
    @ObservedObject var test: Test
    var body: some View {
        List {
            Section(header: Text("Section 1")) {
                ForEach(test.questions[0], id: \.self){ question in
                    AnswerSheetRow(question:question)
                }
                
            }
            Section(header: Text("Section 2")){
                ForEach(test.questions[1], id: \.self){ question in
                    AnswerSheetRow(question:question)
                }
            }
            Section(header: Text("Section 3")){
                ForEach(test.questions[2], id: \.self){ question in
                    AnswerSheetRow(question:question)
                }
            }
            Section(header: Text("Section 4")){
                ForEach(test.questions[3], id: \.self){ question in
                    AnswerSheetRow(question:question)
                }
            }
        }
    }
}

struct AnswerSheetList_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSheetList(test: Test(jsonFile: "test1json"))
    }
}

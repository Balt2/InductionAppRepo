//
//  AnswerSheetList.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI

struct AnswerSheetList: View {
    var body: some View {
        List {
            Section(header: Text("Section 1")) {
                AnswerSheetRow()
                AnswerSheetRow()
                AnswerSheetRow()
            }
        }
    }
}

struct AnswerSheetList_Previews: PreviewProvider {
    static var previews: some View {
        AnswerSheetList()
    }
}

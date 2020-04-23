//
//  StackAnswer.swift
//  InductionApp
//
//  Created by Josh Breite on 4/22/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI

struct StackAnswer: View {
    var body: some View {
        VStack {
            Text("A")
            Circle()
                .stroke()
                .frame(width: 20, height: 20)
        }
    }
}


struct StackAnswer_Previews: PreviewProvider {
    static var previews: some View {
        StackAnswer()
    }
}

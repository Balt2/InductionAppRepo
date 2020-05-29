//
//  PastPerformanceView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct PastPerformanceView: View {
    var body: some View {
        GeometryReader{geometry in
            ScrollView() {
                VStack{
                    Text("NEXT CHART")
                    
                    Text("NEXT...")
                    Text("BENJAMIN")
                    BarChart().frame(width: geometry.size.width * 0.9)
//                    BarChart().frame(width: geometry.size.width * 0.9)
                    Rectangle().frame(height: 50)
                    Rectangle().foregroundColor(.green)
                }
            }
        }
    }
}

struct PastPerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        PastPerformanceView()
    }
}

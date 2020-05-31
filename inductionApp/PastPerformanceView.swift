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
            ScrollView(.vertical) {
                VStack{
                    Spacer()
                    Text("RESULTS").font(.system(.largeTitle)).foregroundColor(.red)
                    BarChart().frame(width: geometry.size.width * 0.9, height: (geometry.size.width) / 2.0) //2 is the aspect ratio
                    BarChart().frame(width: geometry.size.width * 0.9, height: (geometry.size.width) / 2.0)
                    ScatterChart().frame(width: geometry.size.width * 0.9, height: (geometry.size.width) / 2.0)
                    
                }.frame(maxWidth: .infinity)
            }
        }
    }
}

struct PastPerformanceView_Previews: PreviewProvider {
    static var previews: some View {
        PastPerformanceView()
    }
}

//
//  BarGraphViews.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/19/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import Foundation
import SwiftUI

enum SectionName: Int, CaseIterable, Hashable, Identifiable {
    case overall = 0
    case reading
    case writing
    case math
    case science
    
    var name: String {
        return "\(self)".capitalized
    }

    var id: SectionName {self}
}


enum Days: CaseIterable, Hashable, Identifiable {
    
    case CSE
    case POW
    case KOL
    
    case KID
    case IK
    case CS
    
    case IES
    case Alg
    case Geom
    case Func
    case Modeling
    case NQ
    
    case IOD
    case SI
    case EM
    
    case ACT1
    case ACT2
    case ACT3
    
    
    var shortName: String {
        return String("\(self)".prefix(4)).capitalized
    }
    var id: Days {self}
    
}



struct BarContentView: View {
    
    @State var pickerSelectedItem = 0
    
    @State var data: [(dayPart: SectionName, caloriesByDay: [(day:Days, calories:Int)])] =
        [
                (
                    SectionName.overall,
                        [
                            (Days.ACT1, 28),
                            (Days.ACT2, 34),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.reading,
                        [
                            (Days.ACT1, 28),
                            (Days.ACT2, 32),
                            (Days.ACT3, 35)
                        ]
                ),
                (
                    SectionName.writing,
                        [
                            (Days.ACT1, 26),
                            (Days.ACT2, 33),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.math,
                        [
                            (Days.ACT1, 25),
                            (Days.ACT2, 34),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.science,
                        [
                            (Days.ACT1, 30),
                            (Days.ACT2, 32),
                            (Days.ACT3, 36)
                        ]
                )
                
        ]

    
    
    
    var body: some View {
        ZStack {
            
            
            VStack {
                
                Text("Quick Data")
                    .foregroundColor(Color("lightBlue"))
                    .font(.system(size: 34))
                    .fontWeight(.heavy)
                
                Picker(selection: $pickerSelectedItem.animation(), label: Text("")) {
                   ForEach(SectionName.allCases) { dp in
                        Text(dp.name).tag(dp.rawValue)
                    }
                    
                    
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    .animation(.default)
                
                 
              HStack (spacing: 10) {
                     ForEach(0..<self.data[pickerSelectedItem].caloriesByDay.count, id: \.self)
                     { i in
                      
                        BarView(
                            value: self.data[self.pickerSelectedItem].caloriesByDay[i].calories,
                            label: self.data[self.pickerSelectedItem].caloriesByDay[i].day.shortName
                        )
                     
                     }
                
              }.padding(.top, 24)
               .animation(.default)
                
                
            }//vs
        }//zs
        
    }
}


struct BarView:  View {
    
    var value: Int
    var label: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 30, height: 216)
                    .foregroundColor(Color("lightBlue"))
                Capsule().frame(width: 30, height: CGFloat(value*6))
                    .foregroundColor( Color("salmon"))
            }
            Text(label)
                .padding(.top,8)
        }
    }
}


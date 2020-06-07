//
//  BarGraphView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct ACTFormatedTestData: Hashable, Identifiable{
    
    static func == (lhs: ACTFormatedTestData, rhs: ACTFormatedTestData) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    
    var overall: BarEntry //BarEntry(xLabel: date, yEntries: ([height: overallScore], orange)
    //var overallTime: BarEntry //BarEntry(xLabel: date, yEntries: ([height: time], orange)
    var sectionsOverall: [String: BarEntry] //(SectionName, Entry for the section)
    var subSectionGraphs: [String: BarData] //(SectionName, BarData)
    //var subSectionTime: [(String, BarData)]
}

struct BarData: Hashable, Identifiable{
    static func == (lhs: BarData, rhs: BarData) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = UUID()
    var title: String
    var xAxisLabel: String
    var yAxisLabel: String
    var yAxisSegments: Int
    var yAxisTotal: Int
    var barEntries: [BarEntry]
    
}

struct BarEntry: Hashable, Identifiable, Equatable{
    static func == (lhs: BarEntry, rhs: BarEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var xLabel: String
    var yEntries: [(height: CGFloat, color: Color)]
    var index: Int?
}

struct BarChart: View {
    //var width: CGFloat = 1000
    @Binding var showDetailTest : Bool
    @Binding var detailDataIndex: Int?
    var ar: CGFloat = 2
    let data: BarData
    var barChart: Bool
//        BarData(title: "ACT Performance by Data", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [
//        BarEntry(xLabel: "Date 1", yEntries: [(height: 30, color: Color.green), (height: 4, color: Color.red), (height: 2, color: Color.gray) ]),
//        BarEntry(xLabel: "Date 2", yEntries: [(height: 20, color: Color.green), (height: 15, color: Color.red), (height: 1, color: Color.gray) ]),
//        BarEntry(xLabel: "Date 3", yEntries: [(height: 15, color: Color.green), (height: 0, color: Color.red), (height: 21, color: Color.gray) ]),
//        BarEntry(xLabel: "Date 4", yEntries: [(height: 12, color: Color.green), (height: 12, color: Color.red), (height: 12, color: Color.gray) ])
//    ])
    
    var body: some View {
            ZStack{ //Whole backgoruund of graph
                Color("lightBlue")
                
                    
                    HStack{ //HSTACK FOR GRAPH TO PLACE Y-AXIS
                        Text(self.data.yAxisLabel)
                            .rotationEffect(Angle(degrees: -90), anchor: .trailing)
                            .font(.system(.subheadline))
                            .padding(.trailing, 15)
                        Spacer()
                        VStack{ //VSTACK FOR GRAPH TO PLACE TITLE, BARS, AND X-AXIS LABEL
                            Text(self.data.title)
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .medium , design: .rounded))
                                .padding([.top, .bottom], 20)
                            ZStack(){ //ZSTSCK FOR GRID AND BAR VIEWS
                                Grid(data: self.data)
                                if self.barChart == true {
                                    HStack{
                                        GeometryReader{innerGeometry in
                                            ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                                
                                                BarShape(barEntry: self.data.barEntries[i], yAxisTotal: self.data.yAxisTotal)
                                                    .frame(width: innerGeometry.size.width / CGFloat(self.data.barEntries.count), height: innerGeometry.size.height, alignment: .center)
                                                    .offset(x: self.offsetHelper(width: innerGeometry.size.width, index: i), y: 0)
                                                .onTapGesture() {
                                                    print(i)
                                                    print("Taped")
                                                    print(self.data.barEntries[i].xLabel)
                                                    print(self.data.barEntries[i].index)
                                                    if self.data.barEntries[i].index != nil{
                                                        
                                                        self.detailDataIndex = self.data.barEntries[i].index
                                                        print(self.detailDataIndex)
                                                        self.showDetailTest = true
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    HStack{
                                        GeometryReader{innerGeometry in
                                            ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                                Circle().fill(self.data.barEntries[i].yEntries[0].color).frame(width: (innerGeometry.size.width / CGFloat(self.data.barEntries.count)) * 0.5, height: (innerGeometry.size.width / CGFloat(self.data.barEntries.count)) * 0.5, alignment: .center)
                                                    .offset(x: self.widthOffsetHelper(width: innerGeometry.size.width, index: i), y: (innerGeometry.size.height - (((self.data.barEntries[i].yEntries[0].height) / CGFloat(self.data.yAxisTotal)) * innerGeometry.size.height)) - (innerGeometry.size.width / CGFloat(self.data.barEntries.count)) * 0.25)
                                                
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }.frame(width: UIScreen.main.bounds.width * 0.85, height: ((UIScreen.main.bounds.width * 0.85 )/self.ar) * 0.75, alignment: .bottom)
                                .padding([.top, .bottom], 0)
                            Text(self.data.xAxisLabel).font(.system(.subheadline)).padding([.top, .bottom], 10)
                        }.frame(width: UIScreen.main.bounds.width * 0.85)
                            .padding([.trailing, .leading], 15)
                    }.padding([.leading], 15)
                
            }.cornerRadius(20.0).aspectRatio(self.ar, contentMode: .fit).padding([.leading, .trailing], 30)
    }
    
    func offsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth
    }
    
    func widthOffsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth + (offsetWidth * 0.25)
    }
    
    
}


struct Grid: View {
    var data: BarData
    var body: some View{
        GeometryReader{geometry in
            self.createGridLines(geometry: geometry.size).stroke(Color.gray)
            VStack{
                ForEach( (0...self.data.yAxisSegments).reversed(), id: \.self){i in
                    Group{
                        Text(self.getYAxisLabel(i: i))
                        if i != 0{
                            Spacer()
                        }
                    }
                }
            }.padding([.top, .bottom], -10).padding(.leading, self.paddingHelp() )
            HStack{
                ForEach(0..<self.data.barEntries.count, id: \.self){i in
                    Group{
                        Text(self.data.barEntries[i].xLabel)
                        if i != self.data.barEntries.count - 1 {
                            Spacer()
                        }
                    }
                }
            }.offset(x: 0, y: geometry.size.height).padding([.leading, .trailing], (geometry.size.width / CGFloat(self.data.barEntries.count))*0.40)
        }
    }
    
    func getYAxisLabel(i: Int) -> String{
        let label = (CGFloat(i) / CGFloat(self.data.yAxisSegments)) * CGFloat(self.data.yAxisTotal)
        return String(Int(label))
    }
    
    func paddingHelp() -> CGFloat{
        if data.yAxisTotal < 100{
            return -25
        }else if data.yAxisTotal >= 100 {
            return -40
        }else if data.yAxisTotal >= 1000{
            return -55
        }
        return 0
    }
    
    func createGridLines(geometry: CGSize) -> Path{
        var path = Path()
        
        //Horizontal bars
        for i in (0...data.yAxisSegments){
            let yLoc = CGFloat(i) * (geometry.height / CGFloat(data.yAxisSegments) )
            path.move(to: CGPoint(x: 0, y: yLoc))
            path.addLines([CGPoint(x: 0, y: yLoc), CGPoint(x: geometry.width, y: yLoc)])
        }
        
        
        ///Vertical Bars
        //Y-Axis left
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLines([CGPoint(x: 0, y: 0), CGPoint(x: 0, y: geometry.height)])
        //Lines on bar
        
        
        for (index, barEntry) in data.barEntries.enumerated() {
            let xLoc = (2.0 * CGFloat(index) * geometry.width + geometry.width) / (2.0 * CGFloat(self.data.barEntries.count))
            path.move(to: CGPoint(x: xLoc, y: 0))
            path.addLines([CGPoint(x: xLoc, y: 0), CGPoint(x: xLoc, y: geometry.height)])
        }
        
        //Y-Axis Right
        path.move(to: CGPoint(x: geometry.width, y: 0))
        path.addLines([CGPoint(x: geometry.width, y: 0), CGPoint(x: geometry.width, y: geometry.height)])
        
        // path.move(to: CGPoint(x: CGFloat(barEntry.index) * (geometry.width / CGFloat( self.barEntrys.count)) + geometry.width / CGFloat(self.barEntrys.count * 2), y: 0)) X calculation the same, but simplified
        return path
    }
    
    
}

struct BarShape: View {
    var barEntry: BarEntry
    var yAxisTotal: Int
    var body: some View {
        
        VStack(alignment: .center){
            GeometryReader{geometry in
                
                ForEach(0..<self.barEntry.yEntries.count, id: \.self) { i in
                    self.createStackRect(startHeight: self.heightHelper(maxHeight: geometry.size.height, index: i - 1), endHeight: self.heightHelper(maxHeight: geometry.size.height, index: i), width: geometry.size.width * 0.9).fill(self.barEntry.yEntries[i].color).rotationEffect(Angle(degrees: 180))
                        .transformEffect(CGAffineTransform(translationX: -geometry.size.width * 0.05, y: 0))
                        .opacity(0.85)
                }
                
            }
        }
    }
    
    func createStackRect(startHeight: CGFloat, endHeight: CGFloat, width: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0 , y: startHeight))
        path.addRoundedRect(in: CGRect(x: 0, y: startHeight, width: width, height: endHeight - startHeight), cornerSize: CGSize(width: 5.0, height: 7.0))
        return path
    }
    
    
    
    func heightHelper (maxHeight: CGFloat, index: Int, height: CGFloat = 0.0) -> CGFloat{
        
        if index == -1 {
            return 0
        }else{
            let nextHeight = height + ((self.barEntry.yEntries[index].height) / CGFloat(self.yAxisTotal)) * maxHeight
            if index == 0 {
                return nextHeight
            }else{
                return heightHelper(maxHeight: maxHeight, index: index - 1, height: nextHeight)
            }
        }
        
    }
    
    
}




//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarChart().previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
//    }
//}


//
//  BarGraphView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

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

struct BarEntry: Hashable, Identifiable{
    static func == (lhs: BarEntry, rhs: BarEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var xLabel: String
    var yEntries: [(height: CGFloat, color: Color)]
}

struct BarChart: View {
    //var width: CGFloat = 1000
    var ar: CGFloat = 2
    
    //    let entries = [
    //        BarEntry(xLabel: "Date 1", yEntries: [(height: 0.5, color: Color.green), (height: 0.4, color: Color.red), (height: 0, color: Color.gray) ]),
    //        BarEntry(xLabel: "Date 2", yEntries: [(height: 0.2, color: Color.green), (height: 0.8, color: Color.red), (height: 0, color: Color.gray) ]),
    //        BarEntry(xLabel: "Date 3", yEntries: [(height: 0.3, color: Color.green), (height: 0.5, color: Color.red), (height: 0.2, color: Color.gray) ]),
    //        BarEntry(xLabel: "Date 4", yEntries: [(height: 0.3, color: Color.green), (height: 0.1, color: Color.red), (height: 0.6, color: Color.gray) ])
    //    ]
    let data = BarData(title: "ACT Performance by Data", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "Date 1", yEntries: [(height: 0.5, color: Color.green), (height: 0.4, color: Color.red), (height: 0, color: Color.gray) ]),
        BarEntry(xLabel: "Date 2", yEntries: [(height: 0.2, color: Color.green), (height: 0.8, color: Color.red), (height: 0, color: Color.gray) ]),
        BarEntry(xLabel: "Date 3", yEntries: [(height: 0.3, color: Color.green), (height: 0.5, color: Color.red), (height: 0.2, color: Color.gray) ]),
        BarEntry(xLabel: "Date 4", yEntries: [(height: 0.3, color: Color.green), (height: 0.1, color: Color.red), (height: 0.6, color: Color.gray) ])
    ])
    
    //    var title: String = "ACT Performance by Date"
    //    let data = [ BarEntry(xLabel: "Date 1", yEntries: [0.5, 0.4, 0.0], index: 0), BarEntry(xLabel: "Date 2", yEntries: [0.2, 0.8, 0.0], index: 1), BarEntry(xLabel: "Date 3", yEntries: [0.3, 0.5, 0.2], index: 2), BarEntry(xLabel: "Date 4", yEntries: [0.3, 0.1, 0.6], index: 3)]
    //    let perfect: CGFloat = 36
    
    var body: some View {
        VStack{
            GeometryReader{geometry in
                ZStack{ //Whole backgoruund of graph
                    Color("lightBlue")
                    HStack{
                        Text(self.data.yAxisLabel)
                            .rotationEffect(Angle(degrees: -90))
                            .font(.system(.title))
                            .padding(.leading, -15)
                            .padding(.trailing, 10)
                        VStack{
                            Spacer(minLength: 25)
                            Text(self.data.title)
                                .foregroundColor(.white)
                                .font(.system(size: 30, weight: .medium , design: .rounded))
                            Spacer(minLength: 25)
                            ZStack(){
                                Grid(data: self.data)
                                HStack{
                                    
                                    GeometryReader{innerGeometry in
                                        ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                            BarShape(barEntry: self.data.barEntries[i])
                                                .frame(width: innerGeometry.size.width / CGFloat(self.data.barEntries.count), height: innerGeometry.size.height, alignment: .center)
                                                .offset(x: self.offsetHelper(width: innerGeometry.size.width, index: i), y: 0)
                                                .onTapGesture {
                                                    print("Taped")
                                                    print(self.data.barEntries[i].xLabel)
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                
                            }.frame(width: geometry.size.width * 0.9, height: (geometry.size.width/self.ar) * 0.75, alignment: .bottom)
                                .padding([.top, .bottom], 0)
                            Spacer()
                            Spacer()
                            Text(self.data.xAxisLabel).font(.system(.title))
                            Spacer()
                        }.frame(width: geometry.size.width * 0.9)
                    }
                }.cornerRadius(20.0) //.frame(width: geometry.size.width) //.aspectRatio(self.ar, contentMode: .fit)
            }
        }
    }
    
    func offsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth
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
            }.offset(x: 0, y: geometry.size.height + 10).padding([.leading, .trailing], (geometry.size.width / CGFloat(self.data.barEntries.count))*0.40)
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
    //var colors = [Color.green, Color.red, Color.gray]
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
        }else if index == 0 {
            return height + barEntry.yEntries[index].height * maxHeight
        }else{
            return  heightHelper(maxHeight: maxHeight, index: index - 1, height: height + barEntry.yEntries[index].height * maxHeight)
        }
        
    }
    
    
    
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BarChart().previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
    }
}

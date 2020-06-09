//
//  BarGraphView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI


struct BarChart: View {
    @Binding var showDetailTest : Bool
    @Binding var allDataTestIndex: Int
    var ar: CGFloat = 2
    let data: BarData
    var barChart: Bool
    
    @State var zStackWidth: CGFloat = 0
    
    var body: some View {
        ZStack{ //Whole backgoruund of graph
            Color("lightBlue")
            
            
            HStack(spacing: 0){
                Text(self.data.yAxisLabel)
                    .rotationEffect(Angle(degrees: -90))
                    .font(.system(.subheadline))
                VStack{ //VSTACK FOR GRAPH TO PLACE TITLE, BARS, AND X-AXIS LABEL
                    Text(self.data.title)
                        .foregroundColor(.white)
                        .font(.title)
                        .padding([.top, .bottom], 10)
                    
                    VStack(spacing: 0){
                        HStack(spacing: 0){
                            YAXisLabelView(data: self.data).padding([.top, .bottom], -10).padding(.trailing, 10)
                            ZStack{ //ZSTSCK FOR GRID AND BAR VIEWS
                                GeometryReader{zStackGeo in
                                    Grid(data: self.data).onAppear(){
                                        self.zStackWidth = zStackGeo.size.width
                                    }
                                if self.barChart == true {
                                    HStack{
                                        GeometryReader{innerGeometry in
                                            ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                                
                                                BarShape(barEntry: self.data.barEntries[i], yAxisTotal: self.data.yAxisTotal)
                                                    .frame(width: innerGeometry.size.width / CGFloat(self.data.barEntries.count), height: innerGeometry.size.height, alignment: .center)
                                                    .offset(x: self.offsetHelper(width: innerGeometry.size.width, index: i), y: 0)
                                                    .onTapGesture() {
                                                        if self.data.barEntries[i].index != nil{
                                                            self.allDataTestIndex = self.data.barEntries[i].index!
                                                            self.showDetailTest = true
                                                            print(zStackGeo.size)
                                                            
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
                                
                                }
                        }
                        }
                        XAxisLabelView(barEntries: self.data.barEntries).frame(width: zStackWidth)
                    }.frame(height: ((UIScreen.main.bounds.width * 0.85 )/self.ar) * 0.75, alignment: .bottom)
                    Text(self.data.xAxisLabel).font(.system(.subheadline))
                }.padding([.trailing, .leading], 15)
                    .padding(.bottom, 25)
            }
            
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

struct XAxisLabelView: View{
    var barEntries: [BarEntry]
    var labelJump: Int{
        return ((barEntries.count) / 25 + 1)
    }
    var body: some View{
        HStack{
            Spacer()
            ForEach(self.getStride(), id: \.self){i in
                Group{
                    Spacer()
                    Text(self.barEntries[i].xLabel).multilineTextAlignment(.center).minimumScaleFactor(1.00).frame(maxWidth: .infinity, alignment: .center).lineLimit(3)
                    if i < self.barEntries.count - self.labelJump {
                        Spacer()
                    }
                }
            }
        }
    }
    func getStride() -> [Int] {
        return Array(stride(from: 0, to: barEntries.count, by: labelJump ))
    }
}

struct YAXisLabelView: View{
    var data: BarData
    var body: some View{
        VStack{
            
            ForEach((0...self.data.yAxisSegments).reversed(), id: \.self){i in
                Group{
                    Text(self.getYAxisLabel(i: i))
                    if i != 0{
                        Spacer()
                    }
                }
            }
        }
    }
    
    func getYAxisLabel(i: Int) -> String{
        let label = (CGFloat(i) / CGFloat(data.yAxisSegments)) * CGFloat(data.yAxisTotal)
        return String(Int(label))
    }
    
}
struct Grid: View {
    var data: BarData
    var body: some View{
        GeometryReader{geometry in
            self.createGridLines(geometry: geometry.size).stroke(Color.gray)
        }
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


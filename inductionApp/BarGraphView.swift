//
//  BarGraphView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct HorizontalBarChart: View {
    var ar: CGFloat = 2
    let data: BarData
    let gridHeight = ((UIScreen.main.bounds.width * 0.85 )/2) * 0.75 //2 is the AR

    var body: some View{
        ZStack{
            Color("lightBlue")
            HStack(spacing: 0){
                HStack(spacing: 20) {
                    YAXisLabelView(data: self.data, scale: false).padding(.bottom, -15)
                }.frame(height: self.gridHeight).padding([.trailing, .leading], 0)
                
                VStack{
                    Text(self.data.title)
                    .foregroundColor(.white)
                    .font(.title)
                    .padding([.top, .bottom], 10)
                    ZStack{
                        //Grid(data: self.data, horizontal: true)
                        VStack{
                            GeometryReader{innerGeometry in
                                ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                   BarShape(barEntry: self.data.barEntries[i], yAxisTotal: self.data.yAxisTotal)
                                    .frame(width: innerGeometry.size.width / CGFloat(self.data.barEntries.count), height: innerGeometry.size.height, alignment: .center)
                                    .offset(x: 0, y: self.offsetHelper(width: innerGeometry.size.height, index: i))
                                }
                            }
                        }
                    }
                }
            }
        }
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

struct BarChart: View {
    @Binding var showDetailTest : Bool
    @Binding var allDataTestIndex: Int
    var ar: CGFloat = 2
    let data: BarData
    var barChart: Bool
    let gridHeight = ((UIScreen.main.bounds.width * 0.85 )/2) * 0.75 //2 is the AR
    
    
    var body: some View {
        ZStack{ //Whole backgoruund of graph
            Color("lightBlue")
            
                VStack{ //VSTACK FOR GRAPH TO PLACE TITLE, BARS, AND X-AXIS LABEL
                    Text(self.data.title)
                        .foregroundColor(.white)
                        .font(.title)
                        .padding([.top, .bottom], 10)
                    HStack{
                        Text(self.data.yAxisLabel)
                        .rotationEffect(Angle(degrees: -90), anchor: .trailing)
                        .font(.system(.subheadline))
                        Grid(data: self.data, horizontal: true, showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, barChart: self.barChart).padding(.leading, 50).padding(.trailing, 10)
                }.padding([.trailing], 15)
                    .padding(.bottom, 25)
            }
            
        }.cornerRadius(20.0).frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.475)
            .aspectRatio(self.ar, contentMode: .fit).padding([.leading, .trailing], 30)
    }
    
}

struct XAxisLabelView: View{
    var data: BarData
    var scale: Bool //true if xaxisView holdsnames of bar data or just numbers (x or y axis). True = typical y-axis data
    var labelJump: Int{
        return ((data.barEntries.count) / 25 + 1)
    }
    
    var body: some View{
        HStack{
            ForEach(self.getStride(), id: \.self){i in
                Group{
                    Text(self.getAxisLabel(i: i)).minimumScaleFactor(0.40).frame(maxWidth: .infinity, alignment: .center).multilineTextAlignment(.center).lineLimit(3).fixedSize(horizontal: false, vertical: true)//.rotationEffect(Angle(degrees: 45))
                    if i < self.data.barEntries.count - self.labelJump {
                        Spacer()
                    }
                }
            }
        }
    }
    
    func getAxisLabel(i: Int) -> String{
        if scale == true{
            let label = (CGFloat(i) / CGFloat(data.yAxisSegments)) * CGFloat(data.yAxisTotal)
            return String(Int(label))
        }else{
            return self.data.barEntries[i].xLabel
        }
        
    }
    
    func getStride() -> [Int] {
        if scale == true{
            return ((0...self.data.yAxisSegments).reversed())
        }else{
            return Array(stride(from: 0, to: data.barEntries.count, by: labelJump))
        }
    }
}

struct YAXisLabelView: View{
    var data: BarData
    var scale: Bool
    var labelJump: Int{
        return ((data.barEntries.count) / 25 + 1)
    }
    
    var body: some View{
        VStack{
            ForEach(self.getStride(), id: \.self){i in
                Group{
                    Text(self.getAxisLabel(i: i))
                    if i != 0{
                        Spacer()
                    }
                }
            }
        }
    }
    
    func getAxisLabel(i: Int) -> String{
           if scale == true{
               let label = (CGFloat(i) / CGFloat(data.yAxisSegments)) * CGFloat(data.yAxisTotal)
               return String(Int(label))
           }else{
               return self.data.barEntries[i].xLabel
           }
           
       }
       
       func getStride() -> [Int] {
           if scale == true{
               return ((0...self.data.yAxisSegments).reversed())
           }else{
               return Array(stride(from: 0, to: data.barEntries.count, by: labelJump))
           }
       }
    
}
struct Grid: View {
    var data: BarData
    var horizontal: Bool
    @Binding var showDetailTest : Bool
    @Binding var allDataTestIndex: Int
    var barChart: Bool
    
    var body: some View{
        VStack{
            ZStack{
                GeometryReader{geometry in
                    self.createGridLines(geometry: geometry.size).stroke(Color.gray)
                    GeometryReader{innerGeometry in
                        ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                            self.getView(i: i, innerGeometry: innerGeometry.size)
                        }
                    }
                    HStack(alignment: .center, spacing: 10){
                        YAXisLabelView(data: self.data, scale: true).padding([.bottom,.top], -10)
                    }.offset(x: self.paddingForY() , y: 0)
                 
                }
            }
            XAxisLabelView(data: self.data, scale: false).padding(.trailing)//.background(Color.black).opacity(0.5)//.padding(.trailing, -15)
           
        }
            
        
    }
    
    func paddingForY() -> CGFloat{
        if data.yAxisTotal > 99{
            return -35
        }else if data.yAxisTotal > 9{
            return -25
        }else{
            return -15
        }
    }
    
    func getView(i: Int, innerGeometry: CGSize) -> AnyView{
        if self.barChart == true{
            return AnyView(BarShape(barEntry: self.data.barEntries[i], yAxisTotal: self.data.yAxisTotal)
            .frame(width: innerGeometry.width / CGFloat(self.data.barEntries.count), height: innerGeometry.height, alignment: .center)
            .offset(x: self.offsetHelper(width: innerGeometry.width, index: i), y: 0)
            .onTapGesture() {
                print("TAPPPED")
                if self.data.barEntries[i].index != nil{
                    self.allDataTestIndex = self.data.barEntries[i].index!
                    self.showDetailTest = true
                    
                }
            }.disabled(self.allDataTestIndex < 0))
        }else{
            return AnyView(Circle().fill(self.data.barEntries[i].yEntries[0].color).frame(width: (innerGeometry.width / CGFloat(self.data.barEntries.count)) * 0.5, height: (innerGeometry.width / CGFloat(self.data.barEntries.count)) * 0.5, alignment: .center)
            .offset(x: self.widthOffsetHelper(width: innerGeometry.width, index: i), y: (innerGeometry.height - (((self.data.barEntries[i].yEntries[0].height) / CGFloat(self.data.yAxisTotal)) * innerGeometry.height)) - (innerGeometry.width / CGFloat(self.data.barEntries.count)) * 0.25))
        }
    }
    func offsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth
    }
    
    func widthOffsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth + (offsetWidth * 0.25)
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
                    self.createStackRect(startHeight: self.heightHelper(maxHeight: geometry.size.height, index: i - 1), endHeight: self.heightHelper(maxHeight: geometry.size.height, index: i), width: geometry.size.width * 0.9).fill(self.barEntry.yEntries[i].color)
                        .opacity(0.95).transformEffect(CGAffineTransform(translationX: geometry.size.width * 0.05, y: 0))
                }
                
            }
        }.rotationEffect(Angle(degrees: 180)) //180
        //.transformEffect(CGAffineTransform(translationX: -geometry.size.width * 0.05, y: 0))
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


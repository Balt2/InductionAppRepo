//
//  BarGraphView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI



struct ScatterPlot: View{
    @EnvironmentObject var orientationInfo: OrientationInfo
    var ar: CGFloat = 2
    let data: BarData
    var body: some View{
        ZStack{ //Whole backgoruund of graph
            Color(.white).opacity(orientationInfo.orientation.rawValue == "ben" ? 1.0 : 1.0)
                   
                   VStack{ //VSTACK FOR GRAPH TO PLACE TITLE, BARS, AND X-AXIS LABEL
                       Text(self.data.title)
                           .foregroundColor(.white)
                           .font(.title)
                           .padding([.top, .bottom], 10)
                    HStack(spacing: 0){
                        YAXisLabelView(data: self.data, scale: true, isScatter: true).padding(.bottom, 10).padding(.top, -10).padding(.trailing, 5) //padding(.leading, 20)
                        
                        ScatterGrid(data: self.data).padding(.trailing, 10)
                    }
                           
                    Text(self.data.xAxisLabel)
                    HStack{
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                        Text("Wrong")
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Correct")
                        Circle().fill(Color.gray).frame(width: 10, height: 10)
                        Text("Omitted")
                    }.padding(.bottom, 25)
                    
                   }
                   
        }.aspectRatio(2.0, contentMode: .fill).padding([.leading, .trailing], 30) //.frame(width: (UIScreen.main.bounds.width) * 0.95, alignment: .center) // frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.475)
            //.aspectRatio(self.ar, contentMode: .fit)
        .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                )
        .padding()
    }
}

struct BarChart: View {
    @EnvironmentObject var orientationInfo: OrientationInfo
    @Binding var showDetailTest : Bool
    @Binding var allDataTestIndex: Int
    let data: BarData
    var showLegend: Bool
    var isQuickData: Bool
    
    
    var body: some View {
        ZStack{ //Whole backgoruund of graph
            Color(.white).opacity( (orientationInfo.orientation.rawValue == "ben" || data.barEntries[0].xLabel == " ") ? 1.0 : 1.0)
            
            VStack{ //VSTACK FOR GRAPH TO PLACE TITLE, BARS, AND X-AXIS LABEL
                Text(self.data.title)
                    .foregroundColor(.black)
                    .font(.title)
                    .padding([.top, .bottom], 10)
                HStack{
                    Spacer(minLength: 35.0) //To create space for the y-axis labels
                    Grid(data: self.data, horizontal: true, showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex).padding(.leading, 30).padding(.trailing, 10)
                }.padding([.trailing], 15)
                    
                Text(self.data.xAxisLabel).font(.system(size: 18.0)).padding(.bottom, self.showLegend == true ? 0.0 : 25.0)
                
                if showLegend == true{
                    HStack{
                        Rectangle().fill(Color.red).frame(width: 50, height: 10)
                        Text("Wrong")
                        Rectangle().fill(Color.green).frame(width: 50, height: 10)
                        Text("Correct")
                        Rectangle().fill(Color.gray).frame(width: 50, height: 10)
                        Text("Omitted")
                    }.padding(.bottom, 25)
                }
            }
            Text(data.barEntries[0].xLabel == " " ? "NO DATA" : "").font(.system(size: 50.0))
            
        }.aspectRatio(2.0, contentMode: self.isQuickData ? .fit : .fill).padding([.leading, .trailing], 30) //.frame(width: (UIScreen.main.bounds.width) * 0.95, alignment: .center)
            .opacity(data.barEntries[0].xLabel == " " ? 0.25 : 1.0)
        .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                )
        .padding()
        
        
        
            
//            .frame(width: (UIScreen.main.bounds.width) * 0.95, height: (UIScreen.main.bounds.width) * 0.475, alignment: .center) // ?? UIScreen.main.bounds.width
//            .aspectRatio(self.ar, contentMode: .fit).padding([.leading, .trailing], 30)
    }
    
}

struct XAxisLabelView: View{
    var data: BarData
    var scale: Bool //true if xaxisView holdsnames of bar data or just numbers (x or y axis). True = typical y-axis data
    var labelJump: Int{
        return 1
        //return ((data.barEntries.count) / 25 + 1)
    }
    
    var body: some View{
        HStack{
            ForEach(self.getStride(), id: \.self){i in
                Group{
                    Text(self.getAxisLabel(i: i)).font(.system(size: self.fontSize())).multilineTextAlignment(.center).lineLimit(3).frame(maxWidth: .infinity, alignment: .center)
                    //.fixedSize(horizontal: false, vertical: true)//.rotationEffect(Angle(degrees: -45), anchor: .center) minimumScaleFactor(0.40) .frame(maxWidth: .infinity, alignment: .center)
                    //                    if i < self.data.barEntries.count - self.labelJump {
                    //                        Spacer()
                    //                    }
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
    func fontSize() -> CGFloat{
        if data.barEntries.count < 4{
            return 16.0
        }else if  data.barEntries.count < 8{
            return 13.0
        }else if data.barEntries.count < 20{
            return 10.0
        }else{
            return 10.0
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
    var isScatter: Bool
    var labelJump: Int{
        return 1
        //return ((data.barEntries.count) / 25 + 1)
    }
    
    var body: some View{
        HStack{
            VStack(spacing: 0){
                ForEach(self.getCharArray(str: self.data.yAxisLabel), id: \.self){letter in
                    Text(String(letter)).rotationEffect(Angle(degrees: -90), anchor: .center).padding([.top, .bottom], -4).font(.system(.subheadline))
                }
            }

            VStack(spacing: 0){
                ForEach(self.getStride(), id: \.self){i in
                    Group{
                        Text(self.getAxisLabel(i: i)).font(.system(.subheadline)).padding(.top, self.isScatter ? 0 : -10)
                        if i != 0{
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    func getCharArray(str: String) -> [Character]{
        var charArray: [Character] = []
        for chr in str{
            charArray.append(chr)
        }
        return charArray.reversed()
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
struct ScatterGrid: View{
    @EnvironmentObject var orientationInfo: OrientationInfo
    var data: BarData
    let diameter: CGFloat = 25.0
    var body: some  View{
        ScrollView(.horizontal){
            //GeometryReader{widthGeometry in
                VStack(alignment: .leading){
                    ZStack{
                        GeometryReader{geometry in
                            self.createGridLines(geometry: geometry.size).stroke(Color.gray)
                            GeometryReader{innerGeometry in
                                ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                    Circle().fill(self.data.barEntries[i].yEntries[0].color).frame(width: self.diameter / 2.0, height: self.diameter / 2.0, alignment: .center)
                                        .offset(x: self.diameter * (CGFloat(i) + 0.75), y: innerGeometry.size.height - (((self.data.barEntries[i].yEntries[0].height) / CGFloat(self.data.yAxisTotal)) * innerGeometry.size.height) - self.diameter / 4.0)
                                }
                            }
                        }
                        
                    }
                    XAxisLabelView(data: self.data, scale: false).frame(width: self.diameter * CGFloat(self.data.barEntries.count)).padding([.trailing, .leading], self.diameter / 2.0)
                }
        }.frame(width: orientationInfo.orientation.rawValue == "BEN" ? UIScreen.main.bounds.width * 0.8 : UIScreen.main.bounds.width * 0.8)
    }
    func createGridLines(geometry: CGSize) -> Path{
        var path = Path()
        
        //Horizontal bars
        for i in (0...data.yAxisSegments){
            let yLoc = CGFloat(i) * (geometry.height / CGFloat(data.yAxisSegments) )
            path.move(to: CGPoint(x: 0, y: yLoc))
            path.addLines([CGPoint(x: 0, y: yLoc), CGPoint(x: 2*geometry.width + CGFloat(25*data.barEntries.count), y: yLoc)])
            print("GEOMETRY")
            print(geometry.width)
            
        }
        
        
        ///Vertical Bars
        //Y-Axis left
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLines([CGPoint(x: 0, y: 0), CGPoint(x: 0, y: geometry.height)])
        //Lines on bar
        
        
        for (index, _) in data.barEntries.enumerated() {
            let xLoc = (self.diameter * (CGFloat(index) + 1))
            path.move(to: CGPoint(x: xLoc, y: 0))
            path.addLines([CGPoint(x: xLoc, y: 0), CGPoint(x: xLoc, y: geometry.height)])
        }
        
        //Y-Axis Right
        path.move(to: CGPoint(x: 2*geometry.width + CGFloat(25*data.barEntries.count), y: 0))
        path.addLines([CGPoint(x: 2*geometry.width + CGFloat(25*data.barEntries.count), y: 0), CGPoint(x: 2*geometry.width + CGFloat(25*data.barEntries.count), y: geometry.height)])
        
        
        return path
        
    }

}
struct Grid: View {
    var data: BarData
    var horizontal: Bool
    @State private var beingTapped = (isTapped: false, index: 0)
    @Binding var showDetailTest : Bool
    @Binding var allDataTestIndex: Int
    
    var body: some View{
           
        GeometryReader{widthGeometry in
            VStack(alignment: .center){
                
                HStack{
                   
                    GeometryReader{geometry in
                        
                        self.createGridLines(geometry: geometry.size).stroke(Color.gray)
                        GeometryReader{innerGeometry in
                            ForEach(0..<self.data.barEntries.count, id: \.self) { i in
                                BarShape(barEntry: self.data.barEntries[i], yAxisTotal: self.data.yAxisTotal)
                                    .frame(width: innerGeometry.size.width / CGFloat(self.data.barEntries.count), height: innerGeometry.size.height, alignment: .center)
                                    .scaleEffect((self.beingTapped.isTapped == true && self.beingTapped.index == i)  ? 0.9 : 1, anchor: .center)
                                    .offset(x: self.offsetHelper(width: innerGeometry.size.width, index: i), y: 0)
                                    .onTapGesture()
                                        {
                                        print("TAPPPED")
                                        if self.data.barEntries[i].index != nil{
                                            self.allDataTestIndex = self.data.barEntries[i].index!
                                            self.showDetailTest = true
                                        }
                                }.disabled(self.allDataTestIndex < 0)
                                    
                                    .onLongPressGesture(pressing: { inProgress in
                                        self.beingTapped = (isTapped: inProgress, index: i)
                                    }) {
                                        self.beingTapped = (isTapped: false, index: i)
                                        self.allDataTestIndex = self.data.barEntries[i].index!
                                        self.showDetailTest = true
                                        print("OVER LONG PRESS")
                                }.disabled(self.allDataTestIndex < 0)
                                
                            }
                        }
                        
                        //HStack(alignment: .center, spacing: 10){
                        

                        YAXisLabelView(data: self.data, scale: true, isScatter: false).offset(x: self.paddingForY(), y: 0) //.frame(maxHeight: geometry.size.height) //.padding([ .bottom], -20)//.fixedSize(horizontal: true, vertical: true)
                        //}.offset(x: self.paddingForY() , y: 0) .padding([.bottom,.top], -10) .offset(x: self.paddingForY() , y: 0)
                        
                        
                    }
                }
                XAxisLabelView(data: self.data, scale: false).padding([.trailing, .leading], (widthGeometry.size.width / CGFloat(2 * self.data.barEntries.count)) * 0.10 )
                
                
            }
        }
        
        
    }
    
    func paddingForY() -> CGFloat{
        if data.yAxisTotal > 999 {
            return -60
        }else if data.yAxisTotal > 99{
            return -50
        }else if data.yAxisTotal > 9{
            return -40
        }else{
            return -30
        }
    }
    
    func offsetHelper (width: CGFloat, index: Int) -> CGFloat{
        let offsetWidth = (width / CGFloat(self.data.barEntries.count))
        return CGFloat(index) * offsetWidth
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
        
        
        for (index, _) in data.barEntries.enumerated() {
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
        }.rotationEffect(Angle(degrees: 180))
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


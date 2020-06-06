//
//  PastPerformanceView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct PastPerformanceView: View {
    @ObservedObject var user: User
    
    @State var index = 0
    @State var offset : CGFloat = 0
    @State var showDetailTest = false
    var detailData: ACTFormatedTestData?{
        return user.fullTestResults[0]
    }
    var width = UIScreen.main.bounds.width
    let scatterData = BarData(title: "Time Per Question", xAxisLabel: "Questions", yAxisLabel: "Minutues", yAxisSegments: 4, yAxisTotal: 12, barEntries: [
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "1", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "2", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "3", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.green)]),
        BarEntry(xLabel: "4", yEntries: [(height: CGFloat(Int.random(in: 1..<11)), color: Color.red)])
    ])
    let totalData = BarData(title: "ACT Perfomance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 30, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 36, color: Color.orange)])
    ])
    
    let totalDataR = BarData(title: "ACT Reading Perfomance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 28, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 36, color: Color.orange)])
    ])
    
    let totalDataM = BarData(title: "ACT Math Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 32, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 35, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 32, color: Color.orange)])
    ])
    
    let totalDataE = BarData(title: "ACT English Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 33, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 36, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 36, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 35, color: Color.orange)])
    ])
    
    let totalDataS = BarData(title: "ACT Science Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 5, yAxisTotal: 36, barEntries: [
        BarEntry(xLabel: "1-16-20", yEntries: [(height: 30, color: Color.orange)]),
        BarEntry(xLabel: "2-1-20", yEntries: [(height: 31, color: Color.orange)]),
        BarEntry(xLabel: "3-10-20", yEntries: [(height: 32, color: Color.orange)]),
        BarEntry(xLabel: "4-4-20", yEntries: [(height: 33, color: Color.orange)])
    ])
    var body: some View {
        Group{
            if showDetailTest == false{
                
                //GeometryReader{geometry in
                    ScrollView(.vertical) {
                        VStack{
                            Spacer()
                            Text("RESULTS").font(.system(.largeTitle)).foregroundColor(.red)
                            //BarChart(data: self.totalData, barChart: true).frame(width: geometry.size.width)
                            BarChart(showDetailTest: self.$showDetailTest, data: self.createOverallGraph(), barChart: true).frame(width: UIScreen.main.bounds.width) //.offset(x: geometry.size.width * 0.05) //2 is the aspect ratio
                            CostumeBarView(index: self.$index, offset: self.$offset, headers: ["Reading", "Math", "English", "Science"]).frame(width:  UIScreen.main.bounds.width)
                            //
                            HStack(spacing: 0){
                                //BarChart(data: self.totalData, barChart: true).frame(width: geometry.size.width)
                                BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataR, barChart: true).frame(width: UIScreen.main.bounds.width)
                                BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataM, barChart: true).frame(width: UIScreen.main.bounds.width)
                                BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataE, barChart: true).frame(width: UIScreen.main.bounds.width)
                                BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataS, barChart: true).frame(width: UIScreen.main.bounds.width)
                                 
                                
                            }.offset(x: 0.5 * (4-1) * UIScreen.main.bounds.width + self.offset).frame(alignment: .trailing) //(4-1) is headers.count - 1
                                .animation(.default)
                                .edgesIgnoringSafeArea(.all)
                                .padding(.all, 0)
                            
                            
                            BarChart(showDetailTest: self.$showDetailTest, data: self.scatterData, barChart: false).frame(width: UIScreen.main.bounds.width)
                            //                            .highPriorityGesture(DragGesture()
                            //
                            //                                .onEnded({ (value) in
                            //
                            //                                    if value.translation.width > 50{// minimum drag...
                            //
                            //                                        print("right")
                            //                                        //self.changeView(left: false)
                            //                                    }
                            //                                    if -value.translation.width > 50{
                            //
                            //                                        print("left")
                            //                                        //self.changeView(left: true)
                            //                                    }
                            //                                }))
                            
                            
                            //}
                        }
                        
                    }
                    
                //}.frame(maxWidth: .infinity)
            }else{
                VStack{
                    CostumeBarView(index: self.$index, offset: self.$offset, headers: ["Tutor Analysis", "Raw Stats", "Actual Test"]).frame(width: UIScreen.main.bounds.width)
                    HStack(spacing: 0){
                        ScrollView(){
                            VStack{
                                ZStack{
                                    Ellipse()
                                        .fill(Color("lightBlue"))
                                        .frame(width: 300, height: 100)
                                    Text("Score: \(Int(self.detailData!.overall.yEntries[0].height))")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.white)
                                }
                                HStack{
                                    Spacer()
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("lightBlue"))
                                            .font(.largeTitle)
                                        Text("Reading: 32")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    }
                                    Spacer()
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("lightBlue"))
                                            .font(.largeTitle)
                                        Text("Math: 32")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    }
                                    Spacer()
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("lightBlue"))
                                            .font(.largeTitle)
                                        Text("Reading: 32")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    }
                                    Spacer()
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("lightBlue"))
                                            .font(.largeTitle)
                                        Text("Reading: 32")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    }
                                    Spacer()
                                }.frame(maxWidth: UIScreen.main.bounds.width)
                                //BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataR, barChart: true).frame(width: UIScreen.main.bounds.width)
                                CostumeBarView(index: self.$index, offset: self.$offset, headers: ["Readig", "Math", "Writing", "Science"]).frame(width: UIScreen.main.bounds.width *  0.9)
                                HStack(spacing: 0){
                                    VStack{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.orange)
                                                .font(.largeTitle)
                                            Text("Reading Breakdown")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                            
                                        }.frame(width: 300)
                                        Spacer()
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.detailData!.subSectionGraphs[0], barChart: true).frame(width: UIScreen.main.bounds.width)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.scatterData, barChart: false).frame(width: UIScreen.main.bounds.width)
                                    }.padding(.all, 0)
                                    VStack{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.orange)
                                                .font(.largeTitle)
                                            Text("Math Breakdown")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                        }.frame(width: 300)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.detailData!.subSectionGraphs[1], barChart: true).frame(width: UIScreen.main.bounds.width)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.scatterData, barChart: false).frame(width: UIScreen.main.bounds.width)
                                    }
                                    
                                    VStack{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.orange)
                                                .font(.largeTitle)
                                            Text("English Breakdown")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                        }.frame(width: 300)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.detailData!.subSectionGraphs[2], barChart: true).frame(width: UIScreen.main.bounds.width)//.frame(width: UIScreen.main.bounds.width)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.scatterData, barChart: false).frame(width: UIScreen.main.bounds.width)
                                    }
                                    VStack{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.orange)
                                                .font(.largeTitle)
                                            Text("Science Breakdown")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                        }.frame(width: 300)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.detailData!.subSectionGraphs[3], barChart: true)//.frame(width: UIScreen.main.bounds.width)//.frame(width: UIScreen.main.bounds.width)
                                        BarChart(showDetailTest: self.$showDetailTest, data: self.scatterData, barChart: false)//.frame(width: UIScreen.main.bounds.width)
                                    }
                                    
                                }.offset(x: 0.5 * (4-1) * UIScreen.main.bounds.width + self.offset) //(4-1) is headers.count - 1
                                .animation(.default)
                                .edgesIgnoringSafeArea(.all)
                                .padding(.all, 0)
                                
                                //Rectangle().fill(Color("lightBlue"))
                                
                            }
                        }
                    }
                    //                    HStack(spacing: 0){
                    //
                    //                    }
                }
            }
        }
    }
    func createOverallGraph() -> BarData{
        var barData = BarData(title: "ACT Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [])
        for test in self.user.fullTestResults{
            barData.barEntries.append(test.overall)
        }
        return barData
        
    }
}

struct CostumeBarView : View {
    
    @Binding var index : Int
    @Binding var offset : CGFloat
    var headers: [String]
    var width = UIScreen.main.bounds.width
    
    var body: some View{
        
        VStack(alignment: .leading, content: {
            
            HStack{
                ForEach(0..<self.headers.count){ i in
                    
                    Button(action: {
                        
                        self.index = i
                        self.offset = CGFloat(-i) * UIScreen.main.bounds.width
                    }) {
                        
                        VStack(spacing: 8){
                            
                            HStack(spacing: 12){
                                
                                Text(self.headers[i])
                                    .foregroundColor(self.index == i ? .white : Color.white.opacity(0.7))
                            }
                            
                            Capsule()
                                .fill(self.index == i ? Color.white : Color.clear)
                                .frame(height: 4)
                        }
                    }
                    
                }
            }
        })
            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)!)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background(Color.red)
    }
}


//struct PastPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PastPerformanceView(testResults: <#[ACTFormatedTestData]#>)
//    }
//}

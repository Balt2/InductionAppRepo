//
//  PastPerformanceView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct PastPerformanceView: View {
    var allData: AllACTData?
    
    @State var index = 0
    @State var offset : CGFloat = 0
    @State var showDetailTest = false
    @State var allDataTestIndex = 0
    
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
    
    var body: some View {

        
        Group {
            if showDetailTest == false{
                
                //GeometryReader{geometry in
                    ScrollView(.vertical) {
                        VStack{
                            Spacer()
                            Text("RESULTS").font(.system(.largeTitle)).foregroundColor(.red)
                            //BarChart(data: self.totalData, barChart: true).frame(width: geometry.size.width)
                            BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: allData!.overallPerformance!, barChart: true).frame(width: UIScreen.main.bounds.width)
                            CostumeBarView(index: self.$index, offset: self.$offset, headers: allData!.sectionNames!).frame(width:  UIScreen.main.bounds.width)
                            HStack(spacing: 0){
                                ForEach(allData!.sectionNames!, id: \.self){sectionKey in
                                    BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.allData!.sectionsOverall![sectionKey]!, barChart: true).frame(width: UIScreen.main.bounds.width)
                                }
                                 
                                
                            }.offset(x: 0.5 * (4-1) * UIScreen.main.bounds.width + self.offset).frame(alignment: .trailing) //(4-1) is headers.count - 1
                                .animation(.default)
                                .edgesIgnoringSafeArea(.all)
                                .padding(.all, 0)
                            
                            
                            //BarChart(showDetailTest: self.$showDetailTest, detailDataIndex: self.$detailDataIndex, data: self.scatterData, barChart: false).frame(width: UIScreen.main.bounds.width)
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
//                DetailView(index: self.index, offset: self.offset, showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, sectionNames: self.allData!.sectionNames, data: self.allData!.allTestData![allDataTestIndex])
                VStack{
                    //CostumeBarView(index: self.$index, offset: self.$offset, headers: ["Tutor Analysis", "Raw Stats", "Actual Test"]).frame(width: UIScreen.main.bounds.width)
                    HStack(spacing: 0){
                        ScrollView(){
                            VStack{
                                ZStack{
                                    Ellipse()
                                        .fill(Color("lightBlue"))
                                        .frame(width: 300, height: 100)
                                    Text("Score: \(Int((self.allData?.allTestData![self.allDataTestIndex].overall.yEntries[0].height)!))")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.white)
                                }
                                HStack{
                                    Spacer()
                                    ForEach((self.allData!.sectionNames!), id: \.self){sectionKey in
                                        Group{
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color("lightBlue"))
                                                    .font(.largeTitle)
                                                Text("\(sectionKey): \(Int((self.allData?.allTestData![self.allDataTestIndex].sectionsOverall[sectionKey]!.yEntries[0].height)!))")
                                                    .font(.largeTitle)
                                                    .foregroundColor(Color.white)
                                            }
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }.frame(maxWidth: UIScreen.main.bounds.width)
                                //BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataR, barChart: true).frame(width: UIScreen.main.bounds.width)
                                CostumeBarView(index: self.$index, offset: self.$offset, headers: (self.allData?.sectionNames)!).frame(width: UIScreen.main.bounds.width)
                                HStack(spacing: 0){
                                    ForEach((self.allData?.sectionNames)!, id: \.self){sectionKey in
                                            VStack{
                                                ZStack{
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .fill(Color.orange)
                                                        .font(.largeTitle)
                                                    Text("\(sectionKey) Breakdown") //section.title
                                                        .font(.largeTitle)
                                                        .foregroundColor(Color.white)
                                                }.frame(width: 300)
                                                Spacer()
                                                BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: (self.allData?.allTestData![self.allDataTestIndex].subSectionGraphs[sectionKey]!)!, barChart: true).frame(width: UIScreen.main.bounds.width)
                                                BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: (self.allData!.allTestData![self.allDataTestIndex].subSectionTime[sectionKey]!), barChart: false).frame(width: UIScreen.main.bounds.width)
                                            }.padding(.all, 0)
                                        }
                                }.offset(x: 0.5 * (CGFloat(self.allData!.allTestData![self.allDataTestIndex].sectionsOverall.count) - 1) * UIScreen.main.bounds.width + self.offset)
                                .animation(.default)
                                .edgesIgnoringSafeArea(.all)
                                .padding(.all, 0)
                                
                                
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

}

struct DetailView: View{
    @State var index: Int
    @State var offset: CGFloat
    @Binding var showDetailTest: Bool
    @Binding var allDataTestIndex: Int
    var sectionNames: [String]
    var data: ACTFormatedTestData
    var body: some View{
        VStack{
            //CostumeBarView(index: self.$index, offset: self.$offset, headers: ["Tutor Analysis", "Raw Stats", "Actual Test"]).frame(width: UIScreen.main.bounds.width)
            HStack(spacing: 0){
                ScrollView(){
                    VStack{
                        ZStack{
                            Ellipse()
                                .fill(Color("lightBlue"))
                                .frame(width: 300, height: 100)
                            Text("Score: \(Int(self.data.overall.yEntries[0].height))")
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                        }
                        HStack{
                            Spacer()
                            ForEach(self.sectionNames, id: \.self){sectionKey in
                                Group{
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("lightBlue"))
                                            .font(.largeTitle)
                                        Text("\(sectionKey): \(Int(self.data.sectionsOverall[sectionKey]!.yEntries[0].height))")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    }
                                    Spacer()
                                }
                            }
                            Spacer()
                        }.frame(maxWidth: UIScreen.main.bounds.width)
                        //BarChart(showDetailTest: self.$showDetailTest, data: self.totalDataR, barChart: true).frame(width: UIScreen.main.bounds.width)
                        CostumeBarView(index: self.$index, offset: self.$offset, headers: self.sectionNames).frame(width: UIScreen.main.bounds.width)
                        HStack(spacing: 0){
                             ForEach(self.sectionNames, id: \.self){sectionKey in
                                    VStack{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.orange)
                                                .font(.largeTitle)
                                            Text("\(sectionKey) Breakdown") //section.title
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                        }.frame(width: 300)
                                        Spacer()
                                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.data.subSectionGraphs[sectionKey]!, barChart: true).frame(width: UIScreen.main.bounds.width)
                                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.data.subSectionTime[sectionKey]!, barChart: false).frame(width: UIScreen.main.bounds.width)
                                    }.padding(.all, 0)
                                }
                            }.offset(x: 0.5 * (CGFloat(self.data.sectionsOverall.count) - 1) * UIScreen.main.bounds.width + self.offset)
                        .animation(.default)
                        .edgesIgnoringSafeArea(.all)
                        .padding(.all, 0)
                        
                        
                    }
                }
            }
            //                    HStack(spacing: 0){
            //
            //                    }
        }
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

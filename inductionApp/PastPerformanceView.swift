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
    @State var shouldScrollNav: Bool = true
    @State var shouldScrollToTopNav: Bool =  true
    
    @State private var selection: Tabs = .analytics
    
    private enum Tabs: Hashable{
        case analytics
        case tutorPDF
        case corrections
    }
    
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        
        
        Group {
            if showDetailTest == false{
                
                //GeometryReader{geometry in
                ScrollView(.vertical) {
                    VStack{
                        Spacer()
                        Text("RESULTS").font(.system(.largeTitle)).foregroundColor(.red)
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: allData!.overallPerformance!, showLegend: false).frame(width: UIScreen.main.bounds.width)
                        CostumeBarView(index: self.$index, offset: self.$offset, headers: allData!.sectionNames!).frame(width:  UIScreen.main.bounds.width)
                        HStack(spacing: 0){
                            ForEach(allData!.sectionNames!, id: \.self){sectionKey in
                                BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.allData!.sectionsOverall![sectionKey]!, showLegend: false).frame(width: UIScreen.main.bounds.width)
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
            }else{
                TabView(selection: $selection){
                    RawDataView(index: self.index, offset: self.offset, sectionNames: self.allData!.sectionNames!, data: self.allData!.allTestData![allDataTestIndex])
                        .tabItem{
                            Image(systemName: "1.square.fill")
                            Text("Analytics")
                    }.tag(Tabs.analytics)
                    
                    ScrollView(.vertical){
                        
                        ForEach(self.allData!.allTestData![allDataTestIndex].tutorPDF.pages, id: \.self){ page in
                                PageView(model: page)
                            
                        }
                    }
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("Tutor PDF")
                    }.tag(Tabs.tutorPDF)
                    CorrectionView(testData: self.allData!.allTestData![allDataTestIndex])
//                        .navigationBarItems(leading: EmptyView(),
//                        trailing: CorrectionNavigationBar(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData))
//                    ScrollView(.vertical){
//                        ForEach(self.allData!.allTestData![allDataTestIndex].pdfImages, id: \.self){page in
//                            PageView(model: page)
//                        }
//                    }
                    .tabItem {
                        Image(systemName: "3.square.fill")
                        Text("Corrections")
                    }.tag(Tabs.corrections)
                }.navigationBarItems(trailing: self.selection == .corrections ? AnyView(CorrectionNavigationBar(shouldScrollNav: self.$shouldScrollNav, shouldScrollToTopNav: self.$shouldScrollToTopNav, test: self.allData!.allTestData![allDataTestIndex])) : AnyView(EmptyView()))
                //.navigationBarItems(trailing: self.selection == .corrections ? CorrectionNavigationBar(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData) : EmptyView())
            }
        }
    }
    
}


struct RawDataView: View{
    @State var index: Int
    @State var offset: CGFloat
    
    @State var showDetailTest = true
    @State var allDataTestIndex = -1 //Used to disable the bars tap
    var sectionNames: [String]
    var data: ACTFormatedTestData
    var body: some View{
        ScrollView(.vertical){
            ZStack{
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color("lightBlue"))
                    .font(.largeTitle)
                Text("Test: \(data.name); Taken on: \(data.dateTaken!)")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            ZStack{
                Ellipse()
                    .fill(Color("lightBlue"))
                    .frame(width: 300, height: 100)
                Text("Score: \(Int(self.data.overall!.yEntries[0].height))")
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
            CostumeBarView(index: self.$index, offset: self.$offset, headers: self.sectionNames).frame(width: UIScreen.main.bounds.width)
            HStack(spacing: 0){
                ForEach(self.sectionNames, id: \.self){sectionKey in
                    VStack{
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.data.subSectionGraphs[sectionKey]!, showLegend: true).frame(width: UIScreen.main.bounds.width)
                        ScatterPlot(data:self.data.subSectionTime[sectionKey]!).frame(width: UIScreen.main.bounds.width)
                        
                        
                    }.padding(.all, 0)
                }
            }.offset(x: 0.5 * (CGFloat(self.data.sectionsOverall.count) - 1) * UIScreen.main.bounds.width + self.offset)
                .animation(.default)
                .edgesIgnoringSafeArea(.all)
                .padding(.all, 0)
            
        }
        
    }
}

struct CostumeBarView : View {
    
    @Binding var index : Int
    @Binding var offset : CGFloat
    var headers: [String]
    var width = UIScreen.main.bounds.width
    
    var body: some View{
                    
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
            .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)!)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background(Color("salmon"))
    }
}



//struct PastPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PastPerformanceView(testResults: <#[ACTFormatedTestData]#>)
//    }
//}

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
                        HStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 5)
                                .fill(Color("lightBlue"))
                                    .font(.largeTitle)
                                    .frame(width: 300)
                                    Text("\(user.showACTData! ? "ACT" : "SAT") Results").font(.system(.largeTitle)).foregroundColor(.red)
                            }
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 5)
                                .fill(Color("lightBlue"))
                                    .font(.largeTitle)
                                    .frame(width: 200)
                                Text("Show \(user.showACTData! ? "SAT" : "ACT") Results").font(.system(.caption)).foregroundColor(.white)
                            }.onTapGesture {
                                print("TAPING DATA CHANGE")
                                self.user.showACTData!.toggle()
                                if self.user.currentPerformanceData == nil {
                                    self.user.showACTData!.toggle()
                                }
                            }
                            
                        }
                        
                        
                        
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentPerformanceData!.overallPerformance!, showLegend: false).frame(width: UIScreen.main.bounds.width)
                        .animation(.default)
                        
                        CostumeBarView(index: self.$index, offset: self.$offset, headers: user.currentPerformanceData!.higherSectionNames!).frame(width:  UIScreen.main.bounds.width)
                        
                        HStack(spacing: 0){
                            ForEach(user.currentPerformanceData!.higherSectionNames!, id: \.self){sectionKey in
                                BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.user.currentPerformanceData!.sectionsOverall![sectionKey]!, showLegend: false).frame(width: UIScreen.main.bounds.width)
                            }
                        }.offset(x: 0.5 * (CGFloat(self.user.currentPerformanceData!.higherSectionNames?.count ?? 4 ) - 1.0) * UIScreen.main.bounds.width + self.offset).frame(alignment: .trailing) //(4-1) is headers.count - 1
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
                    RawDataView(index: self.index, offset: self.offset, sectionNames: self.user.currentPerformanceData!.sectionNames!, data: self.user.currentPerformanceData!.allTestData![allDataTestIndex])
                        .tabItem{
                            Image(systemName: "1.square.fill")
                            Text("Analytics")
                    }.tag(Tabs.analytics)
                    
                    ScrollView(.vertical){
                        
                        ForEach(self.user.currentPerformanceData!.allTestData![allDataTestIndex].tutorPDF.pages, id: \.self){ page in
                                PageView(model: page)
                            
                        }
                    }
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("Tutor PDF")
                    }.tag(Tabs.tutorPDF)
                    CorrectionView(testData: self.user.currentPerformanceData!.allTestData![allDataTestIndex])
//                        .navigationBarItems(leading: EmptyView(),
//                        trailing: CorrectionNavigationBar(shouldScrollNav: self.$shouldScroll, shouldScrollToTopNav: self.$shouldScrollToTop, test: self.testData))
//                    ScrollView(.vertical){
//                        ForEach(self.user.currentPerformanceData!.allTestData![allDataTestIndex].pdfImages, id: \.self){page in
//                            PageView(model: page)
//                        }
//                    }
                    .tabItem {
                        Image(systemName: "3.square.fill")
                        Text("Corrections")
                    }.tag(Tabs.corrections)
                }.navigationBarItems(trailing: self.selection == .corrections ? AnyView(CorrectionNavigationBar(shouldScrollNav: self.$shouldScrollNav, shouldScrollToTopNav: self.$shouldScrollToTopNav, test: self.user.currentPerformanceData!.allTestData![allDataTestIndex])) : AnyView(EmptyView()))
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
                Text("\(data.name) taken on: \(data.dateTaken!.toString(dateFormat: "EEEE, MMM d, yyyy"))")
                .font(.largeTitle)
                .foregroundColor(Color.white)
            }.frame(width: 850).padding(.top, 10)
                
                
            
            ZStack{
                Ellipse()
                    .fill(Color("lightBlue"))
                    .frame(width: 300, height: 100)
                Text("Score: \(Int(self.data.overall!.yEntries[0].height))")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            if data.act == false{
                HStack{
                    Spacer()
                    //Group{
                       ZStack{
                           RoundedRectangle(cornerRadius: 5)
                               .fill(Color("lightBlue"))
                               .font(.largeTitle)
                        Text("English: \(self.data.englishScore!)")
                               .font(.largeTitle)
                               .foregroundColor(Color.white)
                       }
                       Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color("lightBlue"))
                                .font(.largeTitle)
                            Text("Math: \(self.data.mathScore!)")
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    //}
                }.frame(maxWidth: UIScreen.main.bounds.width)
            }else{
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
            }
            CostumeBarView(index: self.$index, offset: self.$offset, headers: self.sectionNames).frame(width: UIScreen.main.bounds.width)
            HStack(spacing: 0){
                ForEach(self.sectionNames, id: \.self){sectionKey in
                    VStack{
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.data.subSectionGraphs[sectionKey]!, showLegend: true).frame(width: UIScreen.main.bounds.width)
                        ScatterPlot(data:self.data.subSectionTime[sectionKey]!).frame(width: UIScreen.main.bounds.width)
                        
                        
                    }.padding(.all, 0)
                }
            }.offset(x: 0.5 * (CGFloat(self.sectionNames.count) - 1) * UIScreen.main.bounds.width + self.offset)
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
                ForEach(0..<self.headers.count, id: \.self){ i in
                    
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

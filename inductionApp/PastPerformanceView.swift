//
//  PastPerformanceView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 5/29/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI

struct PastPerformanceView: View {
    //INFORMATION ABOUT THE SCREEN ORIENTATION
    @EnvironmentObject var orientationInfo: OrientationInfo
    //CURRENT USER
    @ObservedObject var user: User
    //INDEX OF SECTION THE USER IS LOOKING AT
    @State var index = 0
    //BOOLEAN THAT DETERMIENS IF THE USER IS LOOKING AT A DETAIL ANAYLISIS
    @State var showDetailTest = false
    //INDEX REPRESENTING WHICH TEST THEY WANT TO SEE THE DETAIL OF
    @State var allDataTestIndex = 0
    //USED FOR THE VIEW OF TEST PDF
    @State var shouldScrollNav: Bool = true
    @State var shouldScrollToTopNav: Bool =  true
    
    //POP UP FOR GETTING INFORMATION ABOUT A SPECIFIC QUESTION
    @State var popUpShow: Bool = false
    
    //WHICH TAB THEY ARE CURRENTLY LOOKING AT (GRAPHS (ANALYTICS), TEST PDF (CORRECTIONS) , TUTOR PDF)
    @State private var selection: Tabs = .analytics
    
    private enum Tabs: Hashable{
        case analytics
        case tutorPDF
        case corrections
    }
    //WIDTH OF SCREEN
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        
        
        Group {
            
            if showDetailTest == false{
                //EXCUTE LOGIC FOR THE OVERAL GRAPHS
                //GeometryReader{geometry in
                ScrollView(.vertical) {
                    VStack{
                        Spacer()
                        HStack{
                            ZStack{
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(red: 0.15, green: 0.68, blue: 0.37))
                                    .font(orientationInfo.orientation.rawValue == "Ben" ? .largeTitle : .largeTitle)
                                    .frame(width: 300)
                                Text("\(user.showTestType!.rawValue) Results").font(.system(.largeTitle)).foregroundColor(.black)
                            }
                            
                        }
                        
                        
                        //BAR CHART FOR THEIR OVERALL PERFORMANCE OVER THE DIFFERENT DATES THEY HAVE TAKEN THIS TYPE OF TEST
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentPerformanceData!.overallPerformance!, showLegend: false, isQuickData: false).frame(width: UIScreen.main.bounds.width)
                        .animation(.default)
                        
                        CostumeBarView(index: self.$index, headers: user.currentPerformanceData!.higherSectionNames!).frame(width:  UIScreen.main.bounds.width)
                        
                        //HSTACK CONTAINING THE SECTION BAR GRAPHS
                        HStack(spacing: 0){
                            ForEach(user.currentPerformanceData!.higherSectionNames!, id: \.self){sectionKey in
                                BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.user.currentPerformanceData!.sectionsOverall![sectionKey]!, showLegend: false, isQuickData: false).frame(width: UIScreen.main.bounds.width)
                            }
                        }.offset(x: 0.5 * (CGFloat(self.user.currentPerformanceData!.higherSectionNames?.count ?? 4 ) - 1.0) * UIScreen.main.bounds.width + (UIScreen.main.bounds.width * CGFloat(self.index) * -1.0)).frame(alignment: .trailing) //(4-1) is headers.count - 1
                            .animation(.default)
                            .edgesIgnoringSafeArea(.all)
                            .padding(.all, 0)
                        //TIME OF DAY GRAPH
                        //ScatterPlot(data: (user.currentPerformanceData?.overallPerformanceTimeOfDay!)!).frame(width: UIScreen.main.bounds.width)
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
                //IF THEY ARE LOOING AT A TEST DETAIL THEN THEY WILL HAVE A TAB VIEW
                TabView(selection: $selection){
                    RawDataView(index: self.index, sectionNames: self.user.currentPerformanceData!.sectionNames!, data: self.user.currentPerformanceData!.allTestData![allDataTestIndex])
                        .tabItem{
                            Image(systemName: "1.square.fill")
                            Text("Analytics")
                    }.tag(Tabs.analytics)
                    //TUTOR PDF TAB
//                    ScrollView(.vertical){
//
//                        ForEach(self.user.currentPerformanceData!.allTestData![allDataTestIndex].tutorPDF.pages, id: \.self){ page in
//                                PageView(model: page)
//
//                        }
//                    }
//                    .tabItem {
//                        Image(systemName: "2.square.fill")
//                        Text("Tutor PDF")
//                    }.tag(Tabs.tutorPDF)
                    //PDF OF TEST WITH EACH QUESTION CLICKABLE SO THEY CAN GET MORE INFORMATION ABOUT THAT ONE QUESTION
                    CorrectionView(shouldScroll: self.$shouldScrollNav, shouldScrollToTop: self.$shouldScrollToTopNav, showPopUp: self.$popUpShow,  testData: self.user.currentPerformanceData!.allTestData![allDataTestIndex])

                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("Corrections")
                    }.tag(Tabs.corrections)
                }.navigationBarItems(trailing: self.selection == .corrections ? AnyView(CorrectionNavigationBar(shouldScrollNav: self.$shouldScrollNav, shouldScrollToTop: self.$shouldScrollToTopNav, showPopUp: self.$popUpShow, test: self.user.currentPerformanceData!.allTestData![allDataTestIndex])) : AnyView(EmptyView()))
            }
        }
    }
    
}

//STRUCTURE TO PRESENT THE DETAIL VIEW FOR A SPECIFIC TEST. GRAPHS INCLUDE SUB SECIOTN SCORES AND TIMING PER QUESTION
struct RawDataView: View{
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State var index: Int
    
    @State var showDetailTest = true
    @State var allDataTestIndex = -1 //Used to disable the bars tap
    var sectionNames: [String]
    var data: ACTFormatedTestData
    var body: some View{
        ScrollView(.vertical){
            ZStack{
                RoundedRectangle(cornerRadius: 5)
                   .fill(Color(red: 0.12, green: 0.58, blue: 0.84))
                   .font(.largeTitle)
                Text("\(data.name) taken on: \(data.dateTaken!.toString(dateFormat: "EEEE, MMM d, yyyy"))")
                .font(.largeTitle)
                .foregroundColor(Color.white)
            }.frame(width: 850).padding(.top, 10)
                
                
            
            ZStack{
                Ellipse()
                    .fill(Color(red: 0.12, green: 0.58, blue: 0.84))
                    .frame(width: 300, height: 100)
                Text("Score: \(Int(self.data.overall!.yEntries[0].height))")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
            }
            if data.testType! == .sat || data.testType! == .psat{
                HStack{
                    Spacer()
                    //Group{
                    //LABELS WITH THEIR ENGLISH AND MATH SCORES FOR SAT OR PSAT
                       ZStack{
                           RoundedRectangle(cornerRadius: 5)
                               .fill(Color(red: 0.12, green: 0.58, blue: 0.84))
                               .font(.largeTitle)
                        Text("English: \(self.data.englishScore)")
                               .font(.largeTitle)
                               .foregroundColor(Color.white)
                       }
                       Spacer()
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(red: 0.12, green: 0.58, blue: 0.84))
                                .font(.largeTitle)
                            Text("Math: \(self.data.mathScore)")
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    //}
                }.frame(maxWidth: UIScreen.main.bounds.width)
            }else{
                //SHOW SECTION NAME FOR ACT
                HStack{
                    Spacer()
                    ForEach(self.sectionNames, id: \.self){sectionKey in
                        Group{
                            ZStack{
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(red: 0.12, green: 0.58, blue: 0.84))
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
            //HEADER WITH SECTION NAMES FOR USER TO CLICK THROUGH
            CostumeBarView(index: self.$index, headers: self.sectionNames).frame(width: orientationInfo.orientation.rawValue == "BEN" ? UIScreen.main.bounds.width : UIScreen.main.bounds.width )
            HStack(spacing: 0){
                ForEach(self.sectionNames, id: \.self){sectionKey in
                    VStack{
                        BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: self.data.subSectionGraphs[sectionKey]!, showLegend: true, isQuickData: false).frame(width: UIScreen.main.bounds.width)
                        ScatterPlot(data:self.data.subSectionTime[sectionKey]!).frame(width: UIScreen.main.bounds.width)
                        
                        
                    }.padding(.all, 0)
                }
            }.offset(x: 0.5 * (CGFloat(self.sectionNames.count) - 1) * UIScreen.main.bounds.width + (UIScreen.main.bounds.width * CGFloat(self.index) * -1.0))
                .animation(.default)
                .edgesIgnoringSafeArea(.all)
                .padding(.all, 0)
            
        }
        
    }
}

//TAKEN FROM ONLINE SOURCE
struct CostumeBarView : View {
    
    @Binding var index : Int
    var headers: [String]
    var width = UIScreen.main.bounds.width
    
    var body: some View{
                    
            HStack{
                ForEach(0..<self.headers.count, id: \.self){ i in
                    
                    Button(action: {
                        
                        self.index = i
                        
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
            .background(Color(red: 0.15, green: 0.68, blue: 0.37))
    }
}



//struct PastPerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PastPerformanceView(testResults: <#[ACTFormatedTestData]#>)
//    }
//}

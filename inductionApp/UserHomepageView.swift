//
//  UserHomepageView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import Firebase

struct UserHomepageView: View {
    @EnvironmentObject var currentAuth: FirebaseManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var user: User
    @State var isTestActive: Bool = false
    @State var isStudyActive: Bool = false
    @State private var showSettingSheet: Bool = false
    
    //Used for quick data
    @State var updateHomePageView = true
    //NOT USED
    @State var showDetailTest = false
    @State var allDataTestIndex = -1
    //var emptyBarEntry = BarEntry(xLabel: "No Date", yEntries: [(height: 0, color: Color.gray)])
    var emptyData = BarData(title: "ACT Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [BarEntry(xLabel: " ", yEntries: [(height: 0, color: Color.gray)])])
    
    var body: some View {
        NavigationView{
            HStack(alignment: .top){
                //Student name and buttons for next tests
                VStack{
                    //Circle with initilias and name
                    HStack{
                        ZStack{
                            Circle().foregroundColor(.blue)//.background(Color.black)
                            Text(String(user.firstName.first ?? "N") + String(user.lastName.first ?? "A"))
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .font(.system(size: 30))
                        }.frame(width: 80)
                        Text("\(currentAuth.currentUser!.firstName + " " + currentAuth.currentUser!.lastName)")
                            .foregroundColor(Color.blue)
                            .fontWeight(.bold)
                    }.frame(height: 80)
                    //Buttons
                    
                    //Link for taking a test
                    NavigationLink(destination: TestTable(user: currentAuth.currentUser!, rootIsActive: self.$isTestActive, updateView: self.$updateHomePageView), isActive: self.$isTestActive){
                        HStack{
                            getLoadingIcon(imageName: "folder", checkBool: user.getTestsComplete) //Folder or activity indicator saying it is loading
                            Text(user.getTestsComplete == true ?  "Choose Test!" : "Loading Tests..." )
                        }
                    }.isDetailLink(false).buttonStyle(buttonBackgroundStyle(disabled: user.getTestsComplete == false)) //.isDetailLink(false)
                        .disabled(user.getTestsComplete == false)
                    
                    
                    //Past Performance
                    NavigationLink(destination: PastPerformanceView(user: user)){ //allSATPerformanceData
                        HStack{
                            getLoadingIcon(imageName: "archivebox", checkBool: user.getPerformanceDataComplete)
                            Text(user.getPerformanceDataComplete == true ? "Past Performance" : "Loading Performance...")
                        }
                    }.buttonStyle(buttonBackgroundStyle(disabled: user.getPerformanceDataComplete == false || user.showTestType == nil))
                        .disabled(user.getPerformanceDataComplete == false || user.showTestType == nil)
                    
                    Button(action: {
                        self.showSettingSheet = true
                    }){
                        Text("Settings")
                    }.buttonStyle(buttonBackgroundStyle())
                    .actionSheet(isPresented: $showSettingSheet){
                            ActionSheet(title: Text("Test Type"),
                                        message: Text("Select which test you want to take. This will change the contents of your testing library."),
                                        buttons: [
                                            
                                            .default(Text("ACT"), action: {
                                                if self.user.allACTPerformanceData != nil {
                                                    self.user.showTestType = .act
                                                }
                                            }),
                                            .default(Text("SAT"), action: {
                                                if self.user.allSATPerformanceData != nil {
                                                    self.user.showTestType = .sat
                                                }
                                            }),
                                            .default(Text("PSAT"), action: {
                                                if self.user.allPSATPerformanceData != nil {
                                                    self.user.showTestType = .psat
                                                }
                                            })
                            ])
                    }

                    
                    //Sign out
                    Button(action: {
                        if self.currentAuth.signOut() == true {
                            print("Sucsess Logging out!")
                        } else {
                            print("Failed to log out")
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                            Text("Sign out")
                        }
                    }.buttonStyle(buttonBackgroundStyle())
                    
                }.padding(.top, 20).padding(.leading, 5)
                
                
                VStack{
                    BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentQuickData.overallBarData, showLegend: false, isQuickData: true).opacity(self.updateHomePageView ? 1.0 : 1.0)
                    HStack{
                        ForEach(user.currentQuickData.sectionNames, id: \.self){sectionName in
                            Group{
                                Spacer()
                                ZStack{
                                    RoundedRectangle(cornerRadius: 15).frame(width: 120, height: 50).foregroundColor(self.updateHomePageView ? .black : .black)
                                    Text(sectionName).foregroundColor(sectionName == self.user.currentQuickData.currentSectionString ? .blue : .white)
                                }.onTapGesture {
                                    print("DANIEL")
                                    self.user.currentQuickData.currentSectionString = sectionName
                                    self.updateHomePageView.toggle()
                                    
                                }
                            }
                        }
                        Spacer()
                    }
                    BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentQuickData.currentSectionBarData, showLegend: false, isQuickData: true)
                }.padding([.top, .bottom], 20)
                
            }.navigationBarTitle("Home Page", displayMode: .inline)
                        
                
        }.navigationViewStyle((StackNavigationViewStyle()))
        
    }
    //
    //
    //                    //                            NavigationLink(destination: StudyTable(user: currentAuth.currentUser!, rootIsActive: self.$isStudyActive), isActive: self.$isStudyActive){
    //                    //                                HStack{
    //                    //                                    getLoadingIcon(imageName: "folder", checkBool: user.getTestsComplete) //Folder or activity indicator saying it is loading
    //                    //                                    Text(user.getTestsComplete == true ?  "Study Library" : "Loading Library..." )
    //                    //                                }
    //                    //                            }.isDetailLink(false).buttonStyle(buttonBackgroundStyle(disabled: user.getTestsComplete == false))
    //                    //                                .disabled(user.getTestsComplete == false)
    //
    //
    //                Image("ilLogo")
    //                    .resizable()
    //                    .aspectRatio(contentMode: .fit)
    //                    .frame(width: 300)
    //                    .padding()
    //            }
    //        }
    //    }
    
    func getLoadingIcon(imageName: String, checkBool: Bool) -> AnyView{
        if checkBool == true {
            return AnyView(Image(systemName: imageName))
        }else{
            return AnyView(ActivityIndicator(isAnimating: true).configure { $0.color = .white })
        }
    }
    
    
}

//Acitivity monitor helpers: https://stackoverflow.com/questions/56496638/activity-indicator-in-swiftui
struct ActivityIndicator: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

extension View where Self == ActivityIndicator {
    func configure(_ configuration: @escaping (Self.UIView)->Void) -> Self {
        Self.init(isAnimating: self.isAnimating, configuration: configuration)
    }
}





//struct UserHomepageView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserHomepageView(, user: <#User#>)
//    }
//}

struct buttonBackgroundStyle: ButtonStyle {
    var disabled: Bool?
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(disabled == true ? Color(.lightGray) : Color("salmon"))
            .cornerRadius(40)
            .padding()
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct nameLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.system(.body, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .background(Color("lightBlue"))
            .cornerRadius(20)
    }
}


struct infoLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.system(.title, design: .rounded))
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color("lightBlue"))
            .cornerRadius(20)
            .padding()
    }
}



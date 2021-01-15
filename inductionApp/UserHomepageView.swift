//
//  UserHomepageView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import Firebase
import UIKit

struct UserHomepageView: View {
    //CURRENT AUTH FROM FIREBASE
    @EnvironmentObject var currentAuth: FirebaseManager
    //POSSIBLY CAN BE DELETED BUT NOT TOTALLY SURE.
    @Environment(\.managedObjectContext) var managedObjectContext
    //INFORMATION ABOUT THE ORIENTATION OF THE SCREEN. CAUSES THE SCREEN TO RE-RENDER IF
    @EnvironmentObject var orientationInfo: OrientationInfo
    //CURRENT USER
    @ObservedObject var user: User
    //VARIABLE TO DETEMRINE IFA  STUDENT IS TAKING A TEST OR IS STUDYING
    @State var isTestActive: Bool = false
    @State var isStudyActive: Bool = false
    //SHOW SHEET IS TRUE IF THE INSTRUCTIONS OR SETTINGS PAGE SHOULD BE DISPLAYED
    @State var showSheet: Bool = false
    @State var showSettingSheet: Bool = false
    
    //Used for quick data
    @State var updateHomePageView: Bool = true
    @State var showInstructions: Bool = false
    
    //Settings
    @State var showQuickDataType: TestType = .act
    @State var leftHandMode: Bool = false
    @State var currentPageInstructions: Int = 0
    let imageNames = ["i1", "i2", "i3", "i4", "i5", "i6", "i7", "i8", "i9", "i10", "i11", "i12"]
    
    private let blueColor = Color(red: 0.12, green: 0.58, blue: 0.84)
    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.37)
    //NOT USED
    
    @State var showDetailTest = false
    @State var allDataTestIndex = -1
    var emptyData = BarData(title: "ACT Performance", xAxisLabel: "Dates", yAxisLabel: "Score", yAxisSegments: 4, yAxisTotal: 36, barEntries: [BarEntry(xLabel: " ", yEntries: [(height: 0, color: Color.gray)])])
    
    var body: some View {
        NavigationView{
            HStack(alignment: .top){
                //Student name and buttons for next tests
                VStack{
                    //Circle with initilias and name
                    HStack{
                        ZStack{
                            Circle().foregroundColor(blueColor)//.background(Color.black)
                            Text(String(user.firstName.first ?? "N") + String(user.lastName.first ?? "A"))
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                                .font(.system(size: 30))
                        }.frame(width: 80)
                        Text("\(self.user.firstName + " " + self.user.lastName)")
                            .foregroundColor(Color.blue)
                            .fontWeight(.bold)
                    }.frame(height: 80)
                    //Buttons
                    
                    //Link for taking a test
                    NavigationLink(destination: TestTable(user: self.user, rootIsActive: self.$isTestActive, sectionDict: self.user.createSectionsForStudyTable()), isActive: self.$isTestActive){
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
                        self.showSheet = true
                        self.showSettingSheet = true
                        print("SETTINGS NOW TRUE?")
                        
                    }){
                        HStack{
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }.buttonStyle(buttonBackgroundStyle())
                    
                    //Instructiopns
                    Button(action: {
                        self.showSheet = true
                        self.showInstructions = true
                        print("INSTRUCTIONS NOW TRUE?")
                   }) {
                       HStack {
                           Image(systemName: "doc")
                           Text("Instructions")
                       }
                   }.buttonStyle(buttonBackgroundStyle())
                    
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
                    //PRESENT A BARCHART FOR THE QUICK DATA
                    BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentQuickData.overallBarData, showLegend: false, isQuickData: true)
                    
                    HStack{
                        ForEach(user.currentQuickData.sectionNames, id: \.self){sectionName in
                            Group{
                                ZStack{
                                    RoundedRectangle(cornerRadius: 15).frame(width: 120, height: 40).foregroundColor(self.updateHomePageView ? greenColor : greenColor)
                                    Text(sectionName).foregroundColor(sectionName == self.user.currentQuickData.currentSectionString ? .white : .black)
                                }.onTapGesture {
                                    self.user.currentQuickData.currentSectionString = sectionName
                                    self.updateHomePageView.toggle()
                                }
                            }
                        }
                    }
                    BarChart(showDetailTest: self.$showDetailTest, allDataTestIndex: self.$allDataTestIndex, data: user.currentQuickData.currentSectionBarData, showLegend: false, isQuickData: true)
                }.padding([.top, .bottom], 20).frame(width: orientationInfo.orientation.rawValue == "BEN" ? UIScreen.main.bounds.width * 0.75 : UIScreen.main.bounds.width * 0.75)
                
            }.navigationBarTitle("Home Page", displayMode: .inline)
                .sheet(isPresented: $showSheet, onDismiss: {
                    //SHOW SEETTINGS PAGE OR INSTRUCTIONS PAGE
                    if self.showSettingSheet == true{
                        //SETTINGS LOGIC
                        switch self.showQuickDataType{
                        case .act:
                            if self.user.allACTPerformanceData != nil {
                                self.user.showTestType = self.showQuickDataType
                            }
                        case .sat:
                            if self.user.allSATPerformanceData != nil {
                                self.user.showTestType = self.showQuickDataType
                            }
                        case .psat:
                            if self.user.allPSATPerformanceData != nil {
                                self.user.showTestType = self.showQuickDataType
                            }
                        }
                        self.showSettingSheet = false
                    }else if self.showInstructions == true{
                        //INSTRUCTIONS LOGIC
                        //Setting a boolean to indicate that the user has already seen the instructions. this should be called once for each user
                        if self.user.showInstructions == true{
                            self.user.showInstructions = false
                            self.user.setInstructionsToFalse()
                        }
                        self.showInstructions = false
                        
                    }
                    
                }){
                    Group{
                        if self.showInstructions == true{
                            //INSTRUCTIONS VIEW. USES DIFFERENT STRUCTURES IF USER IS USING IOS 14 OR LESS THAN THAT
                            if #available(iOS 14.0, *){
                                NavigationView{
                                    InstructionScroll(imageNames: self.imageNames, page: self.$currentPageInstructions)
                                        .navigationBarTitle(Text(self.getTitleForInstructions(index: self.currentPageInstructions)))
                                }.navigationViewStyle((StackNavigationViewStyle()))
                            }else{
                                NavigationView{
                                    VStack (spacing: 0){
                                        GeometryReader{g in
        
                                            PagedUIScrollView(imageNames: self.imageNames, size: g.frame(in: .global).size, page: self.$currentPageInstructions)
        
                                        }
                                        HStack{
                                            ForEach(0..<self.imageNames.count){index in
                                                Circle().fill(Color.gray).opacity(index == self.currentPageInstructions ? 1 : 0.5).frame(width:  10, height: 10)
                                            }
                                        }.padding(.bottom, 15)
        
                                    }.navigationBarTitle(Text(self.getTitleForInstructions(index: self.currentPageInstructions)))
                                }.navigationViewStyle((StackNavigationViewStyle()))
                            }
                            
                        }else if self.showSettingSheet == true{
                            //SETTINGS VIEW
                             NavigationView{
                                Form{
                                    Section(footer: Text("Select which test you want to take. This will change the contents of your testing library")){
                                        VStack{
                                            Picker(selection: self.$showQuickDataType, label: Text("Test Type")){
                                                Text("SAT").tag(TestType.sat).disabled(self.user.allSATPerformanceData == nil)
                                                Text("ACT").tag(TestType.act).disabled(self.user.allACTPerformanceData == nil)
                                                Text("PSAT").tag(TestType.psat).disabled(self.user.allPSATPerformanceData == nil)
                                            }
                                        }
                                    }
//                                    Section(footer: Text("For any questions or concerns please email us at: info@inductionLearning.com")){
//                                        Toggle(isOn: self.$leftHandMode){
//                                            Text("Left Hand Mode")
//                                        }
//                                    }
                                }.navigationBarTitle("Settings")

                            }.navigationViewStyle((StackNavigationViewStyle()))
                        }
                    }
                }
                        
                
        }.navigationViewStyle((StackNavigationViewStyle()))
        .opacity( (self.showInstructions || self.showSettingSheet) ? 1.0 : 1.0) //You need to initialize all state variables with somethign "related" to swiftui
        
    }
    
    func getTitleForInstructions(index: Int) -> String{
        if index < 8 {
            return "Downloading Your Tests"
        }else if index < 9{
            return "Tool Choices"
        }else{
            return "Looking into Tests"
        }
        
    }
    

//SHOWS ACTIVITY ICON IF NECESSAR
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
    var configuration = { (indicator: UIView) in } //fileprivate 
    
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

//SOME DESIGNS SO THERE IS CONSISTENCY ON THE PAGE
struct buttonBackgroundStyle: ButtonStyle {
    var disabled: Bool?
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(disabled == true ? Color(.lightGray) : Color(red: 0.12, green: 0.58, blue: 0.84))
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
            .background(Color(red: 0.12, green: 0.58, blue: 0.84))
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
            .background(Color(red: 0.12, green: 0.58, blue: 0.84))
            .cornerRadius(20)
            .padding()
    }
}




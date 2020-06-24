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
    var body: some View {
        NavigationView{
            HStack {
                VStack {
                    HStack {
                        
                        Text("Name: \(currentAuth.currentUser!.firstName)") //
                            .fontWeight(.bold)
                            .modifier(nameLabelStyle())
                        Spacer()
                        Text("Tutor: \(currentAuth.currentUser!.association.name)")
                            .fontWeight(.bold)
                            .modifier(nameLabelStyle())
                    }
                    .padding()
                    HStack(alignment: .top) {
                        VStack (alignment: .leading) {
                            
                            
                            NavigationLink(destination: TestTable(user: currentAuth.currentUser!, rootIsActive: self.$isTestActive), isActive: self.$isTestActive){
                                HStack{
                                    getLoadingIcon() //Folder or activity indicator saying it is loading
                                    Text(user.getTestsComplete == true ?  "Choose Test!" : "Loading Tests..." )
                                }
                            }.isDetailLink(false).buttonStyle(buttonBackgroundStyle(disabled: user.getTestsComplete == false)) //.isDetailLink(false)
                                .disabled(user.getTestsComplete == false)
                            
                            
                            
                            NavigationLink(destination: StudyTable(user: currentAuth.currentUser!, rootIsActive: self.$isStudyActive), isActive: self.$isStudyActive){
                                HStack{
                                    getLoadingIcon() //Folder or activity indicator saying it is loading
                                    Text(user.getTestsComplete == true ?  "Study Library" : "Loading Library..." )
                                }
                            }.isDetailLink(false).buttonStyle(buttonBackgroundStyle(disabled: user.getTestsComplete == false))
                                .disabled(user.getTestsComplete == false)
                            
                            NavigationLink(destination: PastPerformanceView(allData: (currentAuth.currentUser?.allACTPerformanceData))){
                                HStack{
                                    Image(systemName: "archivebox")
                                    Text("Past Performance")
                                }
                                }.buttonStyle(buttonBackgroundStyle())
//                            Button(action: {       //NavigationLink(destination: PastPerformanceTable()){
//
//                            }){
//                                HStack{
//                                    Image(systemName: "archivebox")
//                                    Text("Past Performance")
//                                }
//                            }.buttonStyle(buttonBackgroundStyle())
                            
                            Button(action: {
                                //what the button does
                            }) {
                                HStack {
                                    Image(systemName: "lightbulb")
                                    Text("Reccomended Study")
                                }
                            }
                            .buttonStyle(buttonBackgroundStyle())
                            
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
                            }
                            .buttonStyle(buttonBackgroundStyle())
                            
                            Spacer()
                            if user.association.image != nil{
                                Image(uiImage: user.association.image!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .padding()
                            }else{
                                Image("ilLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .padding()
                            }
                            
                            
                            
                        }
                        .padding()
                        
                        VStack {
                            BarContentView()
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .navigationBarTitle("Home Page", displayMode: .inline)
            }
        }.navigationViewStyle((StackNavigationViewStyle()))
    }
    
    func getLoadingIcon() -> AnyView{
        if user.getTestsComplete == true {
            return AnyView(Image(systemName: "folder"))
        }else{
            return AnyView(ActivityIndicator(isAnimating: true).configure { $0.color = .white })
        }
    }
    
    func saveContext() {
      do {
        try managedObjectContext.save()
      } catch {
        print("Error saving managed object context: \(error)")
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



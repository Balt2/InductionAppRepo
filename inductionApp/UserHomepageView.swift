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
  var body: some View {
    NavigationView{
      HStack {
          VStack {
              HStack {
               
                Text("Name: \(currentAuth.currentUser!.firstName)")
                      .fontWeight(.bold)
                      .modifier(nameLabelStyle())
                  Spacer()
                Text("Tutor ID: \(currentAuth.currentUser!.associationID)")
                      .fontWeight(.bold)
                      .modifier(nameLabelStyle())
              }
              .padding()
              HStack(alignment: .top) {
                  VStack (alignment: .leading) {
                    NavigationLink(destination: TestTable()){
                        HStack{
                            Image(systemName: "folder")
                            Text("Choose Test!")
                        }
                    }.buttonStyle(buttonBackgroundStyle())

                      NavigationLink(destination: StudyTable()){
                          HStack{
                              Image(systemName: "folder")
                              Text("Study Library")
                          }
                      }.buttonStyle(buttonBackgroundStyle())
                    
                      Button(action: {
                          //what the button does
                      }) {
                          HStack {
                              Image(systemName: "archivebox")
                              Text("Past Performance")
                          }
                      }
                      .buttonStyle(buttonBackgroundStyle())
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
                      Image("ilLogo")
                      .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 100)
                    .padding()
                      
                  }
                  .padding()
                BarContentView()
                  VStack {
                      Text("Average Score: ")
                          .fontWeight(.bold)
                          .modifier(infoLabelStyle())
                      Text("Best Section:")
                          .fontWeight(.bold)
                          .modifier(infoLabelStyle())
                      Text("Worst Section: ")
                          .fontWeight(.bold)
                          .modifier(infoLabelStyle())
                      Text("Best Sub-Category ")
                          .fontWeight(.bold)
                          .modifier(infoLabelStyle())
                      Text("Worst Sub-Category: ")
                          .fontWeight(.bold)
                          .modifier(infoLabelStyle())
                    Spacer()
                  }
                  Spacer()
              }
          }
          .navigationBarTitle("Home Page", displayMode: .inline)
        }
    }.navigationViewStyle((StackNavigationViewStyle()))
  }
}

struct UserHomepageView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomepageView()
    }
}

struct buttonBackgroundStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color("salmon"))
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

enum SectionName: Int, CaseIterable, Hashable, Identifiable {
    case overall = 0
    case reading
    case writing
    case math
    case science
    
    var name: String {
        return "\(self)".capitalized
    }

    var id: SectionName {self}
}


enum Days: CaseIterable, Hashable, Identifiable {
    
    case CSE
    case POW
    case KOL
    
    case KID
    case IK
    case CS
    
    case IES
    case Alg
    case Geom
    case Func
    case Modeling
    case NQ
    
    case IOD
    case SI
    case EM
    
    case ACT1
    case ACT2
    case ACT3
    
    
    var shortName: String {
        return String("\(self)".prefix(4)).capitalized
    }
    var id: Days {self}
    
}



struct BarContentView: View {
    
    @State var pickerSelectedItem = 0
    
    @State var data: [(dayPart: SectionName, caloriesByDay: [(day:Days, calories:Int)])] =
        [
                (
                    SectionName.overall,
                        [
                            (Days.ACT1, 28),
                            (Days.ACT2, 34),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.reading,
                        [
                            (Days.ACT1, 28),
                            (Days.ACT2, 32),
                            (Days.ACT3, 35)
                        ]
                ),
                (
                    SectionName.writing,
                        [
                            (Days.ACT1, 26),
                            (Days.ACT2, 33),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.math,
                        [
                            (Days.ACT1, 25),
                            (Days.ACT2, 34),
                            (Days.ACT3, 36)
                        ]
                ),
                (
                    SectionName.science,
                        [
                            (Days.ACT1, 30),
                            (Days.ACT2, 32),
                            (Days.ACT3, 36)
                        ]
                )
                
        ]

    
    
    
    var body: some View {
        ZStack {
            
            
            VStack {
                
                Text("Quick Data")
                    .foregroundColor(Color("lightBlue"))
                    .font(.system(size: 34))
                    .fontWeight(.heavy)
                
                Picker(selection: $pickerSelectedItem.animation(), label: Text("")) {
                   ForEach(SectionName.allCases) { dp in
                        Text(dp.name).tag(dp.rawValue)
                    }
                    
                    
                }.pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    .animation(.default)
                
                 
              HStack (spacing: 10) {
                     ForEach(0..<self.data[pickerSelectedItem].caloriesByDay.count, id: \.self)
                     { i in
                      
                        BarView(
                            value: self.data[self.pickerSelectedItem].caloriesByDay[i].calories,
                            label: self.data[self.pickerSelectedItem].caloriesByDay[i].day.shortName
                        )
                     
                     }
                
              }.padding(.top, 24)
               .animation(.default)
                
                
            }//vs
        }//zs
        
    }
}


struct BarView:  View {
    
    var value: Int
    var label: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 30, height: 216)
                    .foregroundColor(Color("lightBlue"))
                Capsule().frame(width: 30, height: CGFloat(value*6))
                    .foregroundColor( Color("salmon"))
            }
            Text(label)
                .padding(.top,8)
        }
    }
}

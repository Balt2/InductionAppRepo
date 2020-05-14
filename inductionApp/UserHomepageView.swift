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
    
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var shortName: String {
        return String("\(self)".prefix(2)).capitalized
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
                            (Days.sunday,28),
                            (Days.monday, 29),
                            (Days.tuesday, 28),
                            (Days.wednesday,33),
                            (Days.thursday, 31),
                            (Days.friday, 34),
                            (Days.saturday, 36)
                        ]
                ),
                (
                    SectionName.reading,
                        [
                            (Days.sunday, 29),
                            (Days.monday, 30),
                            (Days.tuesday, 34),
                            (Days.wednesday, 31),
                            (Days.thursday, 34),
                            (Days.friday, 35),
                            (Days.saturday, 35)
                        ]
                ),
                (
                    SectionName.writing,
                        [
                            (Days.sunday, 29),
                            (Days.monday, 30),
                            (Days.tuesday, 29),
                            (Days.wednesday, 31),
                            (Days.thursday, 34),
                            (Days.friday, 35),
                            (Days.saturday, 35)
                        ]
                ),
                (
                    SectionName.math,
                        [
                            (Days.sunday, 29),
                            (Days.monday, 30),
                            (Days.tuesday, 29),
                            (Days.wednesday, 32),
                            (Days.thursday, 36),
                            (Days.friday, 31),
                            (Days.saturday, 36)
                        ]
                ),
                (
                    SectionName.science,
                        [
                            (Days.sunday, 29),
                            (Days.monday, 30),
                            (Days.tuesday, 29),
                            (Days.wednesday, 33),
                            (Days.thursday, 32),
                            (Days.friday, 36),
                            (Days.saturday, 32)
                        ]
                )
                
        ]

    
    
    
    var body: some View {
        ZStack {
            
            Color("background").edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Text("Quick Data")
                    .foregroundColor(Color.blue)
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
                    .foregroundColor(Color(#colorLiteral(red: 0.160164088, green: 0.2815363109, blue: 0.3686951399, alpha: 1)))
                Capsule().frame(width: 30, height: CGFloat(value*6))
                    .foregroundColor(.orange)
            }
            Text(label)
                .padding(.top,8)
        }
    }
}

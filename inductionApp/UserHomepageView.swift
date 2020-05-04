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
                    
                    NavigationLink(destination: TestView(testData: (currentAuth.currentUser?.tests[0])!)) {
                         HStack {
                              Image(systemName: "folder")
                               Text("Take Test!")
                          }
                        }
                      .buttonStyle(buttonBackgroundStyle())
                      Button(action: {
                          //What the button does
                      }) {
                          HStack {
                              Image(systemName: "folder")
                              Text("Study Library")
                          }
                      }
                      .buttonStyle(buttonBackgroundStyle())
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

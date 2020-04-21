//
//  UserHomepageView.swift
//  InductionApp
//
//  Created by Ben Altschuler on 4/21/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI
import Firebase

struct UserHomepageView: View {
    var user: User
    
  var body: some View {
      HStack {
          VStack {
              HStack {
               
                Text("Name: \(user.association)")
                      .fontWeight(.bold)
                      .modifier(nameLabelStyle())
                  Spacer()
                  Text("TUTOR GROUP")
                      .fontWeight(.bold)
                      .modifier(nameLabelStyle())
              }
              .padding()
              HStack(alignment: .top) {
                  VStack (alignment: .leading) {
                      Button(action: {
                          //What the button does
                      }) {
                          HStack {
                              Image(systemName: "folder")
                               Text("Test Library")
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
                            do {
                                print("BEN")
                                try Auth.auth().signOut()
                            } catch{
                                print("ERROR logging out")
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
                      
                  }
                  .padding()
                  VStack {
                      Image("empireEdge")
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
                  }
                  Spacer()
              }
          }
      }
  }
}

struct UserHomepageView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomepageView(user: User(fn: "B", ln: "L", id: "D"))
    }
}

struct buttonBackgroundStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color(.red).opacity(0.5))
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
            .background(Color(.blue).opacity(0.5))
            .cornerRadius(20)
    }
}


struct infoLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .font(.system(.title, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .background(Color(.blue).opacity(0.5))
            .cornerRadius(20)
            .padding()
    }
}

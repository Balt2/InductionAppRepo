//
//  LoginView.swift
//  inductionApp
//
//  Created by Josh Breite on 4/20/20.
//  Copyright © 2020 Josh Breite. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    
    @ObservedObject private var userRegistrationViewModel = UserRegistrationViewModel()
    @EnvironmentObject var currentAuth: UserAuth
    
    var body: some View {
        VStack {
            Image("ilLogo")
                .padding()
            
            userFormField(fieldName: "Email", fieldValue: $userRegistrationViewModel.email)
                .padding()
            FormField(fieldName: "Password", fieldValue: $userRegistrationViewModel.password, isSecure: true)
                .padding()
            Button(action: {
                if (self.userRegistrationViewModel.isemailValid && self.userRegistrationViewModel.isPasswordLengthValid
                && self.userRegistrationViewModel.isPasswordCapitalLetter){
                    Auth.auth().signIn(withEmail: self.userRegistrationViewModel.email, password: self.userRegistrationViewModel.password) { authResult, error in
                        if let error = error {
                            print(self.userRegistrationViewModel.email)
                            print(self.userRegistrationViewModel.password)
                            print("Error logging in: \(error.localizedDescription)")
                        }else{
                            //Create User here
//                            guard let strongSelf = self else { return }
//
//                            strongSelf.createUser(id: authResult!.user.uid, completionHandler: { (success) -> Void in
//                                if success {
//                                    strongSelf.performSegue(withIdentifier: "logInSuccsessFromLogin", sender: strongSelf)
//                                }else{
//                                    //ERROR
//                                }
//                            })
//                            //Segue to user profile
                        }

                    }
                }
            }) {
                Text("Sign In")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(.orange))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
    }
}

struct LoginView_previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


struct userFormField: View {
    var fieldName = ""
    @Binding var fieldValue: String
    
    var isSecure = false
    
    var body: some View {
        
        VStack {
            if isSecure {
                SecureField(fieldName, text: $fieldValue)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                
            } else {
                TextField(fieldName, text: $fieldValue)                 .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                .padding(.horizontal)
            
        }
    }
}


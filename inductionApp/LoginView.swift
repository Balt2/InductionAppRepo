//
//  LoginView.swift
//  inductionApp
//
//  Created by Ben Altschuler on 4/20/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    
    @ObservedObject private var userRegistrationViewModel = UserRegistrationViewModel()
    @EnvironmentObject var currentAuth: FirebaseManager
    
    func signIn () {
        currentAuth.signIn(email: userRegistrationViewModel.email, password: userRegistrationViewModel.password){ (result, error) in
            if error != nil{
                print("ERROR Logging in")
            } else{
                print("Succsess logging in")
            }
            
        }
    }
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
                    self.signIn()
//                    Auth.auth().signIn(withEmail: self.userRegistrationViewModel.email, password: self.userRegistrationViewModel.password) { authResult, error in
//                        if let error = error {
//                            print(self.userRegistrationViewModel.email)
//                            print(self.userRegistrationViewModel.password)
//                            print("Error logging in: \(error.localizedDescription)")
//                        }else{
//                            //Create User here
//                        }

                    //}
                }else{
                    print("Login Failed")
                }
            }) {
                Text("Sign In")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color("salmon"))
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


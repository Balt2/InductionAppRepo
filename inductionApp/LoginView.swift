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
    
    //MODEL FOR CAPTURING LOGIN INFORMATION
    @ObservedObject private var userRegistrationViewModel = UserRegistrationViewModel()
    //INSTANCE OF CURRENT AUTH TO GET INFORMATION ABOUT CURRENT USER
    @EnvironmentObject var currentAuth: FirebaseManager
    @State private var showingErrorCredentials = false
    
    func signIn () {
        //TRY TO SIGN IN WITH GIVEN CREDENTIALS. THIS SENDS A REQUEST TO FIREBASE
        currentAuth.signIn(email: userRegistrationViewModel.email, password: userRegistrationViewModel.password){ (result, error) in
            if error != nil{
                self.showingErrorCredentials = true
                print("ERROR Logging in")
            } else{
                print("Succsess logging in")
            }
            
        }
    }
    
    var body: some View {
        VStack {
            
            Spacer(minLength: 50)
            //USER INPUTS
            userFormField(fieldName: "Email", fieldValue: $userRegistrationViewModel.email)
                .padding()
            FormField(fieldName: "Password", fieldValue: $userRegistrationViewModel.password, isSecure: true)
                .padding()
            Button(action: {
                if (self.userRegistrationViewModel.isemailValid && self.userRegistrationViewModel.isPasswordLengthValid
                && self.userRegistrationViewModel.isPasswordCapitalLetter){
                    self.signIn()
                }else{
                    self.showingErrorCredentials = true
                    print("Login Failed")
                }
            }) {
                Text("Sign In")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(red: 0.15, green: 0.68, blue: 0.37))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }.alert(isPresented: $showingErrorCredentials) {
                Alert(title: Text("Error Logging In"),
                      message: Text("Please use correct credentials. If you have not created an account, create one."),
                      dismissButton: .default(Text("OK")))
            }
            Image("ilLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
    }
}

struct LoginView_previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//RE-USABLE STRUCT FOR INPUTS SO ITS CONSTANT ON THE PAGE
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
                TextField(fieldName, text: $fieldValue)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color(red: 240/255, green: 240/255, blue: 240/255))
                .padding(.horizontal)
            
        }
    }
}


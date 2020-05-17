//
//  SignupView.swift
//  inductionApp
//
//  Created by Ben Altschuler on 4/20/20.
//  Copyright © 2020 Ben Altschuler. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseUI

struct SignupView: View {
    
    
    //Observable object that contains data that the user puts in when creating a class
    @ObservedObject private var userRegistrationViewModel = UserRegistrationViewModel()
    @EnvironmentObject var currentAuth: FirebaseManager
    var db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack {
                Image("ilLogo").resizable()
                .aspectRatio(contentMode: .fit)
                VStack {
                    
                    //.padding()
                    VStack {
                    FormField(fieldName: "First Name", fieldValue: $userRegistrationViewModel.firstName)
                    FormField(fieldName: "Last Name", fieldValue: $userRegistrationViewModel.lastName)
                    }
                    
                    FormField(fieldName: "Email", fieldValue: $userRegistrationViewModel.email)
                    RequirementText(iconColor: userRegistrationViewModel.isemailValid ? Color.secondary : Color(red: 251/255, green: 128/255, blue: 128/255), text: "A minimum of 4 characters and valid email", isStrikeThrough: userRegistrationViewModel.isemailValid)
                        .padding()
                    
                    FormField(fieldName: "Password", fieldValue: $userRegistrationViewModel.password, isSecure: true)
                    VStack {
                        RequirementText(iconName: "lock.open", iconColor: userRegistrationViewModel.isPasswordLengthValid ? Color.secondary : Color(red: 251/255, green: 128/255, blue: 128/255), text: "A minimum of 8 characters", isStrikeThrough: userRegistrationViewModel.isPasswordLengthValid)
                        RequirementText(iconName: "lock.open", iconColor: userRegistrationViewModel.isPasswordCapitalLetter ? Color.secondary : Color(red: 251/255, green: 128/255, blue: 128/255), text: "One uppercase letter", isStrikeThrough: userRegistrationViewModel.isPasswordCapitalLetter)
                    }
                    .padding()
                    
                    FormField(fieldName: "Confirm Password", fieldValue: $userRegistrationViewModel.passwordConfirm, isSecure: true)
                    RequirementText(iconColor: userRegistrationViewModel.isPasswordCapitalLetter ? Color.secondary : Color(red: 251/255, green: 128/255, blue: 128/255), text: "Your confirm password should be the same as password", isStrikeThrough: userRegistrationViewModel.isPasswordConfirmValid)
                        .padding()
                    FormField(fieldName: "Association ID", fieldValue: $userRegistrationViewModel.associationID)
                    
                    
                    Button(action: {
                        //Check if email is valid, check if password is minum 8 characters and has on upercase letter, Check confirm password is equal to password
                        if (self.userRegistrationViewModel.isemailValid && self.userRegistrationViewModel.isPasswordLengthValid
                            && self.userRegistrationViewModel.isPasswordCapitalLetter && self.userRegistrationViewModel.isPasswordConfirmValid && self.userRegistrationViewModel.isAssociationIDLengthValid){
                                
                            self.currentAuth.signUp(userRegModel: self.userRegistrationViewModel) { succsess in
                                if succsess == true{
                                    print("Signed UP and loged in")
                                }else{
                                    print("ERROR Signing up")
                                }
                            }
                        }else{
                            print("Error on Sign up: Invalid Email and/or password")
                        }
                        
                    }) {
                        Text("Sign Up")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(red: 255/255, green: 126/255, blue: 103/255))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                    }
                    
                    HStack {
                        Text("Already have an account?")
                            .font(.system(.body, design: .rounded))
                            .bold().padding(.bottom, 25.0)
                        NavigationLink(destination: LoginView()){
                            Text("Sign in")
                                .font(.system(.body, design: .rounded))
                                .bold()
                                .foregroundColor(Color(red: 255/255, green: 126/255, blue: 103/255))
                        }.padding(.bottom, 25.0)
                    }
                }
                
                // Spacer()
            }
            .padding()
        }.navigationViewStyle(StackNavigationViewStyle())
            .edgesIgnoringSafeArea(.bottom)
        
    }
    
    
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView().previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
    }
}

struct FormField: View {
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

struct RequirementText: View {
    
    var iconName = "xmark.square"
    var iconColor = Color(red: 251/255, green: 128/255, blue: 128/255)
    
    var text = ""
    var isStrikeThrough = false
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .strikethrough(isStrikeThrough)
            Spacer()
        }
    }
}
////
////  LoginView.swift
////  TapCash
////
////  Created by DHIKA ADITYA ARE on 19/08/26.
////
//
//import SwiftUI
//
//struct LoginView: View {
//    @ObservedObject var vm: WithdrawalViewModel
//    @State private var email = "alex@tapcash.demo"
//    @State private var password = "cash1234"
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Eyebrow(text: "TapCash")
//            Text("Cardless cash")
//                .font(.system(size: 40, weight: .bold, design: .rounded))
//                .foregroundStyle(Palette.ink)
//            Text("Sign in to your SIMULATED account.")
//                .foregroundStyle(Palette.muted)
//
//            TextField("Email", text: $email)
//                .textInputAutocapitalization(.never)
//                .keyboardType(.emailAddress)
//                .textFieldStyle(.roundedBorder)
//            SecureField("Password", text: $password)
//                .textFieldStyle(.roundedBorder)
//
//            if let error = vm.errorMessage {
//                Text(error).foregroundStyle(.red).font(.footnote)
//            }
//
//            Button(vm.loading ? "Signing in…" : "Sign in") {
//                vm.login(email: email, password: password)
//            }
//            .buttonStyle(PrimaryButtonStyle(enabled: !vm.loading))
//            .disabled(vm.loading)
//
//            Spacer()
//        }
//        .padding(24)
//    }
//}

//
//  LoginScreen.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginScreenViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EyebrowView(text: "TapCash")
            Text("Cardless cash")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.ink)
            Text("Sign in to your SIMULATED account.")
                .foregroundStyle(Palette.muted)

            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.footnote)
            }

            Button(viewModel.loading ? "Signing in…" : "Sign in") {
                viewModel.login()
            }
            .buttonStyle(PrimaryButtonStyle(enabled: !viewModel.loading))
            .disabled(viewModel.loading)

            Spacer()
        }
        .padding(24)
        .dismissKeyboardOnTapBackground()
    }
}

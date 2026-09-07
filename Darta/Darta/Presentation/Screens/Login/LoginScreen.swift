//
//  LoginScreen.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginScreenViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                // MARK: - Header & Brand Emblem
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Palette.goldGradient)
                                .frame(width: 52, height: 52)
                                .shadow(color: Palette.amber.opacity(0.4), radius: 12, x: 0, y: 4)

                            Image(systemName: "creditcard.and.123")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color(red: 0x0D/255, green: 0x0D/255, blue: 0x12/255))
                        }

                        Spacer()

                        EyebrowView(text: "Digital Banking", iconName: "sparkles")
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Darta Cash")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(Palette.ink)

                        Text("Instant, cardless cash withdrawal at your fingertips.")
                            .font(.subheadline)
                            .foregroundStyle(Palette.inkSecondary)
                            .lineSpacing(3)
                    }
                }
                .padding(.top, 20)

                // MARK: - Form Card
                VStack(spacing: 18) {
                    DartaTextField(
                        title: "Email address",
                        iconName: "envelope.fill",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )

                    DartaTextField(
                        title: "Password",
                        iconName: "lock.fill",
                        text: $viewModel.password,
                        isSecure: true
                    )

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.subheadline)
                                .foregroundStyle(Palette.red)

                            Text(error)
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Palette.red)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Palette.red.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Palette.red.opacity(0.3), lineWidth: 1)
                        )
                    }

                    Button {
                        viewModel.login()
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.loading {
                                ProgressView()
                                    .tint(Color(red: 0x0D/255, green: 0x0D/255, blue: 0x12/255))
                                Text("Signing in…")
                            } else {
                                Text("Sign In")
                                Image(systemName: "arrow.right")
                                    .font(.headline.weight(.bold))
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(enabled: !viewModel.loading))
                    .disabled(viewModel.loading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Palette.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Palette.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)

                // MARK: - Demo Info Footnote
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)

                    Text("Testing environment: alex@tapcash.demo / cash1234")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 24)
        }
        .background(
            ZStack {
                Palette.canvas.ignoresSafeArea()
                Palette.radialAmbient.ignoresSafeArea()
            }
        )
        .dismissKeyboardOnTapBackground()
    }
}

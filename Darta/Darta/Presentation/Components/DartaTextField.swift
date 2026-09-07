//
//  DartaTextField.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI

public struct DartaTextField: View {
    let title: String
    let iconName: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool

    public init(
        title: String,
        iconName: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .never
    ) {
        self.title = title
        self.iconName = iconName
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isFocused ? Palette.amber : Palette.muted)
                .frame(width: 20)

            Group {
                if isSecure && !isPasswordVisible {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(title).foregroundColor(Palette.muted)
                    )
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(title).foregroundColor(Palette.muted)
                    )
                }
            }
            .focused($isFocused)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .foregroundStyle(Palette.ink)
            .font(.body)

            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Palette.muted)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Palette.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isFocused ? Palette.amber : Palette.border,
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .shadow(
            color: isFocused ? Palette.amber.opacity(0.18) : Color.clear,
            radius: 8,
            x: 0,
            y: 0
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

//
//  UIView+Extensions.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import Foundation
import SwiftUI

extension View {
    func dismissKeyboardOnTap(
        _ handler: @escaping TypeAliases.VoidHandler = { return }
    ) -> some View {
        self.onTapGesture {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }?
                .windows
                .first?
                .endEditing(true)
            handler()
        }
    }
    
    func dismissKeyboardOnTapBackground(
        _ handler: @escaping TypeAliases.VoidHandler = { return }
    ) -> some View {
        self.background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                    handler()
                }
        )
    }
}

//
//  Eyebrow.swift
//  TapCash
//
//  Created by DHIKA ADITYA ARE on 21/08/26.
//

import SwiftUI

struct Eyebrow: View {
    let text: String
    
    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(2)
            .foregroundStyle(Palette.muted)
    }
}

//
//  Theme.swift
//  Darta
//
//  Created by DHIKA ADITYA ARE on 20/08/26.
//

import SwiftUI
import UIKit

/// Darta "Luxury Obsidian & Amber" design system palette & tokens.
public enum Palette {
    // MARK: - Core Theme Colors
    public static let canvas = Color(red: 0x0D/255, green: 0x0D/255, blue: 0x12/255)
    public static let surface = Color(red: 0x17/255, green: 0x17/255, blue: 0x20/255)
    public static let surfaceElevated = Color(red: 0x22/255, green: 0x22/255, blue: 0x2E/255)
    public static let surfaceHighlight = Color(red: 0x2C/255, green: 0x2C/255, blue: 0x3B/255)
    
    // MARK: - Amber & Gold Accents
    public static let amber = Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)
    public static let amberLight = Color(red: 0xFB/255, green: 0xBF/255, blue: 0x24/255)
    public static let amberDark = Color(red: 0xB4/255, green: 0x53/255, blue: 0x09/255)
    public static let gold = Color(red: 0xE6/255, green: 0xAF/255, blue: 0x38/255)
    
    // MARK: - Backwards Compatibility Aliases
    public static let orange = amber
    public static let navy = Color(red: 0x1E/255, green: 0x1E/255, blue: 0x2A/255)
    
    // MARK: - Typography & Feedback Colors
    public static let ink = Color(red: 0xF9/255, green: 0xFA/255, blue: 0xFB/255)
    public static let inkSecondary = Color(red: 0x9C/255, green: 0xA3/255, blue: 0xAF/255)
    public static let muted = Color(red: 0x6B/255, green: 0x72/255, blue: 0x80/255)
    public static let green = Color(red: 0x10/255, green: 0xB9/255, blue: 0x81/255)
    public static let red = Color(red: 0xEF/255, green: 0x44/255, blue: 0x44/255)
    
    // MARK: - Borders & Dividers
    public static let border = Color.white.opacity(0.08)
    public static let borderGlow = amber.opacity(0.35)
    
    // MARK: - Gradients
    public static let goldGradient = LinearGradient(
        colors: [amberLight, amber, amberDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardGradient = LinearGradient(
        colors: [
            Color(red: 0x22/255, green: 0x22/255, blue: 0x2E/255),
            Color(red: 0x14/255, green: 0x14/255, blue: 0x1B/255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let goldCardGradient = LinearGradient(
        colors: [
            Color(red: 0x2C/255, green: 0x23/255, blue: 0x13/255),
            Color(red: 0x17/255, green: 0x14/255, blue: 0x0E/255)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let radialAmbient = RadialGradient(
        colors: [amber.opacity(0.12), Color.clear],
        center: .top,
        startRadius: 20,
        endRadius: 350
    )
}

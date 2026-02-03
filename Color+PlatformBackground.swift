//
//  Color+PlatformBackground.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-03.
//

import SwiftUI

// MARK: Color extensions
/// Shared colors that adapt to the current platform (iOS / macOS).
extension Color {
    
    // MARK: Primary background
    /// Returns the system background color for the current platform.
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
    
    // MARK: Secondary background
    /// Returns the secondary system background color for the current platform.
    static var secondarySystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.secondary
        #endif
    }
}

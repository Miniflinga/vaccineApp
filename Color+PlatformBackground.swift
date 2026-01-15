//
//  Color+PlatformBackground.swift
//  vaccineApp
//
//  Skapad för att samla plattformsoberoende färgextensioner.
//

import SwiftUI

extension Color {
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
}

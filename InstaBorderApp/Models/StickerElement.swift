import SwiftUI

// MARK: - Sticker Element Re-export
// StickerElement is defined in CanvasElement.swift
// This file provides additional convenience extensions

extension StickerElement {
    /// Default sticker size (1.5x of original 64)
    static let defaultSize: CGFloat = 96
    
    /// Minimum scale (0.3x)
    static let minScale: CGFloat = 0.3
    
    /// Maximum scale (4.0x)
    static let maxScale: CGFloat = 4.0
}

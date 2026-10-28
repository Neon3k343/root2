//
//  FocalLength.swift.swift
//  root2
//
//  Created by Hubert  Greszta on 28/10/2026.
//

import Foundation
import SwiftUI

enum FocalLength: Int, CaseIterable, Identifiable {
    case ultraWide = 13
    case wide = 24
    case normal = 35
    case tele = 72
    case superTele = 120
    
    var id: Int { rawValue }
    var label: String { "\(rawValue)" }
}

//
//  test.swift
//  root2
//
//  Created by Hubert  Greszta on 29/09/2026.
//

import SwiftUI

struct DragIndependentView: View {
    // 1. Track the active drag distance
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        HStack(spacing: 20) {
            Circle()
                .fill(.blue)
                .frame(width: 80, height: 80)
            
            // This is the draggable item
            Circle()
                .fill(.red)
                .opacity(0.5)
                .glassEffect()
                .frame(width: 80, height: 80)
                // 2. Apply the offset to move the view
                .offset(dragOffset)
                // 3. Attach the DragGesture
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the offset as the finger moves
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            // Snap back to the original layout position on release
                            withAnimation(.spring()) {
                                dragOffset = .zero
                            }
                        }
                )
            
            Circle()
                .fill(.green)
                .frame(width: 80, height: 80)
        }
        .padding()
    }
}

#Preview {
    DragIndependentView()
}

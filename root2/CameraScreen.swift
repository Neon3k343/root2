//
//  CameraScreen.swift
//  Instants camera
//
//  Created by Hubert  Greszta on 27/09/2026.
//

import SwiftUI

public extension Color {
    static let yellowish = Color(.displayP3, red: 1.0, green: 0.8, blue: 0.0)
}

extension ButtonStyle where Self == ShrinkingButtonStyle {
  static var shrinking: ShrinkingButtonStyle {
    ShrinkingButtonStyle()
  }
}

struct ShrinkingButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .scaleEffect(configuration.isPressed ? 0.9 : 1)
          .opacity(configuration.isPressed ? 0.8 : 1)
          .animation(.snappy(duration: 0.2), value: configuration.isPressed)
  }
}

struct CameraScreen: View {
    
    @Namespace private var lensNamespace
    @State private var selectedLens: Int = 24
    @State private var availableLenses: [Int] = [13, 24, 35, 48, 72, 120]
    @State private var isFlash: Bool = false
    @State private var exposureEV: Int = 0
    @State var offset: CGFloat = .zero
    @State var dragOffset: CGFloat = .zero
    @State var currentOffset: CGFloat = .zero
    
    let pointsPerStep: CGFloat = 12.0
    let rawOffset = currentOffset + dragOffset
    let snappedSteps = round(rawOffset / pointsPerStep)
    let targetOffset = snappedSteps * pointsPerStep
    
    var body: some View {
        
        VStack(){
            Spacer()
            VStack{
                HStack{
                    
                    // lens bar
                    HStack(spacing: 0){
                        ForEach(availableLenses, id: \.self) { lens in
                            Button{
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)){
                                    selectedLens = lens
                                }
                            } label: {
                                Text("\(lens)")
                                    .font(.system(size: 14))
                                    .fontWeight(selectedLens == lens ? .black : .regular)
                                    .monospaced()
                                    .foregroundColor(
                                        selectedLens == lens ? Color.yellowish : Color.white
                                    )
                                    .frame(width: 48 , height: 36)
                                    .background{
                                        if selectedLens == lens {
                                            activePillView()
                                        }
                                    }
                            }
                        }
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: selectedLens)
                    .padding(.leading, 0)
                    .padding(.trailing, 0)
                    .glassEffect()
                    .safeAreaPadding(.horizontal)
                    
                    
                }
                
                HStack{
                    
                    //gallery button
                    Button {
                        
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundStyle(Color.primary)
                            .frame(width: 72, height: 72)
                            .contentShape(Circle())
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isFlash)
                    .buttonStyle(.shrinking)
                    .glassEffect()
                    .safeAreaPadding(.horizontal)
                    
                    Spacer()
                    
                    // shutter button
                    Button {
                        
                    } label: {
                        Color.clear
                            .frame(width: 144, height: 72)
                            .background(Color.yellowish, in: Capsule())
                    }
                    .buttonStyle(.shrinking)
                    .padding(8)
                    .glassEffect()
                    
                    Spacer()
                    
                    // rotate button
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.largeTitle)
                            .foregroundStyle(Color.primary)
                            .frame(width: 72, height: 72)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.shrinking)
                    .glassEffect()
                    .safeAreaPadding(.horizontal)
                }
                
                HStack{
                    
                    // flash button
                    Button{
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isFlash.toggle()
                        }
                    } label: {
                        Image(systemName: isFlash ? "bolt.fill" : "bolt.slash.fill")
                            .font(.default)
                            .foregroundStyle(
                                isFlash ? Color.black : Color.white
                            )
                            .frame(width: 72, height: 36)
                            .contentShape(Capsule())
                            .background(
                                isFlash ? Color.yellowish : Color.clear,
                                in: Capsule()
                                    .inset(by: 3)
                            )
                        
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isFlash)
                    .glassEffect()
                    .safeAreaPadding(.horizontal)
                    
                    Spacer()
                    
                    // exposure bar
                    VStack(spacing: 0){
                        
                        //number
                        HStack(){
                            Text("\(Int(exposureEV))")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        
                        //bar
                        ZStack{
                            HStack(){
                                Text("move me")
                                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: dragOffset)
                                    .offset(x: currentOffset + dragOffset)
                                
                                Text("move me")
                                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: dragOffset)
                                    .offset(x: currentOffset + dragOffset)
                            }
                            
                        }
                        .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.25), .init(color: .black, location: 0.75), .init(color: .clear, location: 1.0)], startPoint: .leading, endPoint: .trailing))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    currentOffset += value.translation.width
                                    dragOffset = 0
                                }
                        )
                    }
                    
                    Spacer()

                    // flash button
                    Button{
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isFlash.toggle()
                        }
                    } label: {
                        Image(systemName: isFlash ? "bolt.fill" : "bolt.slash.fill")
                            .font(.default)
                            .foregroundStyle(
                                isFlash ? Color.black : Color.white
                            )
                            .frame(width: 72, height: 36)
                            .contentShape(Capsule())
                            .background(
                                isFlash ? Color.yellowish : Color.clear,
                                in: Capsule()
                                    .inset(by: 3)
                            )
                        
                    }
                    .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isFlash)
                    .buttonStyle(.shrinking)
                    .glassEffect()
                    .safeAreaPadding(.horizontal)
                }
            }
        }
    }
    
    @ViewBuilder
    private func activePillView() -> some View {
        Capsule()
            .glassEffect()
            .foregroundColor(Color.clear)
            .padding(2)
            .matchedGeometryEffect(id: "activePill", in: lensNamespace)
    }
}



#Preview {
    CameraScreen()
}


//Capsule()
//    .fill(Color(.displayP3, red: 1.0, green: 0.8, blue: 0.0))
//    .overlay {
//        Capsule()
//            .strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
//    }
//    .background(.ultraThinMaterial, in: Capsule())


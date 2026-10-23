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
    
    @State private var cameraManager = CameraManager()
    @State private var selectedEV: Int = 0
    
    var body: some View {
        VStack{
            CameraTopBarView()
            CameraViewfinderView()
            LensBarView()
            CaptureControlsView()
            SecondaryControlsView()
                .padding(.top)
            ExposureSliderView(selectedEV: $selectedEV)
                .offset(x: 0, y: -48)
        }
        .background(Color.black.ignoresSafeArea())
        
    }
}

struct CameraTopBarView: View {
    
    @State var isMenu: Bool = false
    
    var body: some View {
        //top
        VStack{
            
            HStack{
                // menu button
                Button{
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isMenu.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 72, height: 36)
                        .contentShape(Capsule())
                }
                .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isMenu)
                .glassEffect()
                .safeAreaPadding(.horizontal)
                
                Spacer()
                
                //TBD button
                Button{
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isMenu.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 72, height: 36)
                        .contentShape(Capsule())
                }
                .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isMenu)
                .glassEffect()
                .safeAreaPadding(.horizontal)
            }
        }
        .statusBar(hidden: true)
    }
}

struct CameraViewfinderView: View {
    
    @State private var cameraManager = CameraManager()
    
    var body: some View {
        CameraPreviewView(session: cameraManager.session)
            .ignoresSafeArea(edges: .all)
            .aspectRatio((1.0 / sqrt(2.0)), contentMode: .fit)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

struct LensBarView: View {
    
    @Namespace private var lensNamespace
    @State private var selectedLens: Int = 24
    @State private var availableLenses: [Int] = [13, 24, 35, 48, 72, 120]
    
    var body: some View {
        
        // bottom 1st layer
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

struct CaptureControlsView: View {
    
    var body: some View {
        
        //bottom 2nd layer
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
//            .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isFlash)
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
    }
    
}

struct SecondaryControlsView: View {
    
    @State private var isFlash: Bool = false
    @State private var isRAW: Bool = false
    
    var body: some View {
        
        HStack{
            // RAW button
            Button{
                withAnimation(.easeInOut(duration: 0.25)) {
                    isRAW.toggle()
                }
            } label: {
                Text("RAW")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .strikethrough(!isRAW)
                    .foregroundStyle(isRAW ? Color.yellowish : Color.white)
                    .frame(width: 72, height: 36)
                    .contentShape(Capsule())
            }
            .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isFlash)
            .glassEffect()
            .tint(isRAW ? Color.yellowish : Color.white)
            .safeAreaPadding(.horizontal)
            
            Spacer()
            
            
            
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
    
    
    struct ExposureRulerView: View {
        var body: some View {
            
        }
    }
}

struct ExposureSliderView: View {
    
    @State private var cameraManager = CameraManager()
    @State private var availableEV: [Double] = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6]
    @Binding var selectedEV: Int
    @State private var dragOffset: CGFloat = .zero
    @State private var currentOffset: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0){
            
            //number
            HStack(){
                var formattedEV: String {
                    switch selectedEV {
                    case -6: "-2"
                    case -5: "-1⅔"
                    case -4: "-1⅓"
                    case -3: "-1"
                    case -2: "-0⅔"
                    case -1: "-0⅓"
                    case 0: "0"
                    case 1: "+0⅓"
                    case 2: "+0⅔"
                    case 3: "+1"
                    case 4: "+1⅓"
                    case 5: "+1⅔"
                    case 6: "+2"
                    default: "?"
                    }
                }
                Text(formattedEV)
                    .font(Font.system(size: 14, weight: .black, design: .monospaced))
            }
            
            //dial
            HStack(spacing: 20){
                ForEach(availableEV, id: \.self) { ev in
                    let isMajor = Int(round(ev)) % 3 == 0
                    Rectangle()
                        .frame(width: 4, height: (isMajor || selectedEV == Int(ev)) ? 14 : 10)
                        .opacity((isMajor || selectedEV == Int(ev)) ? 1 : 0.5)
                        .opacity(abs(selectedEV - Int(ev)) < 4 ? 1 : 0)
                        .foregroundStyle(selectedEV == Int(ev) ? .yellowish : .white)
                        .cornerRadius(2)
                    
                }
                .offset(x: currentOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            
                            let rawOffset = currentOffset + value.translation.width
                            let minBound = -6.0 * Layout.pointsPerStep
                            let maxBound = 6.0 * Layout.pointsPerStep
                            let visualOffset: CGFloat
                            if rawOffset > maxBound {
                                let excess = rawOffset - maxBound
                                visualOffset = maxBound + (sqrt(excess) * 3.5)
                            } else if rawOffset < minBound {
                                let excess = minBound - rawOffset
                                visualOffset = minBound - (sqrt(excess) * 3.5)
                            } else {
                                visualOffset = rawOffset
                            }
                            dragOffset = visualOffset - currentOffset
                            let rawStep = Int(round((currentOffset + dragOffset) / Layout.pointsPerStep))
                            let clampedStep = min(max(rawStep, -6), 6)
                            selectedEV = -clampedStep
                            
                            print("offset: \(currentOffset + dragOffset), step: \(clampedStep)")
                        }
                        .onEnded { value in
                            let rawOffset = currentOffset + dragOffset
                            let snappedStep = round(rawOffset / Layout.pointsPerStep)
                            let clampedStep = min(max(snappedStep, -6), 6)
                            let finalTarget = clampedStep * Layout.pointsPerStep;
                            
                            print("offset: \(currentOffset + dragOffset), step: \(clampedStep)")
                            
                            withAnimation(.easeOut(duration: 0.12)) {
                                currentOffset = finalTarget
                                dragOffset = 0
                            }
                        }
                )
                .sensoryFeedback(.selection, trigger: selectedEV)
            }
            .mask(LinearGradient(stops: [.init(color: .clear, location: 0.2), .init(color: .black, location: 0.5), .init(color: .black, location: 0.5), .init(color: .clear, location: 0.8)], startPoint: .leading, endPoint: .trailing))
            .frame(width: 200, height: 36)
        }
        .onChange(of: selectedEV) { _, newValue in
            cameraManager.setExposureBias(Float(newValue) / 3)
        }
    }
    
    private enum Layout {
        static let pointsPerStep: CGFloat = 24.0
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



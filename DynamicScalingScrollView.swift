//
//  DynamicScalingScrollView.swift
//  mj
//
//  Created by Gray Crawford on 7/11/24.
//


import SwiftUI

struct DynamicScalingScrollView: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var activeIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    let itemCount = 4
    
    var body: some View {
        GeometryReader { geometry in
            let fullWidth = geometry.size.width * 0.9
            let fullHeight = fullWidth
            let compactWidth = fullWidth / CGFloat(itemCount)
            let compactHeight = compactWidth
            let spacing: CGFloat = 4
            
            ZStack {
                // Background
                Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_1")
                    .resizable()
                    .scaleEffect(1.4)
                    .blur(radius: 80)
                    .saturation(3)
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: spacing) {
                    // Main scrollable area
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: spacing) {
                            ForEach(0..<itemCount, id: \.self) { index in
                                ItemView(index: index,
                                         fullSize: CGSize(width: fullWidth, height: fullHeight),
                                         compactSize: CGSize(width: compactWidth, height: compactHeight),
                                         scrollOffset: scrollOffset,
                                         activeIndex: activeIndex)
                            }
                        }
                        .frame(height: geometry.size.height * 2) // Adjust based on your needs
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        activeIndex = Int(-scrollOffset / fullHeight)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        let sensitivity: CGFloat = 50
                        if abs(value.translation.height) > sensitivity {
                            withAnimation(.spring()) {
                                activeIndex = max(0, min(itemCount - 1, activeIndex + (value.translation.height > 0 ? -1 : 1)))
                            }
                        }
                    }
            )
        }
    }
}

struct ItemView: View {
    let index: Int
    let fullSize: CGSize
    let compactSize: CGSize
    let scrollOffset: CGFloat
    let activeIndex: Int
    
    var body: some View {
        GeometryReader { geometry in
            let progress = max(0, min(1, (CGFloat(activeIndex) * fullSize.height + scrollOffset) / fullSize.height))
            let currentWidth = interpolate(from: compactSize.width, to: fullSize.width, progress: progress)
            let currentHeight = interpolate(from: compactSize.height, to: fullSize.height, progress: progress)
            
            VStack(spacing: 4) {
                // Main image
                Image("\(index)")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: currentWidth, height: currentHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Subsidiary squares
                if progress < 0.5 {
                    VStack {
                        HStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { subIndex in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(ImagePaint(
                                            image: Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_\(subIndex)"),
                                            sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                                            scale: 0.1
                                        ))
                                        .frame(width: currentWidth / 4 - 3, height: currentWidth / 4 - 3)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<4, id: \.self) { subsubIndex in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(ImagePaint(
                                                    image: Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_aa24b95e-5d02-4921-8086-b5b25e13cd1a_\(subsubIndex)"),
                                                    sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                                                    scale: 0.025
                                                ))
                                                .frame(width: (currentWidth / 4 - 3) / 4 - 1.5, height: (currentWidth / 4 - 3) / 4 - 1.5)
                                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                        }
                                    }
                                }
                            }
                        }
                    }
//                    .opacity(1-(progress * 2))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .offset(y: calculateOffset(geometry: geometry, progress: progress))
        }
    }
    
    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }
    
    private func calculateOffset(geometry: GeometryProxy, progress: CGFloat) -> CGFloat {
        let fullOffset = -CGFloat(index) * fullSize.height
        let compactOffset = -CGFloat(index) * compactSize.height
        return interpolate(from: compactOffset, to: fullOffset, progress: progress)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DynamicScalingScrollView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicScalingScrollView()
    }
}

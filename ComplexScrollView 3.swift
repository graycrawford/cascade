import SwiftUI

struct ComplexScrollView3: View {
    // Horizontal paging
    @State private var horizontalOffset: CGFloat = 0
    @State private var currentPage: Int = 0
    
    // Vertical drag for scaling
    @State private var verticalDrag: CGFloat = 0
    
    // Which child (0-3) is being targeted for zoom
    @State private var targetChild: Int = 0
    
    // Gesture tracking
    @GestureState private var dragTranslation: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let parentSize = screenWidth
            let childSize = screenWidth / 4
            
            // How much drag distance corresponds to full expansion (e.g. 60% of screen height)
            let dragThreshold = screenHeight * 0.6
            
            // Total vertical offset (base + live gesture)
            let totalVerticalDrag = verticalDrag + dragTranslation.height
            
            // Progress from 0 (no drag) to 1 (fully scaled)
            let progress = min(1, max(0, -totalVerticalDrag / dragThreshold))
            
            // Child size interpolates from childSize to parentSize (1x to 4x relative to child)
            let currentChildSize = childSize + (parentSize - childSize) * progress
            
            // Visual vertical offset: Lift by one child height when fully expanded
            let liftOffset = -childSize * progress
            
            // Total horizontal offset (base + gesture)
            let totalHorizontalOffset = horizontalOffset + dragTranslation.width
            
            // Fixed Anchor Logic:
            // We want the anchor point (center of target child) to remain at its initial screen position
            // (relative to the container) as we scale up.
            //
            // Initial Anchor Position (from left edge) = childSize * (targetChild + 0.5)
            // Scaled Anchor Position (in scaled row)   = currentChildSize * (targetChild + 0.5)
            //
            // To keep the Anchor Position fixed at Initial Anchor Position:
            // Offset + Scaled Anchor Position = Initial Anchor Position
            // Offset = Initial Anchor Position - Scaled Anchor Position
            // Offset = (childSize - currentChildSize) * (targetChild + 0.5)
            let anchorFactor = CGFloat(targetChild) + 0.5
            let childRowOffset = (childSize - currentChildSize) * anchorFactor
            
            ZStack {
                Color.black.opacity(0.05).edgesIgnoringSafeArea(.all)
                
                // Content - use ZStack for proper z-ordering of pages
                ZStack {
                    ForEach(0..<4, id: \.self) { index in
                        let isCurrentPage = index == currentPage
                        
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            
                            // Parent square
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.3 + Double(index) * 0.2))
                                .frame(width: parentSize, height: parentSize)
                                .overlay(
                                    Text("\(index)")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                )
                            
                            // Child Row
                            HStack(spacing: 0) {
                                ForEach(0..<4, id: \.self) { childIndex in
                                    // Opacity and blur for unchosen children
                                    let isTarget = childIndex == targetChild
                                    let childOpacity = isTarget ? 1.0 : (1.0 - progress * 0.6)
                                    let childBlur = isTarget ? 0.0 : (progress * 6.0)
                                    
                                    RoundedRectangle(cornerRadius: 6 + 6 * progress)
                                        .fill(Color.green.opacity(0.3 + Double(childIndex) * 0.15))
                                        .frame(width: currentChildSize, height: currentChildSize)
                                        .overlay(
                                            Text("\(index).\(childIndex)")
                                                .font(progress > 0.5 ? .title : .caption)
                                                .foregroundColor(.white)
                                        )
                                        .opacity(childOpacity)
                                        .blur(radius: childBlur)
                                        .zIndex(isCurrentPage && isTarget ? 10 : 0)
                                }
                            }
                            .offset(x: childRowOffset)
                            // Use alignment leading to ensure offset starts from left edge
                            .frame(width: screenWidth, height: currentChildSize, alignment: .leading)
                        }
                        .frame(width: screenWidth, height: screenHeight)
                        .offset(x: CGFloat(index) * screenWidth + totalHorizontalOffset)
                        .zIndex(isCurrentPage ? 1 : 0)
                    }
                }
                .offset(y: liftOffset)
            }
            // Removed .clipped() to prevent cutting off the left side
            .gesture(
                DragGesture()
                    .updating($dragTranslation) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { value in
                        let isVertical = abs(value.translation.height) > abs(value.translation.width)
                        if isVertical && verticalDrag == 0 {
                            // 8-halves logic
                            let halfIndex = Int(value.startLocation.x / (screenWidth / 8))
                            targetChild = min(3, max(0, halfIndex / 2))
                        }
                    }
                    .onEnded { value in
                        let velocity = CGSize(
                            width: value.predictedEndTranslation.width - value.translation.width,
                            height: value.predictedEndTranslation.height - value.translation.height
                        )
                        
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        
                        if isHorizontal {
                            horizontalOffset += value.translation.width
                            let projectedEnd = horizontalOffset + velocity.width * 0.3
                            let projectedPage = -projectedEnd / screenWidth
                            let newPage = Int(max(0, min(3, projectedPage.rounded())))
                            
                            currentPage = newPage
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                                horizontalOffset = -CGFloat(newPage) * screenWidth
                            }
                        } else {
                            verticalDrag += value.translation.height
                            let projectedEnd = verticalDrag + velocity.height * 0.3
                            let threshold = -dragThreshold * 0.25 
                            
                            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                                if projectedEnd < threshold {
                                    verticalDrag = -dragThreshold
                                } else {
                                    verticalDrag = 0
                                }
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    ComplexScrollView3()
}

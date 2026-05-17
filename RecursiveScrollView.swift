import SwiftUI

struct BasicCarouselView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage: UUID?
    @State private var scaleFactor: CGFloat = 1.0
    @State private var verticalOffset: CGFloat = 0
    @GestureState private var dragState = DragState.inactive
    @State private var selectedSquare: Int = -1
    @State private var isExpanded: Bool = false
    @State private var expandedAnchorPoint: UnitPoint = .center
    
    enum DragState {
        case inactive
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = geometry.size.width * 0.9
            let itemHeight = itemWidth
            
            ZStack {
                // Background blur effect
                Image("background")
                    .resizable()
                    .scaleEffect(1.4)
                    .blur(radius: 80)
                    .saturation(3)
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Main carousel
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -30) {
                            ForEach(0..<4, id: \.self) { index in
                                VStack(alignment: .trailing, spacing: 8) {
                                    // Main image
                                    Image("\(index)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: itemWidth, height: itemHeight)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                    
                                    // Thumbnail row
                                    if !isExpanded || selectedSquare != index {
                                        HStack(spacing: 4) {
                                            ForEach(0..<4, id: \.self) { thumbnailIndex in
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(ImagePaint(
                                                        image: Image("\(thumbnailIndex)"),
                                                        sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                                                        scale: 0.1
                                                    ))
                                                    .frame(width: (itemWidth - 12) / 4, height: (itemWidth - 12) / 4)
                                                    .opacity(isExpanded ? 0.5 : 1.0)
                                            }
                                        }
                                    }
                                }
                                .scaleEffect(scaleFactor)
                                .offset(y: verticalOffset)
                            }
                            .frame(width: geometry.size.width)
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 0, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $currentPage)
                    
                    // Child carousel (appears when parent is expanded)
                    if isExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -30) {
                                ForEach(0..<4, id: \.self) { index in
                                    VStack(alignment: .trailing, spacing: 8) {
                                        // Child image
                                        Image("\(selectedSquare)_\(index)")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: itemWidth / 2, height: itemHeight / 2)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        
                                        // Child thumbnails
                                        HStack(spacing: 4) {
                                            ForEach(0..<4, id: \.self) { thumbnailIndex in
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(ImagePaint(
                                                        image: Image("\(selectedSquare)_\(thumbnailIndex)"),
                                                        sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                                                        scale: 0.1
                                                    ))
                                                    .frame(width: (itemWidth - 12) / 8, height: (itemWidth - 12) / 8)
                                            }
                                        }
                                    }
                                }
                                .frame(width: geometry.size.width)
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                    }
                }
                .gesture(
                    DragGesture()
                        .updating($dragState) { value, state, _ in
                            state = .dragging(translation: value.translation)
                        }
                        .onChanged { value in
                            handleDrag(value, geometry: geometry)
                        }
                        .onEnded { value in
                            handleDragEnd(value, geometry: geometry)
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            // Use the current scroll position to determine which card is centered
                            let index = min(max(Int(Double(geometry.size.width) / Double(geometry.size.width)), 0), 3)
                            selectedSquare = index
                            
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
                                scaleFactor = 4
                                verticalOffset = -geometry.size.height / 2
                                isExpanded = true
                            }
                        }
                )
            }
            
            // Bottom control bar
            .overlay(alignment: .bottom) {
                HStack {
                    ForEach(["sparkle",
                            "sparkles.square.filled.on.square",
                            "gearshape.arrow.triangle.2.circlepath",
                            "arrow.triangle.branch",
                            "bubbles.and.sparkles",
                            "lasso.badge.sparkles",
                            "arrow.up.and.down.and.sparkles"], id: \.self) { imageName in
                        Image(systemName: imageName)
                            .padding(.horizontal, 8)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    private func handleDrag(_ value: DragGesture.Value, geometry: GeometryProxy) {
        let dragAmount = value.translation.height
        let touchLocationX = value.startLocation.x
        
        // Determine which square was touched based on horizontal position
        selectedSquare = Int(touchLocationX / (geometry.size.width / 4))
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
            let dragProgress = -dragAmount / geometry.size.height
            scaleFactor = max(1, min(4, 1 + dragProgress * 3))
            verticalOffset = dragAmount
        }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value, geometry: GeometryProxy) {
        let dragAmount = value.translation.height
        let threshold = geometry.size.height / 4
        
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
            if -dragAmount > threshold {
                // Expand
                scaleFactor = 4
                verticalOffset = -threshold * 2
                isExpanded = true
            } else {
                // Reset
                scaleFactor = 1
                verticalOffset = 0
                isExpanded = false
                selectedSquare = -1
            }
        }
    }
    

}

#Preview {
    BasicCarouselView()
}

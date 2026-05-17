import SwiftUI

struct RecursiveImageGrid: View {
    @State private var currentPage: UUID?
    @State private var scaleFactor: CGFloat = 1.0
    @State private var verticalOffset: CGFloat = 0
    @GestureState private var dragState = DragState.inactive
    @State private var isExpanded: Bool = false
    @State private var activeQuarter: Int = -1
    @State private var expandedAnchorPoint: UnitPoint?
    
    let depth: Int
    let imageIndex: Int
    
    init(depth: Int = 0, imageIndex: Int = 0) {
        self.depth = depth
        self.imageIndex = imageIndex
    }
    
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
        
        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemWidth = geometry.size.width
            let itemHeight = itemWidth
            
            VStack(spacing: 8) {
                Image("\(imageIndex)")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemWidth, height: itemHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                if depth < 3 { // Limit recursion depth
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: -itemWidth * 0.1) {
                            ForEach(0..<4, id: \.self) { subIndex in
                                RecursiveImageGrid(depth: depth + 1, imageIndex: subIndex)
                                    .frame(width: itemWidth * 0.25)
                            }
                        }
                    }
                    .frame(height: itemHeight * 0.25)
                }
            }
            .scaleEffect(scaleFactor)
            .offset(y: verticalOffset)
            .gesture(
                DragGesture()
                    .updating($dragState) { value, state, _ in
                        state = .dragging(translation: value.translation)
                    }
                    .onChanged { value in
                        let dragAmount = value.translation.height
                        withAnimation(.interactiveSpring()) {
                            scaleFactor = max(1, min(4, 1 + (-dragAmount / itemHeight)))
                            verticalOffset = dragAmount
                        }
                    }
                    .onEnded { value in
                        withAnimation(.interactiveSpring()) {
                            if -value.translation.height > itemHeight / 4 {
                                scaleFactor = 4
                                verticalOffset = -itemHeight * 0.75
                                isExpanded = true
                            } else {
                                scaleFactor = 1
                                verticalOffset = 0
                                isExpanded = false
                            }
                        }
                    }
            )
        }
    }
}



#Preview {
 RecursiveImageGrid()
}


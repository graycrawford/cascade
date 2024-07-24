//import SwiftUI
//
//struct NestedSquare: Identifiable {
//    let id = UUID()
//    var children: [NestedSquare] = Array(repeating: NestedSquare(), count: 4)
//    var image: String
//    
//    init(depth: Int = 0) {
//        self.image = "image_\(depth)_\(Int.random(in: 0...9))"
//        if depth < 3 {  // Limit depth for this example, but could be infinite
//            self.children = Array(repeating: NestedSquare(depth: depth + 1), count: 4)
//        }
//    }
//}
//
//struct RecursiveComplexScrollView: View {
//    @State private var expandedPath: [Int] = []
//    @State private var activeSquare: [Int] = []
//    @State private var scaleFactor: CGFloat = 1.0
//    @State private var verticalOffset: CGFloat = 0
//    @State private var dragState: DragState = .inactive
//    @State private var isExpanded: Bool = false
//
//    let rootSquare = NestedSquare()
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Background
//                Color.black.edgesIgnoringSafeArea(.all)
//                
//                RecursiveSquareView(
//                    square: rootSquare,
//                    path: [],
//                    expandedPath: $expandedPath,
//                    activeSquare: $activeSquare,
//                    scaleFactor: $scaleFactor,
//                    verticalOffset: $verticalOffset,
//                    isExpanded: $isExpanded,
//                    dragState: $dragState,
//                    geometry: geometry
//                )
//            }
//        }
//    }
//}
//
//struct RecursiveSquareView: View {
//    let square: NestedSquare
//    let path: [Int]
//    @Binding var expandedPath: [Int]
//    @Binding var activeSquare: [Int]
//    @Binding var scaleFactor: CGFloat
//    @Binding var verticalOffset: CGFloat
//    @Binding var isExpanded: Bool
//    @Binding var dragState: DragState
//    let geometry: GeometryProxy
//    
//    @State private var currentIndex: Int? = nil
//    
//    var body: some View {
//        let itemWidth = geometry.size.width * 0.9
//        let itemHeight = itemWidth
//        
//        return VStack(spacing: 8) {
//            Image(square.image)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: itemWidth, height: itemHeight)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//            
//            if expandedPath.starts(with: path) && square.children.isEmpty == false {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 4) {
//                        ForEach(Array(square.children.enumerated()), id: \.element.id) { index, childSquare in
//                            RecursiveSquareView(
//                                square: childSquare,
//                                path: path + [index],
//                                expandedPath: $expandedPath,
//                                activeSquare: $activeSquare,
//                                scaleFactor: $scaleFactor,
//                                verticalOffset: $verticalOffset,
//                                isExpanded: $isExpanded,
//                                dragState: $dragState,
//                                geometry: geometry
//                            )
//                            .frame(width: itemWidth / 4, height: itemWidth / 4)
//                        }
//                    }
//                }
//                .frame(height: itemWidth / 4)
//                .scrollTargetLayout()
//                .scrollPosition(id: $currentIndex)
//            }
//        }
//        .scaleEffect(path == expandedPath ? scaleFactor : 1)
//        .offset(y: path == expandedPath ? verticalOffset : 0)
//        .zIndex(path == activeSquare ? 1 : 0)
//        .gesture(
//            DragGesture()
//                .onChanged { value in
//                    dragState = .dragging(translation: value.translation)
//                    handleDragChange(value: value)
//                }
//                .onEnded { value in
//                    dragState = .inactive
//                    handleDragEnd(value: value)
//                }
//        )
//    }
//    
//    private func handleDragChange(value: DragGesture.Value) {
//        let dragAmount = value.translation.height
//        let touchLocationX = value.startLocation.x
//        let itemWidth = geometry.size.width * 0.9
//        
//        if !isExpanded {
//            let quarterIndex = Int(touchLocationX / (itemWidth / 4))
//            activeSquare = path + [quarterIndex]
//            expandedPath = path
//        }
//        
//        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
//            let dragProgress = -dragAmount / itemWidth
//            scaleFactor = max(1, min(4, 1 + dragProgress * 3))
//            verticalOffset = dragAmount
//        }
//    }
//    
//    private func handleDragEnd(value: DragGesture.Value) {
//        let dragAmount = value.translation.height
//        let itemHeight = geometry.size.width * 0.9
//        
//        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
//            if isExpanded {
//                if dragAmount > itemHeight / 4 {
//                    // Contract
//                    scaleFactor = 1
//                    verticalOffset = 0
//                    isExpanded = false
//                    expandedPath = expandedPath.dropLast()
//                } else {
//                    // Stay expanded
//                    scaleFactor = 4
//                    verticalOffset = -itemHeight
//                }
//            } else {
//                if -dragAmount > itemHeight / 4 {
//                    // Expand
//                    scaleFactor = 4
//                    verticalOffset = -itemHeight
//                    isExpanded = true
//                    expandedPath = path
//                } else {
//                    // Stay contracted
//                    scaleFactor = 1
//                    verticalOffset = 0
//                }
//            }
//        }
//    }
//}
//
//enum DragState {
//    case inactive
//    case dragging(translation: CGSize)
//    
//    var translation: CGSize {
//        switch self {
//        case .inactive:
//            return .zero
//        case .dragging(let translation):
//            return translation
//        }
//    }
//    
//    var isDragging: Bool {
//        switch self {
//        case .inactive:
//            return false
//        case .dragging:
//            return true
//        }
//    }
//}
//
//#Preview {
//    RecursiveComplexScrollView()
//}

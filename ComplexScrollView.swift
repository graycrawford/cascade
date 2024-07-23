import SwiftUI

struct ComplexScrollView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var currentPage: UUID?
  @State private var scaleFactor: CGFloat = 1.0
  @State private var verticalOffset: CGFloat = 0
  @GestureState private var dragState = DragState.inactive
  @State private var startIndex: Int? = nil
  @State private var anchorPoint: UnitPoint = .leading
  @State private var isExpanded: Bool = false
  @State private var activeQuarter: Int = -1  // Initialize to -1 (no active quarter)
  @State private var isGestureEnded: Bool = false
  @State private var gestureStartScaleFactor: CGFloat = 1.0
  @State private var gestureStartOffset: CGFloat = 0
  @State private var expandedAnchorPoint: UnitPoint?
  
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
      let itemWidth = geometry.size.width * 0.9
      let itemHeight = itemWidth
      let subSquareSpacing: CGFloat = 4
      let subSquareSize = (itemWidth - (3 * subSquareSpacing)) / 4
      let subsubSquareSize = (subSquareSize - (2 * subSquareSpacing)) / 4
      let parentCornerRadius: CGFloat = 15
      
      ZStack {
        Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_1")
          .resizable()
          .scaleEffect(1.4)
          .blur(radius: 80)
          .saturation(3)
          .opacity(0.2)
          .edgesIgnoringSafeArea(.all)
        VStack (alignment: .trailing, spacing: 8) {
          
          VStack {
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: -30) {
                ForEach(0..<4, id: \.self) { index in
                  
                  VStack(alignment: .trailing, spacing: 8) {
                    
                    Image("\(index)")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: itemWidth, height: itemHeight)
                      .clipShape(RoundedRectangle(cornerRadius: parentCornerRadius))
                    
                    VStack {
                      HStack(spacing: subSquareSpacing) {
                        ForEach(0..<4, id: \.self) { subIndex in
                          VStack(spacing: subSquareSpacing) {
                            RoundedRectangle(cornerRadius: 5)
                              .fill(ImagePaint(
                                image: Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_\(subIndex)"),
                                sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1), scale: 0.1))
                              .frame(width: subSquareSize, height: subSquareSize)
                              .clipShape(
                                .rect(
                                  topLeadingRadius: subIndex == 0 ? parentCornerRadius : 5,
                                  bottomLeadingRadius: subIndex == 0 ? parentCornerRadius : 14,
                                  bottomTrailingRadius: subIndex == 3 ? parentCornerRadius : 14,
                                  topTrailingRadius: subIndex == 3 ? parentCornerRadius : 5
                                )
                              )
                            HStack(spacing: subSquareSpacing / 2) {
                              ForEach(0..<4, id: \.self) { index2 in
                                RoundedRectangle(cornerRadius: 2)
                                  .fill(ImagePaint(
                                    image: Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_aa24b95e-5d02-4921-8086-b5b25e13cd1a_\(index2)"),
                                    sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1), scale: 0.025))
                                  .frame(width: subsubSquareSize, height: subsubSquareSize)
                                  .clipShape(
                                    .rect(
                                      topLeadingRadius: index2 == 0 ? parentCornerRadius / 2 : 0.02,
                                      bottomLeadingRadius: index2 == 0 ? parentCornerRadius / 2 : 0.02,
                                      bottomTrailingRadius: index2 == 3 ? parentCornerRadius / 2 : 0.02,
                                      topTrailingRadius: index2 == 3 ? parentCornerRadius / 2 : 0.02
                                    ))
                              }
                            }
                          }
                          .opacity(opacityForSubSquare(subIndex))
                          .blur(radius: blurForSubSquare(subIndex))
                        }
                      }
                      .scrollTransition { content, phase in
                        content
                      }
                    }
                    .scaleEffect(scaleFactor, anchor: anchorPoint)
                  }
                  .offset(y: verticalOffset)
                  
                }
                .frame(width: geometry.size.width)
                .scrollTransition { content, phase in
                  let phaseValuePow = (abs(phase.value))
                  return content
                    .blur(radius: phaseValuePow * 6)
                    .opacity(1 - (phaseValuePow * 0.5))
                }
              }
              .scrollTargetLayout()
            }
            .frame(height: itemHeight + (subSquareSize + 40) * scaleFactor)
            .gesture(
              DragGesture()
                .updating($dragState) { value, state, _ in
                  state = .dragging(translation: value.translation)
                }
                .onChanged { value in
                  let dragAmount = value.translation.height
                  let touchLocationX = value.startLocation.x
                  let screenWidth = geometry.size.width
                  
                  isGestureEnded = false
                  
                  if !isExpanded {
                    // Determine the active quarter based on touch location only when not expanded
                    activeQuarter = Int(touchLocationX / (screenWidth / 4))
                    
                    // Determine the anchor point based on touch location
                    if touchLocationX < screenWidth * 0.25 {
                      anchorPoint = UnitPoint(x: 0, y: 0)
                    } else if touchLocationX < screenWidth * 0.5 {
                      anchorPoint = UnitPoint(x: 0.325, y: 0)
                    } else if touchLocationX < screenWidth * 0.75 {
                      anchorPoint = UnitPoint(x: 0.675, y: 0)
                    } else {
                      anchorPoint = UnitPoint(x: 1, y: 0)
                    }
                    expandedAnchorPoint = anchorPoint
                  } else {
                    // Use the expanded anchor point when already expanded
                    anchorPoint = expandedAnchorPoint ?? .center
                  }
                  
                  withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
                    let dragProgress = -dragAmount / itemHeight
                    scaleFactor = max(1, min(4, gestureStartScaleFactor + dragProgress * 3))
                    verticalOffset = gestureStartOffset + dragAmount
                  }
                }
                .onEnded { value in
                  let dragAmount = value.translation.height
                  withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
                    if isExpanded {
                      if dragAmount > itemHeight / 4 {
                        // Contract
                        scaleFactor = 1
                        verticalOffset = 0
                        isExpanded = false
                        expandedAnchorPoint = nil
                      } else {
                        // Stay expanded
                        scaleFactor = 4
                        verticalOffset = -itemHeight
                      }
                    } else {
                      if -dragAmount > itemHeight / 4 {
                        // Expand
                        scaleFactor = 4
                        verticalOffset = -itemHeight
                        isExpanded = true
                      } else {
                        // Stay contracted
                        scaleFactor = 1
                        verticalOffset = 0
                      }
                    }
                  }
                  // Set gesture ended flag
                  isGestureEnded = true
                  gestureStartScaleFactor = scaleFactor
                  gestureStartOffset = verticalOffset
                }
            )
            
            // icons
            HStack {
              HStack {
                
              }
              .blendMode(colorScheme == .light ? .plusDarker : .plusLighter)
              .padding([.leading, .trailing], 24)
              .padding(.top, 28)
              .padding(.bottom, 8)
            }
            
          }
          
          .contentMargins(.horizontal, 0, for: .scrollContent)
          .scrollTargetBehavior(.viewAligned)
          .scrollPosition(id: $currentPage)
          .scrollClipDisabled()
        }
      }
    }
    .overlay(alignment: .top) {
      GeometryReader { geom in
        VariableBlurView(maxBlurRadius: 10)
          .frame(height: geom.safeAreaInsets.top)
          .ignoresSafeArea()
      }
    }
    .overlay(alignment: .bottom) {
      GeometryReader { geom in
        VStack {
          Spacer()
          VariableBlurView(maxBlurRadius: 10, direction: .blurredBottomClearTop)
            .frame(height: geom.safeAreaInsets.bottom * 2)
        }
        .ignoresSafeArea()
      }
    }
    .overlay(alignment: .bottom) {
      HStack {
        HStack {
          Image(systemName: "sparkle")
          Spacer()
          Image(systemName: "sparkles.square.filled.on.square")
          Spacer()
          Image(systemName: "gearshape.arrow.triangle.2.circlepath")
            .blur(radius: 2)
            .opacity(0.5)
          
          Spacer()
          Image(systemName: "arrow.triangle.branch")
          Spacer()
          Spacer()
          Spacer()
          Image(systemName: "bubbles.and.sparkles")
            .blur(radius: 2)
            .opacity(0.5)
          
          Spacer()
          Image(systemName: "lasso.badge.sparkles")
          Spacer()
          Image(systemName: "arrow.up.and.down.and.sparkles")
        }
        .blendMode(colorScheme == .light ? .plusDarker : .plusLighter)
        .padding([.leading, .trailing], 24)
        .padding(.top, 0)
        .padding(.bottom, 0)
      }
    }
  }
  
  // Helper function to calculate opacity for each subsquare
  private func opacityForSubSquare(_ subIndex: Int) -> Double {
    if subIndex == activeQuarter {
      return 1.0
    } else {
      let progress = (scaleFactor - 1) / 3 // 0 when not scaled, 1 when fully scaled
      if isExpanded {
        return 0.5 // Match offscreen primary squares when view is expanded
      } else {
        return 1.0 - (progress * 0.8) // Gradually fade to 20% opacity during gesture
      }
    }
  }
  
  // Helper function to calculate blur for each subsquare
  private func blurForSubSquare(_ subIndex: Int) -> CGFloat {
    if subIndex == activeQuarter {
      return 0 // Active quarter always remains clear
    } else {
      let progress = (scaleFactor - 1) / 3 // 0 when not scaled, 1 when fully scaled
      let maxBlur: CGFloat = 6
      if isExpanded {
        return maxBlur // Fully blur inactive quarters when expanded
      } else {
        // Smoothly transition blur based on scale factor
        return progress * maxBlur
      }
    }
  }
}

#Preview {
  ComplexScrollView()
}

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
 @State private var activeQuarter: Int = -1
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
 
 enum Corner {
  case topLeading, topTrailing, bottomLeading, bottomTrailing
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
                 topLeadingRadius: interpolatedCornerRadius(for: subIndex, corner: .topLeading),
                 bottomLeadingRadius: interpolatedCornerRadius(for: subIndex, corner: .bottomLeading),
                 bottomTrailingRadius: interpolatedCornerRadius(for: subIndex, corner: .bottomTrailing),
                 topTrailingRadius: interpolatedCornerRadius(for: subIndex, corner: .topTrailing)
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
                   topLeadingRadius: interpolatedSubSubCornerRadius(for: index2, corner: .topLeading),
                   bottomLeadingRadius: interpolatedSubSubCornerRadius(for: index2, corner: .bottomLeading),
                   bottomTrailingRadius: interpolatedSubSubCornerRadius(for: index2, corner: .bottomTrailing),
                   topTrailingRadius: interpolatedSubSubCornerRadius(for: index2, corner: .topTrailing)
                  )
                 )
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
          activeQuarter = Int(touchLocationX / (screenWidth / 4))
          
          if touchLocationX < screenWidth * 0.25 {
           anchorPoint = UnitPoint(x: 0, y: 0)
          } else if touchLocationX < screenWidth * 0.5 {
           anchorPoint = UnitPoint(x: 1/3, y: 0)
          } else if touchLocationX < screenWidth * 0.75 {
           anchorPoint = UnitPoint(x: 2/3, y: 0)
          } else {
           anchorPoint = UnitPoint(x: 1, y: 0)
          }
          expandedAnchorPoint = anchorPoint
         } else {
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
            scaleFactor = 1
            verticalOffset = 0
            isExpanded = false
            expandedAnchorPoint = nil
           } else {
            scaleFactor = 4
            verticalOffset = -itemHeight
           }
          } else {
           if -dragAmount > itemHeight / 4 {
            scaleFactor = 4
            verticalOffset = -itemHeight
            isExpanded = true
           } else {
            scaleFactor = 1
            verticalOffset = 0
           }
          }
         }
         isGestureEnded = true
         gestureStartScaleFactor = scaleFactor
         gestureStartOffset = verticalOffset
        }
      )
      
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
      .frame(height: geom.safeAreaInsets.bottom * 2.4)
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
 
 private func opacityForSubSquare(_ subIndex: Int) -> Double {
  if subIndex == activeQuarter {
   return 1.0
  } else {
   let progress = (scaleFactor - 1) / 3
   if isExpanded {
    return 0.5
   } else {
    return 1.0 - (progress * 0.8)
   }
  }
 }
 
 private func blurForSubSquare(_ subIndex: Int) -> CGFloat {
  if subIndex == activeQuarter {
   return 0
  } else {
   let progress = (scaleFactor - 1) / 3
   let maxBlur: CGFloat = 6
   if isExpanded {
    return maxBlur
   } else {
    return progress * maxBlur
   }
  }
 }
 
 private func interpolatedCornerRadius(for subIndex: Int, corner: Corner) -> CGFloat {
    let progress = (scaleFactor - 1) / 3
    let parentCornerRadius: CGFloat = 14

    let startRadius: CGFloat
    let endRadius: CGFloat = 5 // All corners converge to 5 when fully scaled

    switch (subIndex, corner) {
    case (0, .topLeading), (0, .bottomLeading), (3, .topTrailing), (3, .bottomTrailing):
        startRadius = parentCornerRadius
    case (_, .bottomLeading), (_, .bottomTrailing):
        startRadius = parentCornerRadius // All bottom corners start large
    case (0, .topTrailing), (1, .topLeading), (1, .topTrailing), (2, .topLeading), (2, .topTrailing), (3, .topLeading):
        startRadius = 5 // Top corners (except outer corners of 0 and 3) start small
    default:
        startRadius = 5
    }

    return startRadius + (endRadius - startRadius) * progress
}

 private func interpolatedSubSubCornerRadius(for index2: Int, corner: Corner) -> CGFloat {
  let progress = (scaleFactor - 1) / 3
  let parentCornerRadius: CGFloat = 14

  let startRadius: CGFloat
  let endRadius: CGFloat

  // Function to adjust end radius based on scaling
  func adjustedEndRadius(_ radius: CGFloat) -> CGFloat {
   return radius / scaleFactor
  }

  switch (index2, corner) {
  case (0, .topLeading):
   startRadius = parentCornerRadius / 2
   endRadius = adjustedEndRadius(parentCornerRadius)
  case (0, .bottomLeading):
   startRadius = parentCornerRadius / 2
   endRadius = adjustedEndRadius(parentCornerRadius)
  case (3, .topTrailing):
   startRadius = parentCornerRadius / 2
   endRadius = adjustedEndRadius(parentCornerRadius)
  case (3, .bottomTrailing):
   startRadius = parentCornerRadius / 2
   endRadius = adjustedEndRadius(parentCornerRadius)
  case (_, .bottomLeading), (_, .bottomTrailing):
   startRadius = parentCornerRadius / 4
   endRadius = adjustedEndRadius(14) // Bottom corners of sub-squares start at 14
  case (0, .topTrailing), (3, .topLeading):
   startRadius = parentCornerRadius / 4
   endRadius = adjustedEndRadius(5) // Top inner corners of sub-squares start at 5
  default:
   startRadius = 0.02
   endRadius = adjustedEndRadius(5) // Other corners of sub-squares start at 5
  }


   return startRadius + (endRadius - startRadius) * progress
  }

}

#Preview {
 ComplexScrollView()
}

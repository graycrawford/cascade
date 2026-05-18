import SwiftUI

struct cascade1: View {
 @Environment(\.colorScheme) var colorScheme
 @State private var activePath: [Int] = [0]
 @State private var scrollY: CGFloat = 0
 @State private var liveVerticalDrag: CGFloat = 0
 @State private var liveHorizontalDrag: CGFloat = 0
 @State private var targetChild: Int = 0
 @State private var gestureMode: GestureMode? = nil
 @State private var gestureLevel: Int = 0
 @State private var pendingPromotionChild: Int?
 
 enum GestureMode { case vertical, horizontal }
 
 var body: some View {
  GeometryReader { geometry in
   let screenWidth = geometry.size.width
   let screenHeight = geometry.size.height
   let itemWidth = screenWidth * 0.9
   let itemHeight = itemWidth
   let gap: CGFloat = 8
   let spacing: CGFloat = 4
   let subSquareSize = (itemWidth - 3 * spacing) / 4
   let subsubSquareSize = (subSquareSize - 2 * spacing) / 4
   let levelHeight = itemHeight + gap
   let parentCornerRadius: CGFloat = 15
   let primeLeftX = (screenWidth - itemWidth) / 2
   let carouselStride = screenWidth
   let activeLayoutHeight = itemHeight + 2 * gap + subSquareSize + subsubSquareSize
   let bottomMargin = geometry.safeAreaInsets.bottom + 16
   let availableTop = geometry.safeAreaInsets.top + 8
   let computedTopInset = screenHeight - bottomMargin - activeLayoutHeight
   let topInset = max(availableTop, computedTopInset)
   
   let liveScroll = scrollY + liveVerticalDrag
   let baseScroll = CGFloat(activePath.count - 1) * levelHeight
   let promotionProgress = max(CGFloat(0), min(CGFloat(1), (liveScroll - baseScroll) / levelHeight))
   ZStack {
    (colorScheme == .light ? Color.white : Color.black)
     .edgesIgnoringSafeArea(.all)
    
    ZStack(alignment: .topLeading) {
     ForEach(activePath.indices, id: \.self) { levelIdx in
      let parentLevelPath = Array(activePath.prefix(levelIdx))
      let yPos = CGFloat(levelIdx) * levelHeight
      let isActive = levelIdx == activePath.count - 1
      let isHTarget = (gestureMode == .horizontal && gestureLevel == levelIdx)
      let hDragOffset = isHTarget ? liveHorizontalDrag : 0
      let currentSibling = activePath[levelIdx]
      
      ForEach(visibleSiblingRange(around: currentSibling), id: \.self) { siblingIdx in
       let siblingDelta = siblingIdx - currentSibling
       let siblingPath = parentLevelPath + [siblingIdx]
       let xOffset = CGFloat(siblingDelta) * carouselStride + hDragOffset
       
       CascadeTile(
        path: siblingPath,
        cornerRadius: parentCornerRadius,
        showsLabel: false
       )
       .frame(width: itemWidth, height: itemHeight)
       .position(x: screenWidth / 2 + xOffset, y: yPos + itemHeight / 2)
      }
      
      if isActive {
       ForEach(visibleSiblingRange(around: currentSibling), id: \.self) { activeSiblingIdx in
        let siblingDelta = activeSiblingIdx - currentSibling
        let siblingPath = parentLevelPath + [activeSiblingIdx]
        let siblingXOffset = CGFloat(siblingDelta) * carouselStride + hDragOffset
       let siblingProgress = activeSiblingIdx == currentSibling ? promotionProgress : 0
       let currentChildSize = subSquareSize + (itemWidth - subSquareSize) * siblingProgress
       let currentGrandchildSize = subsubSquareSize + (subSquareSize - subsubSquareSize) * siblingProgress
       let currentGrandchildSpacing = (spacing / 2) + ((spacing / 2) * siblingProgress)
       let childToGrandchildGap = spacing + ((gap - spacing) * siblingProgress)
       let greatGrandchildSpacing = spacing / 2
       let greatGrandchildGap = spacing * siblingProgress
       let chosenIdx = CGFloat(targetChild)
       let chosenChildLevelX = chosenIdx * (subSquareSize + spacing) * (1 - siblingProgress)
       let rowOffsetX = chosenChildLevelX - chosenIdx * (currentChildSize + spacing)
        
       ForEach(0..<4, id: \.self) { childIdx in
         let isTarget = childIdx == targetChild && activeSiblingIdx == currentSibling
         let childPath = siblingPath + [childIdx]
         let childPosInRow = CGFloat(childIdx) * (currentChildSize + spacing)
         let childLevelX = childPosInRow + rowOffsetX
         let childScreenX = primeLeftX + siblingXOffset + childLevelX
         let childScreenY = yPos + itemHeight + gap
        let branchOpacity = activeSiblingIdx == currentSibling && !isTarget ? Double(max(0, 1 - 0.85 * promotionProgress)) : Double(1)
        let branchBlur = activeSiblingIdx == currentSibling && !isTarget ? promotionProgress * 6 : 0
        let branchHeight = currentChildSize + childToGrandchildGap + currentGrandchildSize + greatGrandchildGap + max(0, ((currentGrandchildSize - (2 * spacing)) / 4) * siblingProgress)
         
        ZStack(alignment: .topLeading) {
          CascadeTile(
          path: childPath,
          radii: childRadii(for: childIdx, progress: siblingProgress, parentCornerRadius: parentCornerRadius),
           showsLabel: false
          )
         .frame(width: currentChildSize, height: currentChildSize)
          
         ForEach(0..<4, id: \.self) { gcIdx in
          let gcPath = childPath + [gcIdx]
          let gcXInChild = CGFloat(gcIdx) * (currentGrandchildSize + currentGrandchildSpacing)
          let gcScreenY = currentChildSize + childToGrandchildGap
          
          CascadeTile(
           path: gcPath,
           radii: grandchildRadii(for: gcIdx, progress: siblingProgress),
           showsLabel: false
          )
          .frame(width: currentGrandchildSize, height: currentGrandchildSize)
          .position(x: gcXInChild + currentGrandchildSize / 2, y: gcScreenY + currentGrandchildSize / 2)
          
          if isTarget {
           let greatGrandchildWidth = max(0, (currentGrandchildSize - (2 * spacing)) / 4)
           let greatGrandchildHeight = greatGrandchildWidth * siblingProgress
           let ggcScreenY = gcScreenY + currentGrandchildSize + greatGrandchildGap
           
           HStack(spacing: greatGrandchildSpacing) {
            ForEach(0..<4, id: \.self) { ggcIdx in
             let ggcPath = gcPath + [ggcIdx]
             
             CascadeTile(
              path: ggcPath,
              radii: greatGrandchildRadii(for: ggcIdx),
              showsLabel: false
             )
             .frame(width: greatGrandchildWidth, height: greatGrandchildHeight)
            }
            }
           .frame(width: currentGrandchildSize, height: greatGrandchildHeight, alignment: .topLeading)
           .blur(radius: (1 - siblingProgress) * 4)
           .opacity(Double(siblingProgress))
           .position(x: gcXInChild + currentGrandchildSize / 2, y: ggcScreenY + greatGrandchildHeight / 2)
          }
         }
        }
        .frame(
         width: currentChildSize,
         height: branchHeight,
         alignment: .topLeading
        )
        .opacity(branchOpacity)
        .blur(radius: branchBlur)
        .position(x: childScreenX + currentChildSize / 2, y: childScreenY + branchHeight / 2)
        .zIndex(isTarget ? 10 : 1)
       }
      }
     }
    }
    .frame(maxWidth: .infinity, alignment: .topLeading)
    .offset(y: topInset - liveScroll)
   }
   .contentShape(Rectangle())
   .gesture(
    DragGesture(minimumDistance: 4)
     .onChanged { value in
      let dx = value.translation.width
      let dy = value.translation.height
      
      let mode: GestureMode
      if gestureMode == nil {
       if abs(dy) >= abs(dx) {
        mode = .vertical
        let xWithinPrime = value.startLocation.x - primeLeftX
        let idx = Int(xWithinPrime / (subSquareSize + spacing))
        targetChild = max(0, min(3, idx))
       } else {
        mode = .horizontal
        let touchY = value.startLocation.y - topInset + scrollY
        let lvl = Int(touchY / levelHeight)
        gestureLevel = max(0, min(activePath.count - 1, lvl))
       }
       gestureMode = mode
      } else {
       mode = gestureMode!
      }
      
      switch mode {
      case .vertical:
       liveVerticalDrag = -dy
      case .horizontal:
       liveHorizontalDrag = dx
      }
     }
     .onEnded { value in
      let dx = value.translation.width
      let dy = value.translation.height
      let predictedDx = value.predictedEndTranslation.width
      let predictedDy = value.predictedEndTranslation.height
      
      switch gestureMode {
      case .vertical:
       scrollY = scrollY + (-dy)
       liveVerticalDrag = 0
       
       let base = CGFloat(activePath.count - 1) * levelHeight
       let momentum = -(predictedDy - dy)
       let predictedTotalScroll = scrollY + momentum
       let predictedPromotion = predictedTotalScroll - base
       
       if predictedPromotion >= levelHeight * 0.4 {
        let newBase = base + levelHeight
        let chosenChildIdx = targetChild
        
       pendingPromotionChild = chosenChildIdx
       
        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.85, blendDuration: 1.0)) {
         scrollY = newBase
        } completion: {
        if pendingPromotionChild == chosenChildIdx {
         activePath.append(chosenChildIdx)
         pendingPromotionChild = nil
        }
        }
       } else {
        let snappedLevel = (predictedTotalScroll / levelHeight).rounded()
        let clamped = max(CGFloat(0), min(CGFloat(activePath.count - 1), snappedLevel))
        
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.88, blendDuration: 1.0)) {
         scrollY = clamped * levelHeight
        }
       }
       
      case .horizontal:
       let currentSibling = activePath[gestureLevel]
       let momentum = predictedDx - dx
       let totalDelta = dx + momentum
       let projectedDelta = -(totalDelta / carouselStride).rounded()
       let intDelta = Int(projectedDelta)
       let newSibling = max(0, min(3, currentSibling + intDelta))
       let actualDelta = newSibling - currentSibling
       
       if actualDelta == 0 {
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.88, blendDuration: 1.0)) {
         liveHorizontalDrag = 0
        }
       } else {
        let adjustedDrag = liveHorizontalDrag + CGFloat(actualDelta) * carouselStride
        
        var newPath = Array(activePath.prefix(gestureLevel))
        newPath.append(newSibling)
        
        activePath = newPath
        liveHorizontalDrag = adjustedDrag
        
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.88, blendDuration: 1.0)) {
         liveHorizontalDrag = 0
        }
       }
       
      case .none:
       break
      }
      
      gestureMode = nil
     }
   )
   .simultaneousGesture(
    SpatialTapGesture()
     .onEnded { value in
      handleTap(
       at: value.location,
       topInset: topInset,
       itemHeight: itemHeight,
       gap: gap,
       subSquareSize: subSquareSize,
       spacing: spacing,
       primeLeftX: primeLeftX,
       levelHeight: levelHeight
      )
     }
   )
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
 }
 
 private func handleTap(
  at location: CGPoint,
  topInset: CGFloat,
  itemHeight: CGFloat,
  gap: CGFloat,
  subSquareSize: CGFloat,
  spacing: CGFloat,
  primeLeftX: CGFloat,
  levelHeight: CGFloat
 ) {
  let xWithinPrime = location.x - primeLeftX
  let idx = Int(xWithinPrime / (subSquareSize + spacing))
  
  guard idx >= 0 && idx < 4 else { return }
  
  let incomingChildRowTop = topInset + itemHeight + gap
  if let pending = pendingPromotionChild,
     location.y >= incomingChildRowTop,
     location.y <= incomingChildRowTop + subSquareSize {
   activePath.append(pending)
   pendingPromotionChild = nil
   startPromotion(child: idx, levelHeight: levelHeight)
   return
  }
  
  let activeY = CGFloat(activePath.count - 1) * levelHeight
  let childRowTop = topInset - scrollY + activeY + itemHeight + gap
  
  guard location.y >= childRowTop else { return }
  guard location.y <= childRowTop + subSquareSize else { return }
  
  startPromotion(child: idx, levelHeight: levelHeight)
 }
 
 private func startPromotion(child: Int, levelHeight: CGFloat) {
  let base = CGFloat(activePath.count - 1) * levelHeight
  let newBase = base + levelHeight
  
  withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.85, blendDuration: 1.0)) {
   targetChild = child
   pendingPromotionChild = child
   scrollY = newBase
  } completion: {
   if pendingPromotionChild == child {
    activePath.append(child)
    pendingPromotionChild = nil
   }
  }
 }
}

private struct CascadeTile: View {
 let path: [Int]
 let radii: CascadeCornerRadii
 let showsLabel: Bool
 
 init(path: [Int], cornerRadius: CGFloat, showsLabel: Bool) {
  self.path = path
  self.radii = CascadeCornerRadii(cornerRadius)
  self.showsLabel = showsLabel
 }
 
 init(path: [Int], radii: CascadeCornerRadii, showsLabel: Bool) {
  self.path = path
  self.radii = radii
  self.showsLabel = showsLabel
 }
 
 var body: some View {
  ZStack(alignment: .topLeading) {
   UnevenRoundedRectangle(
    topLeadingRadius: radii.topLeading,
    bottomLeadingRadius: radii.bottomLeading,
    bottomTrailingRadius: radii.bottomTrailing,
    topTrailingRadius: radii.topTrailing
   )
    .fill(cascadeColor(for: path))
    .overlay {
     Image(cascadeImageName(for: path))
      .resizable()
      .aspectRatio(contentMode: .fill)
    }
    .clipShape(
     UnevenRoundedRectangle(
      topLeadingRadius: radii.topLeading,
      bottomLeadingRadius: radii.bottomLeading,
      bottomTrailingRadius: radii.bottomTrailing,
      topTrailingRadius: radii.topTrailing
     )
    )
   
   if showsLabel {
    Text(cascadeLabel(for: path))
     .font(.caption2)
     .fontWeight(.medium)
     .foregroundColor(.white)
     .shadow(radius: 4)
     .padding(6)
   }
  }
 }
}

private struct CascadeCornerRadii {
 let topLeading: CGFloat
 let bottomLeading: CGFloat
 let bottomTrailing: CGFloat
 let topTrailing: CGFloat
 
 init(_ radius: CGFloat) {
  self.topLeading = radius
  self.bottomLeading = radius
  self.bottomTrailing = radius
  self.topTrailing = radius
 }
 
 init(topLeading: CGFloat, bottomLeading: CGFloat, bottomTrailing: CGFloat, topTrailing: CGFloat) {
  self.topLeading = topLeading
  self.bottomLeading = bottomLeading
  self.bottomTrailing = bottomTrailing
  self.topTrailing = topTrailing
 }
}

private func childRadii(for index: Int, progress: CGFloat, parentCornerRadius: CGFloat) -> CascadeCornerRadii {
 lerpRadii(from: restingChildRadii(for: index), to: CascadeCornerRadii(parentCornerRadius), progress: progress)
}

private func grandchildRadii(for index: Int, progress: CGFloat) -> CascadeCornerRadii {
 lerpRadii(from: restingGrandchildRadii(for: index), to: restingChildRadii(for: index), progress: progress)
}

private func greatGrandchildRadii(for index: Int) -> CascadeCornerRadii {
 restingGrandchildRadii(for: index)
}

private func restingChildRadii(for index: Int) -> CascadeCornerRadii {
 let parentCornerRadius: CGFloat = 14
 let smallRadius: CGFloat = 5
 
 return CascadeCornerRadii(
  topLeading: index == 0 ? parentCornerRadius : smallRadius,
  bottomLeading: parentCornerRadius,
  bottomTrailing: parentCornerRadius,
  topTrailing: index == 3 ? parentCornerRadius : smallRadius
 )
}

private func restingGrandchildRadii(for index: Int) -> CascadeCornerRadii {
 let parentCornerRadius: CGFloat = 14
 let outerRadius = parentCornerRadius / 2
 let innerRadius = parentCornerRadius / 4
 
 return CascadeCornerRadii(
  topLeading: index == 0 ? outerRadius : innerRadius,
  bottomLeading: index == 0 ? outerRadius : innerRadius,
  bottomTrailing: index == 3 ? outerRadius : innerRadius,
  topTrailing: index == 3 ? outerRadius : innerRadius
 )
}

private func lerpRadii(from start: CascadeCornerRadii, to end: CascadeCornerRadii, progress: CGFloat) -> CascadeCornerRadii {
 CascadeCornerRadii(
  topLeading: lerp(start.topLeading, end.topLeading, progress),
  bottomLeading: lerp(start.bottomLeading, end.bottomLeading, progress),
  bottomTrailing: lerp(start.bottomTrailing, end.bottomTrailing, progress),
  topTrailing: lerp(start.topTrailing, end.topTrailing, progress)
 )
}

private func lerp(_ start: CGFloat, _ end: CGFloat, _ progress: CGFloat) -> CGFloat {
 start + (end - start) * progress
}

private func visibleSiblingRange(around currentSibling: Int) -> [Int] {
 Array(max(0, currentSibling - 1)...min(3, currentSibling + 1))
}

private func cascadeImageName(for path: [Int]) -> String {
 let seed = path.enumerated().reduce(0) { partialResult, element in
  partialResult + ((element.offset + 1) * (element.element + 1) * 7)
 }
 return "rose/\((seed % 10) + 1)"
}

private func cascadeLabel(for path: [Int]) -> String {
 path.map { String($0 + 1) }.joined(separator: ".")
}

private func cascadeColor(for path: [Int]) -> Color {
 let seed = path.enumerated().reduce(0) { partialResult, element in
  partialResult + ((element.offset + 2) * (element.element + 1) * 13)
 }
 return Color(
  hue: Double(seed % 100) / 100,
  saturation: 0.2,
  brightness: 0.88
 )
}

#Preview {
 cascade1()
}

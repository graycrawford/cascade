  //import SwiftUI
  //
  //struct PromptAssembly: View {
  //  @Environment(\.colorScheme) var colorScheme
  //  @State private var scrollOffset: CGFloat = 0
  //
  //  let rowCount = 20
  //  let columnCount = 4
  //
  //  var body: some View {
  //    GeometryReader { geometry in
  //      let fullWidth = geometry.size.width * 0.9
  //      let itemSpacing: CGFloat = 8
  //
  //      ZStack {
  //
  //      }
  //      // rectangle with round corners, soft drop shaodw:
  //      Text("hello")
  //        .padding(10)
  //        .background(Color.white)
  //        .cornerRadius(18)
  //
  //        // shadow with alpha
  //        .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: 10, x: 0, y: 10)
  //        .offset(x: 10, y: 10)
  //
  //      Text("twicelet")
  //        .padding(10)
  //        .background(Color.white)
  //        .cornerRadius(18)
  //
  //        // shadow with alpha
  //        .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.1), radius: 10, x: 0, y: 10)
  //        .offset(x: 100, y: 10)
  //
  //
  //    }
  //
  //    .overlay(alignment: .top) {
  //      GeometryReader { geom in
  //        VariableBlurView(maxBlurRadius: 10)
  //          .frame(height: geom.safeAreaInsets.top)
  //          .ignoresSafeArea()
  //      }
  //    }
  //    .overlay(alignment: .bottom) {
  //      GeometryReader { geom in
  //        VStack {
  //          Spacer()
  //          VariableBlurView(maxBlurRadius: 10, direction: .blurredBottomClearTop)
  //            .frame(height: geom.safeAreaInsets.bottom * 2)
  //        }
  //        .ignoresSafeArea()
  //      }
  //    }
  ////    .overlay(alignment: .bottom) {
  ////      HStack {
  ////        HStack {
  ////          Image(systemName: "sparkle")
  ////          Spacer()
  ////          Image(systemName: "sparkles.square.filled.on.square")
  ////          Spacer()
  ////          Image(systemName: "gearshape.arrow.triangle.2.circlepath")
  ////            .blur(radius: 2)
  ////            .opacity(0.5)
  ////
  ////          Spacer()
  ////          Image(systemName: "arrow.triangle.branch")
  ////            //                  .blur(radius: 4)
  ////          Spacer()
  ////          Spacer()
  ////          Spacer()
  ////          Spacer()
  ////          Image(systemName: "bubbles.and.sparkles")
  ////            .blur(radius: 2)
  ////            .opacity(0.5)
  ////
  ////          Spacer()
  ////          Image(systemName: "lasso.badge.sparkles")
  //////            .blur(radius: 2)
  //////            .opacity(0.5)
  ////          Spacer()
  ////          Image(systemName: "arrow.up.and.down.and.sparkles")
  ////            //                  .blur(radius: 4)
  ////
  ////        }
  ////        .blendMode(colorScheme == .light ? .plusDarker : .plusLighter)
  ////        .padding([.leading, .trailing], 24)
  ////        .padding(.top, 0)
  ////        .padding(.bottom, 0)
  ////      }
  ////    }
  //  }
  //}
  //
  //#Preview {
  //  PromptAssembly()
  //}
  //
  //
  //
  //
  //





import SwiftUI

struct DraggableText: Identifiable, Equatable {
  let id = UUID()
  var text: String
  var position: CGPoint
  var size: CGSize = .zero
  let padding: CGFloat = 10 // Matching the padding in TextElement
  
  var leftEdge: CGFloat {
    position.x - size.width / 2 + padding
  }
  
  var rightEdge: CGFloat {
    position.x + size.width / 2 - padding
  }
  
  static func == (lhs: DraggableText, rhs: DraggableText) -> Bool {
    lhs.id == rhs.id && lhs.text == rhs.text && lhs.position == rhs.position && lhs.size == rhs.size
  }
}

struct PromptAssembly: View {
  @State private var draggableTexts: [DraggableText] = [
    DraggableText(text: "hello", position: CGPoint(x: 50, y: 50)),
    DraggableText(text: "worldliness", position: CGPoint(x: 150, y: 50)),
    DraggableText(text: "promptism", position: CGPoint(x: 150, y: 100))

  ]
  @State private var editingText: UUID?
  
  let snapDistance: CGFloat = 20
  let itemSpacing: CGFloat = 40
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_1")
          .resizable()
          .scaleEffect(1.4)
          .blur(radius: 80)
          .saturation(3)
          .opacity(0.2)
          .edgesIgnoringSafeArea(.all)
        
        ForEach($draggableTexts) { $text in
          TextElement(text: $text.text, isEditing: editingText == text.id, size: $text.size)
            .position(text.position)
            .gesture(
              DragGesture()
                .onChanged { value in
                  withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 1.0)) {
                    text.position = value.location
                  }
                }
                .onEnded { _ in
                  withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 1.0)) {
                    snapToNearestElement(for: &text)
                  }
                }
            )
            .onTapGesture {
              editingText = text.id
            }
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
  }
  
  private func snapToNearestElement(for text: inout DraggableText) {
    var closestDistance = CGFloat.greatestFiniteMagnitude
    var snapPosition: CGPoint?
    
    for otherText in draggableTexts where otherText.id != text.id {
        // Check right edge of current to left edge of other
      let rightToLeftDistance = abs(text.rightEdge - otherText.leftEdge)
      if rightToLeftDistance < snapDistance && rightToLeftDistance < closestDistance {
        closestDistance = rightToLeftDistance
        let newX = otherText.leftEdge - itemSpacing - (text.size.width / 2 - text.padding)
        snapPosition = CGPoint(x: newX, y: text.position.y)
        
          // Snap to the same vertical line
        if abs(text.position.y - otherText.position.y) < snapDistance {
          snapPosition!.y = otherText.position.y
        }
      }
      
        // Check left edge of current to right edge of other
      let leftToRightDistance = abs(text.leftEdge - otherText.rightEdge)
      if leftToRightDistance < snapDistance && leftToRightDistance < closestDistance {
        closestDistance = leftToRightDistance
        let newX = otherText.rightEdge + itemSpacing + (text.size.width / 2 - text.padding)
        snapPosition = CGPoint(x: newX, y: text.position.y)
        
          // Snap to the same vertical line
        if abs(text.position.y - otherText.position.y) < snapDistance {
          snapPosition!.y = otherText.position.y
        }
      }
    }
    
      // Snap to left edge of screen
    if text.leftEdge < snapDistance && text.leftEdge < closestDistance {
      closestDistance = text.leftEdge
      snapPosition = CGPoint(x: itemSpacing + (text.size.width / 2 - text.padding), y: text.position.y)
    }
    
    if let snapPosition = snapPosition {
      text.position = snapPosition
    }
  }
}

struct TextElement: View {
  @Binding var text: String
  var isEditing: Bool
  @Binding var size: CGSize
  
  var body: some View {
    TextField("", text: $text)
      .padding(10)
      .background(Material.ultraThin)
      .cornerRadius(18)
      .frame(height: 40)
      .fixedSize(horizontal: true, vertical: false)
      .background(
        GeometryReader { geometry in
          Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
      )
      .onPreferenceChange(SizePreferenceKey.self) { newSize in
        size = newSize
      }
  }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

#Preview {
  PromptAssembly()
}

import SwiftUI

struct SimplifiedScrollView: View {
  @Environment(\.colorScheme) var colorScheme
  @State private var scrollOffset: CGFloat = 0
  
  let rowCount = 20
  let columnCount = 4
  
  var body: some View {
    GeometryReader { geometry in
      let fullWidth = geometry.size.width * 0.9
      let itemSpacing: CGFloat = 8
      
      ZStack {
        Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_1")
          .resizable()
          .scaleEffect(1.4)
          .blur(radius: 80)
          .saturation(3)
          .opacity(0.2)
          .edgesIgnoringSafeArea(.all)
        
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: itemSpacing) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
              
              ScrollView(.horizontal, showsIndicators: false){
                HStack{
                  Image("graycrawford_httpss.mj.runELHHW3vPFDk_httpss.mj.runTPKTpAnYMo_4358b208-8c60-41e0-82de-7217f6ba532d_1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: fullWidth, height: fullWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
              }
            }
            
            .frame(width: fullWidth, alignment: .topLeading)
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
            //                  .blur(radius: 4)
          Spacer()
          Spacer()
          Spacer()
          Spacer()
          Image(systemName: "bubbles.and.sparkles")
            .blur(radius: 2)
            .opacity(0.5)
          
          Spacer()
          Image(systemName: "lasso.badge.sparkles")
            .blur(radius: 2)
            .opacity(0.5)
          Spacer()
          Image(systemName: "arrow.up.and.down.and.sparkles")
            //                  .blur(radius: 4)
          
        }
        .blendMode(colorScheme == .light ? .plusDarker : .plusLighter)
        .padding([.leading, .trailing], 24)
        .padding(.top, 0)
        .padding(.bottom, 0)
      }
    }
  }
}

#Preview {
  SimplifiedScrollView()
}

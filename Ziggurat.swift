import SwiftUI

struct Ziggurat: View {
 
 var body: some View {
  GeometryReader { geometry in
   let itemWidth = geometry.size.width * 0.9
   let itemHeight = itemWidth
   
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
           .clipShape(RoundedRectangle(cornerRadius: itemWidth * 0.1))
//          Spacer()
          ScrollView(.horizontal, showsIndicators: false) {
           HStack(spacing: -30) {
            ForEach(0..<4, id: \.self) { index in
             VStack(alignment: .trailing, spacing: 8) {
              Image("\(index)")
               .resizable()
               .aspectRatio(contentMode: .fill)
               .frame(width: itemWidth, height: itemHeight)
               .clipShape(RoundedRectangle(cornerRadius: itemWidth * 0.1))
             
             }
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
         }
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
  }
  
 }
}

#Preview {
 Ziggurat()
}


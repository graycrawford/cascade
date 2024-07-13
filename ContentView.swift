import SwiftUI

struct ContentView: View {
  
    @State private var currentZoom = CGFloat(0)
    @State private var totalZoom = CGFloat(1)

  
    var body: some View {
        ZStack {
          Color(hue: 0.14, saturation: 0.1, brightness: 0.98)
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 20) {
                    ForEach(0..<10) { _ in
                        ImageRow(currentZoom: $currentZoom)
                    }
                }
                .gesture(
                    MagnificationGesture()
                      .onChanged { value in
                        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.1)) {
                          currentZoom = 95 + (value - 1) * 100
                        }
                      }
                      .onEnded { _ in
                        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.9, blendDuration: 0.1)) {
                          totalZoom += currentZoom
                          currentZoom = currentZoom
                        }
                    }
                    
                )
                .padding(20)
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
                        .frame(height: geom.safeAreaInsets.bottom)
                }
                .ignoresSafeArea()
            }
        }
    }
  
  
}

struct ImageRow: View {
    @Binding var currentZoom: CGFloat

    var body: some View {
      ZStack(alignment: .top) {
            BackgroundRectangle(currentZoom: $currentZoom)
          .offset(y: 4)

            HStack(spacing: 0) {
                ImageSquare(cornerStyle: UnevenRoundedRectangle(
                    topLeadingRadius: 15, bottomLeadingRadius: 15,
                    bottomTrailingRadius: 5, topTrailingRadius: 5, style: .continuous))

                ForEach(0..<2) { _ in
                    ImageSquare(cornerStyle: RoundedRectangle(cornerRadius: 5, style: .continuous))
                }

                ImageSquare(cornerStyle: UnevenRoundedRectangle(
                    topLeadingRadius: 5, bottomLeadingRadius: 5,
                    bottomTrailingRadius: 15, topTrailingRadius: 15, style: .continuous))
            }
            .frame(height: 92)
        }
    }
}

struct BackgroundRectangle: View {
    @Binding var currentZoom: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .frame(width: 360, height: max(0, currentZoom))
            .foregroundColor(Color(hue: 0, saturation: 0, brightness: 1, opacity: 0.8))
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.05),
                    radius: 10, x: 0, y: 5)
            .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: 0.02),
                    radius: 1, x: 0, y: 2)
//            .blur(radius: 10)
      //Text("hello")
  }
}

struct ImageSquare<S: Shape>: View {
    var cornerStyle: S
  let randomHue = Double.random(in: 0.5200...0.9913)
  let randomSat = Double.random(in: 0.02200...0.5600)
  let randomBrightness = Double.random(in: 0.8200...0.9000)

    var body: some View {
        cornerStyle
            .frame(width: 92, height: 92)
            .foregroundColor(Color(hue: randomHue, saturation: randomSat, brightness: randomBrightness))
            .shadow(color: Color(hue: randomHue, saturation: randomSat, brightness: 0.4 * (randomBrightness / 10.0), opacity: 0.03),
                    radius: 10, x: 0, y: 5)
            .shadow(color: Color(hue: randomHue, saturation: randomSat, brightness: 0.1 * (randomBrightness / 10.0), opacity: 0.05),
                    radius: 1, x: 0, y: 2)
    }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

//
//  ContentView 2.swift
//  mj
//
//  Created by Gray Crawford on 7/16/24.
//


import SwiftUI

struct Shader: View {
    var body: some View {
        ZStack {
            // Background with "Hello World" text
            GeometryReader { geometry in
                let size = geometry.size
                ForEach(0..<20) { row in
                    ForEach(0..<10) { column in
                        Text("Hello World")
                            .font(.system(size: 20))
                            .foregroundColor(.gray.opacity(0.5))
                            .rotationEffect(.degrees(Double.random(in: -30...30)))
                            .position(
                                x: CGFloat(column) * size.width / 10 + CGFloat.random(in: -20...20),
                                y: CGFloat(row) * size.height / 20 + CGFloat.random(in: -20...20)
                            )
                    }
                }
            }
            
            // Custom shader view
            ShaderView()
        }
    }
}

struct ShaderView: View {
    @State private var time: Double = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let shader = Shader(function: .init(library: .default, name: "customShader"), arguments: [
                    .float2(Float(size.width), Float(size.height)),
                    .float(Float(time))
                ])
                context.addFilter(.shader(shader))
                context.drawLayer { ctx in
                    ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))
                }
            }
            .onChange(of: timeline.date) { newValue in
                time = newValue.timeIntervalSince1970
            }
        }
        .ignoresSafeArea()
    }
}

struct ShaderLibrary: ShaderLibrary {
    @Shader func customShader(position: Float2, size: Float2, time: Float) -> Color {
        let p = position / size
        let l = Float2(0.5, 0.5)
        let v = Float2(cos(time * 0.1), sin(time * 0.1)) * 0.1
        
        let m = -v * pow(max(1 - distance(l, p) / 0.5, 0), 2) * 1.5
        var c = Float3(0)
        
        for i in 0..<10 {
            let s = 0.175 + 0.005 * Float(i)
            c.x += sample(position + s * m).x
            c.y += sample(position + (s + 0.025) * m).y
            c.z += sample(position + (s + 0.05) * m).z
        }
        
        return Color(red: Double(c.x / 10), green: Double(c.y / 10), blue: Double(c.z / 10), opacity: 1)
    }
}


#Preview{
        Shader()
    }

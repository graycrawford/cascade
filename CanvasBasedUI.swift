import SwiftUI

struct CanvasBasedUI: View {
    @State private var touchLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var nodes: [Node] = [
        Node(id: 1, position: CGPoint(x: 100, y: 100), color: .red),
        Node(id: 2, position: CGPoint(x: 200, y: 200), color: .blue),
        Node(id: 3, position: CGPoint(x: 300, y: 300), color: .green)
    ]

    var body: some View {
        Canvas { context, size in
            for node in nodes {
                let rect = CGRect(x: node.position.x - 25, y: node.position.y - 25, width: 50, height: 50)
                context.fill(Path(ellipseIn: rect), with: .color(node.color))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    touchLocation = value.location
                    if !isDragging {
                        isDragging = true
                        if let index = nodes.firstIndex(where: { $0.isPointInside(touchLocation) }) {
                            nodes[index].isDragging = true
                        }
                    }
                    nodes = nodes.map { node in
                        var updatedNode = node
                        if node.isDragging {
                            updatedNode.position = touchLocation
                        }
                        return updatedNode
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    nodes = nodes.map { node in
                        var updatedNode = node
                        updatedNode.isDragging = false
                        return updatedNode
                    }
                }
        )
    }
}

struct Node: Identifiable {
    let id: Int
    var position: CGPoint
    let color: Color
    var isDragging: Bool = false
    
    func isPointInside(_ point: CGPoint) -> Bool {
        return position.distance(to: point) <= 25
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}


struct canv: PreviewProvider {
    static var previews: some View {
      CanvasBasedUI()
    }
}

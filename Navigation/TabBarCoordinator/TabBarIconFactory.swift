import UIKit

enum VKTabIcon {
    case home
    case chats
    case music
    case menu
}

enum TabBarIconFactory {
    static func icon(for type: VKTabIcon, selected: Bool) -> UIImage {
        let size = CGSize(width: 26, height: 26)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cg = context.cgContext
            cg.setLineWidth(selected ? 2.3 : 2.0)
            cg.setStrokeColor(UIColor.black.cgColor)
            cg.setFillColor(UIColor.black.cgColor)

            switch type {
            case .home:
                drawHome(in: cg, size: size, filled: selected)
            case .chats:
                drawChats(in: cg, size: size, filled: selected)
            case .music:
                drawMusic(in: cg, size: size, filled: selected)
            case .menu:
                drawMenu(in: cg, size: size, filled: selected)
            }
        }.withRenderingMode(.alwaysTemplate)
    }

    private static func drawHome(in cg: CGContext, size: CGSize, filled: Bool) {
        let rect = CGRect(x: 5, y: 11, width: 16, height: 11)
        let roof = UIBezierPath()
        roof.move(to: CGPoint(x: 4, y: 12))
        roof.addLine(to: CGPoint(x: 13, y: 4))
        roof.addLine(to: CGPoint(x: 22, y: 12))
        roof.stroke()

        let body = UIBezierPath(roundedRect: rect, cornerRadius: 2)
        if filled { body.fill() } else { body.stroke() }
    }

    private static func drawChats(in cg: CGContext, size: CGSize, filled: Bool) {
        let first = UIBezierPath(roundedRect: CGRect(x: 3, y: 5, width: 13, height: 10), cornerRadius: 4)
        let second = UIBezierPath(roundedRect: CGRect(x: 10, y: 11, width: 13, height: 10), cornerRadius: 4)
        if filled {
            first.fill()
            second.fill()
        } else {
            first.stroke()
            second.stroke()
        }
    }

    private static func drawMusic(in cg: CGContext, size: CGSize, filled: Bool) {
        let noteHead = UIBezierPath(ovalIn: CGRect(x: 7, y: 15, width: 6, height: 6))
        filled ? noteHead.fill() : noteHead.stroke()

        let noteHead2 = UIBezierPath(ovalIn: CGRect(x: 15, y: 13, width: 6, height: 6))
        filled ? noteHead2.fill() : noteHead2.stroke()

        let stem = UIBezierPath()
        stem.move(to: CGPoint(x: 12, y: 17))
        stem.addLine(to: CGPoint(x: 12, y: 6))
        stem.addLine(to: CGPoint(x: 20, y: 8))
        stem.addLine(to: CGPoint(x: 20, y: 15))
        stem.stroke()
    }

    private static func drawMenu(in cg: CGContext, size: CGSize, filled: Bool) {
        let yValues: [CGFloat] = [7, 13, 19]
        yValues.forEach { y in
            let path = UIBezierPath(roundedRect: CGRect(x: 5, y: y, width: 16, height: filled ? 3 : 2), cornerRadius: 1)
            path.fill()
        }
    }
}

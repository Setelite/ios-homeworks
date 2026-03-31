import UIKit

enum VKTabIcon {
    case home
    case search
    case chats
    case clips
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
            case .search:
                drawSearch(in: cg, size: size, filled: selected)
            case .chats:
                drawChats(in: cg, size: size, filled: selected)
            case .clips:
                drawClips(in: cg, size: size, filled: selected)
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

    private static func drawSearch(in cg: CGContext, size: CGSize, filled: Bool) {
        let circle = CGRect(x: 5, y: 5, width: 12, height: 12)
        if filled {
            UIBezierPath(ovalIn: circle).fill()
            cg.setBlendMode(.clear)
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 6, height: 6)).fill()
            cg.setBlendMode(.normal)
        } else {
            UIBezierPath(ovalIn: circle).stroke()
        }

        let handle = UIBezierPath()
        handle.move(to: CGPoint(x: 15, y: 15))
        handle.addLine(to: CGPoint(x: 22, y: 22))
        handle.stroke()
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

    private static func drawClips(in cg: CGContext, size: CGSize, filled: Bool) {
        let rect = UIBezierPath(roundedRect: CGRect(x: 4, y: 6, width: 18, height: 14), cornerRadius: 3)
        if filled { rect.fill() } else { rect.stroke() }

        let play = UIBezierPath()
        play.move(to: CGPoint(x: 11, y: 9))
        play.addLine(to: CGPoint(x: 11, y: 17))
        play.addLine(to: CGPoint(x: 17, y: 13))
        play.close()

        if filled {
            cg.setBlendMode(.clear)
            play.fill()
            cg.setBlendMode(.normal)
        } else {
            play.fill()
        }
    }

    private static func drawMenu(in cg: CGContext, size: CGSize, filled: Bool) {
        let yValues: [CGFloat] = [7, 13, 19]
        yValues.forEach { y in
            let path = UIBezierPath(roundedRect: CGRect(x: 5, y: y, width: 16, height: filled ? 3 : 2), cornerRadius: 1)
            path.fill()
        }
    }
}

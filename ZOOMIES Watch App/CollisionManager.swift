import CoreGraphics

enum CollisionManager {
    static func intersects(playerFrame: CGRect, itemCenter: CGPoint, itemSize: CGSize) -> Bool {
        let itemFrame = CGRect(
            x: itemCenter.x - itemSize.width / 2,
            y: itemCenter.y - itemSize.height / 2,
            width: itemSize.width,
            height: itemSize.height
        )
        return playerFrame.intersects(itemFrame)
    }
}

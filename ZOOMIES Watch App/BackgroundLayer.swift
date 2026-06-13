import SwiftUI

struct BackgroundLayer: View {
    let map: MapType
    let offset: CGFloat
    let size: CGSize

    var body: some View {
        ZStack(alignment: .bottom) {
            map.sky
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "cloud.fill" : map.propSymbol)
                    .font(.system(size: index.isMultiple(of: 2) ? 25 : 34))
                    .foregroundStyle(index.isMultiple(of: 2) ? .white.opacity(0.55) : .white.opacity(0.22))
                    .position(x: wrappedX(CGFloat(index) * 72 + offset * (index.isMultiple(of: 2) ? 0.18 : 0.35)),
                              y: index.isMultiple(of: 2) ? 38 : size.height - 50)
            }
        }
        .ignoresSafeArea()
    }

    private func wrappedX(_ x: CGFloat) -> CGFloat {
        let width = max(size.width, 1)
        return x.truncatingRemainder(dividingBy: width + 70) + 20
    }
}

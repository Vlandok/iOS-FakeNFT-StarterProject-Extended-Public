import SwiftUI

struct RatingView: View {

    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundColor(.ypYellow)
            }
        }
    }
}

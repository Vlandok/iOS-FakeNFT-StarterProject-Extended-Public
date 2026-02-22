import SwiftUI

struct DeleteConfirmationSwiftUIView: View {
    let item: BasketItem
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Blur на весь экран
            VisualEffectBlur(blurStyle: .light)
                .ignoresSafeArea()
            
            // Контент по центру
            VStack(spacing: 12) {
                AsyncImage(url: item.images.first) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("Вы уверены, что хотите\nудалить объект из корзины?")
                    .font(.system(size: 13, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Button(action: {
                        dismiss()
                        onConfirm()
                    }) {
                        Text("Удалить")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(Color(red: 0.96, green: 0.42, blue: 0.42))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Вернуться")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 56)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

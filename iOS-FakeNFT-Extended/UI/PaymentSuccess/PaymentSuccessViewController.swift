import SwiftUI

struct PaymentSuccessSwiftUIView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Binding var isTabBarVisible: Bool
    
    init(isTabBarVisible: Binding<Bool>) {
        _isTabBarVisible = isTabBarVisible
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("56_digital_art_x4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 278, height: 278)
            
            Text("Успех! Оплата прошла,\nпоздравляем с покупкой!")
                .font(.custom("SF Pro Text", size: 22).weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 20)
            
            Spacer()
            
            Button(action: {
                // Отправляем уведомление для обновления корзины
                NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
                
                // Показываем TabBar перед возвратом
                isTabBarVisible = true
                
                // Возвращаемся назад через navigation stack
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    findAndPopNavigation(in: rootVC)
                }
            }) {
                Text(NSLocalizedString("Success.back", comment: ""))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.black)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isTabBarVisible = false
        }
    }
    
    private func findAndPopNavigation(in viewController: UIViewController) {
        if let navController = findNavigationController(in: viewController) {
            // Возвращаемся к корзине (popToRoot вернет к первому экрану в navigation stack)
            navController.popToRootViewController(animated: true)
        }
    }
    
    private func findNavigationController(in viewController: UIViewController) -> UINavigationController? {
        if let navController = viewController as? UINavigationController {
            return navController
        }
        
        if let tabBarController = viewController as? UITabBarController {
            // Ищем в выбранном tab
            if let selectedVC = tabBarController.selectedViewController {
                return findNavigationController(in: selectedVC)
            }
        }
        
        for child in viewController.children {
            if let navController = findNavigationController(in: child) {
                return navController
            }
        }
        
        return nil
    }
}

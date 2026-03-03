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
                // Показываем TabBar
                isTabBarVisible = true
                
                // Закрываем все модальные окна и возвращаемся к root
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    dismissAllPresentedViewControllers(from: rootVC)
                }
                
                // Сбрасываем navigation stack корзины
                NotificationCenter.default.post(name: NSNotification.Name("ResetBasketNavigation"), object: nil)
                
                // Переключаемся на таб корзины
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToBasketTab"), object: nil)
                
                // Обновляем корзину с задержкой
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
                }
            }) {
                Text(NSLocalizedString("Success.back", comment: ""))
                    .font(.system(size: 17, weight: .bold))
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
    
    private func dismissAllPresentedViewControllers(from viewController: UIViewController) {
        if let presented = viewController.presentedViewController {
            presented.dismiss(animated: false) {
                self.dismissAllPresentedViewControllers(from: viewController)
            }
        }
    }
    
    private func findAndPopNavigation(in viewController: UIViewController) {
        if let navController = findNavigationController(in: viewController) {
            // Возвращаемся к корзине
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

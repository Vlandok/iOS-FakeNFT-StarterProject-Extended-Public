import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            // Профиль
            ProfileView()
                .tabItem {
                    Label {
                        Text(NSLocalizedString("Tab.profile", comment: ""))
                    } icon: {
                        Image("TabIconProfile")
                            .renderingMode(.template)
                    }
                }
            
            // Каталог
            TestCatalogView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.catalog", comment: ""),
                        systemImage: "square.stack.3d.up.fill"
                    )
                }
            
            // Корзина
            BasketTabView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.cart", comment: ""),
                        systemImage: "bag.fill"
                    )
                }
            
            // Статистика
            StatisticsPlaceholderView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.statistics", comment: ""),
                        systemImage: "flag.2.crossed.fill"
                    )
                }
        }
        .tint(Color(.ypBlue))
    }
}

// MARK: - Placeholder Views

struct StatisticsPlaceholderView: View {
    var body: some View {
        Text("Статистика")
            .font(.title)
    }
}

struct BasketTabView: UIViewControllerRepresentable {
    @Environment(ServicesAssembly.self) private var services
    
    func makeUIViewController(context: Context) -> UIViewController {
        let assembly = BasketAssembly()
        return assembly.build(service: services.basketService)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


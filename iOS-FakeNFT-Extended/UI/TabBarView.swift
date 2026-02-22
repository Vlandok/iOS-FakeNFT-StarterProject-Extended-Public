import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
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
                .tag(0)
            
            // Каталог
            TestCatalogView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.catalog", comment: ""),
                        systemImage: "square.stack.3d.up.fill"
                    )
                }
                .tag(1)
            
            // Корзина
            BasketTabView()
                .tabItem {
                    Label {
                        Text(NSLocalizedString("Tab.cart", comment: ""))
                    } icon: {
                        Image("Basket")
                            .renderingMode(.template)
                    }
                }
                .tag(2)
            
            // Статистика
            StatisticsPlaceholderView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.statistics", comment: ""),
                        systemImage: "flag.2.crossed.fill"
                    )
                }
                .tag(3)
        }
        .tint(Color(.ypBlue))
        .onChange(of: selectedTab) { oldValue, newValue in
            print("📱 [TabBar] Tab changed: \(oldValue) -> \(newValue)")
            // Перезагружаем корзину при переключении на вкладку корзины
            if newValue == 2 {
                print("📱 [TabBar] Switched to BASKET tab - posting RefreshBasket notification")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
            }
        }
        .onAppear {
            // Загружаем корзину при первом запуске, если открыта вкладка корзины
            if selectedTab == 2 {
                print("📱 [TabBar] Initial load - BASKET tab is selected")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
            }
        }
    }
}

// MARK: - Placeholder Views

struct StatisticsPlaceholderView: View {
    var body: some View {
        Text("Статистика")
            .font(.title)
    }
}

struct BasketTabView: View {
    @Environment(ServicesAssembly.self) private var services
    
    var body: some View {
        BasketSwiftUIView(service: services.basketService)
    }
}


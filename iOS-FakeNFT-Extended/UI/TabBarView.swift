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
            if newValue == 2 {
                print("[TabBarView] INFO: Switched to basket tab, posting refresh notification")
                NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
            }
        }
        .onAppear {
            if selectedTab == 2 {
                print("[TabBarView] INFO: Initial load with basket tab selected")
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
    @State private var isTabBarVisible = true
    
    var body: some View {
        BasketSwiftUIView(service: services.basketService, isTabBarVisible: $isTabBarVisible)
            .onAppear {
                isTabBarVisible = true
            }
    }
}


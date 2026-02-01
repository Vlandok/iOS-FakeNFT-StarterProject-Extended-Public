import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            // Профиль
            ProfilePlaceholderView()
                .tabItem {
                    Label(
                        NSLocalizedString("Tab.profile", comment: ""),
                        systemImage: "person.crop.circle.fill"
                    )
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
            CartPlaceholderView()
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

struct ProfilePlaceholderView: View {
    var body: some View {
        Text("Профиль")
            .font(.title)
    }
}

struct CartPlaceholderView: View {
    var body: some View {
        Text("Корзина")
            .font(.title)
    }
}

struct StatisticsPlaceholderView: View {
    var body: some View {
        Text("Статистика")
            .font(.title)
    }
}

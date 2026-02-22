import SwiftUI

@main
struct iOS_FakeNFT_ExtendedApp: App {
    @State private var services = ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl())
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    print("🚀 [App] scenePhase changed: \(oldPhase) -> \(newPhase)")
                    if newPhase == .active {
                        print("🚀 [App] App became ACTIVE - posting RefreshBasket notification")
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshBasket"), object: nil)
                    }
                }
        }
    }
}

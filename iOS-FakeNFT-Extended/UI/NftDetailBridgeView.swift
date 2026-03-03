import SwiftUI

struct NftDetailBridgeView: UIViewControllerRepresentable {
    typealias UIViewControllerType = NftDetailViewController

    @Environment(ServicesAssembly.self) var servicesAssembly

    func makeUIViewController(context: Context) -> NftDetailViewController {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let nftInput = NftDetailInput(id: Constants.testNftId)
        guard let nftViewController = assembly.build(with: nftInput) as? NftDetailViewController else {
            fatalError("Failed to build NftDetailViewController")
        }
        return nftViewController
    }

    func updateUIViewController(_ uiViewController: NftDetailViewController, context: Context) {
      
    }
}

private enum Constants {
    static let testNftId = "7773e33c-ec15-4230-a102-92426a3a6d5a"
}

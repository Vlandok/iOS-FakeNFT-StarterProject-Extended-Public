import Foundation

enum MyNFTState: Sendable {
    case initial
    case loading
    case loaded([NFTItem])
    case empty
    case error(String)
}

enum MyNFTSortOption: String {
    case price
    case rating
    case name
    
    static let `default`: MyNFTSortOption = .rating
}

struct NFTItem: Identifiable, Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let author: String
    let price: Double
    let isLiked: Bool
}

@MainActor
final class MyNFTViewModel: ObservableObject {
    
    private enum Constants {
        static let sortOptionKey = "MyNFTSortOption"
    }
    
    @Published private(set) var state: MyNFTState = .initial
    @Published private(set) var nfts: [NFTItem] = []
    @Published var showSortOptions: Bool = false
    
    private let likedNFTIds: Set<String>
    private var currentSortOption: MyNFTSortOption {
        didSet {
            UserDefaults.standard.set(currentSortOption.rawValue, forKey: Constants.sortOptionKey)
        }
    }
    
    var isEmpty: Bool {
        nfts.isEmpty
    }
    
    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
    
    init(nftIds: [String] = [], likedIds: [String] = []) {
        self.likedNFTIds = Set(likedIds)
        
        if let savedValue = UserDefaults.standard.string(forKey: Constants.sortOptionKey),
           let savedOption = MyNFTSortOption(rawValue: savedValue) {
            self.currentSortOption = savedOption
        } else {
            self.currentSortOption = .default
        }
        
        loadMockData()
    }
    
    func sortByPrice() {
        currentSortOption = .price
        applyCurrentSort()
    }
    
    func sortByRating() {
        currentSortOption = .rating
        applyCurrentSort()
    }
    
    func sortByName() {
        currentSortOption = .name
        applyCurrentSort()
    }
    
    private func applyCurrentSort() {
        switch currentSortOption {
        case .price:
            nfts.sort { $0.price < $1.price }
        case .rating:
            nfts.sort { $0.rating > $1.rating }
        case .name:
            nfts.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }
    
    private func loadMockData() {
        state = .loading
        
        let mockNFTs: [NFTItem] = [
            NFTItem(
                id: "1",
                name: "Lilo",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Pink/Lilo/1.png"),
                rating: 3,
                author: "John Doe",
                price: 1.78,
                isLiked: likedNFTIds.contains("1")
            ),
            NFTItem(
                id: "2",
                name: "Spring",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Green/Melissa/1.png"),
                rating: 4,
                author: "John Doe",
                price: 2.50,
                isLiked: likedNFTIds.contains("2")
            ),
            NFTItem(
                id: "3",
                name: "April",
                imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/Finn/1.png"),
                rating: 5,
                author: "John Doe",
                price: 0.99,
                isLiked: likedNFTIds.contains("3")
            )
        ]
        
        nfts = mockNFTs
        applyCurrentSort()
        state = nfts.isEmpty ? .empty : .loaded(nfts)
    }
    
    private static func mapError(_ error: Error) -> String {
        switch error {
        case NetworkClientError.httpStatusCode(let code):
            return NSLocalizedString("Error.network", comment: "") + " (\(code))"
        case NetworkClientError.urlSessionError:
            return NSLocalizedString("Error.network", comment: "")
        case NetworkClientError.parsingError:
            return NSLocalizedString("Error.parsing", comment: "")
        default:
            return error.localizedDescription
        }
    }
}

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
    
    private let nftService: MyNFTListService
    private let nftIds: [String]
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
    
    init(
        nftIds: [String],
        likedIds: [String],
        nftService: MyNFTListService = MyNFTListServiceImpl(networkClient: DefaultNetworkClient())
    ) {
        self.nftIds = nftIds
        self.likedNFTIds = Set(likedIds)
        self.nftService = nftService
        
        if let savedValue = UserDefaults.standard.string(forKey: Constants.sortOptionKey),
           let savedOption = MyNFTSortOption(rawValue: savedValue) {
            self.currentSortOption = savedOption
        } else {
            self.currentSortOption = .default
        }
        
        loadNFTs()
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
    
    private func loadNFTs() {
        guard !nftIds.isEmpty else {
            state = .empty
            return
        }
        
        state = .loading
        
        Task { @MainActor in
            do {
                let networkModels = try await nftService.loadNFTs(ids: nftIds)
                
                nfts = networkModels.map { model in
                    NFTItem(
                        id: model.id,
                        name: model.name,
                        imageURL: model.images.first.flatMap { URL(string: $0) },
                        rating: model.rating,
                        author: model.author,
                        price: model.price,
                        isLiked: likedNFTIds.contains(model.id)
                    )
                }
                
                applyCurrentSort()
                state = nfts.isEmpty ? .empty : .loaded(nfts)
            } catch {
                state = .error(Self.mapError(error))
            }
        }
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

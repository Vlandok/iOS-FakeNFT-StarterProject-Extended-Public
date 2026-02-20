import SwiftUI

@MainActor
final class CatalogViewModel: ObservableObject {
    
    enum State {
        case initial
        case loading
        case loaded([CatalogCollectionDomain])
        case error(String)
    }
    
    @Published private(set) var state: State = .initial
    @Published var selectedCollection: CatalogCollectionDomain?
    
    private var collectionsService: CollectionsService
    private var originalCollections: [CatalogCollectionDomain] = []
    private var currentSort: CatalogSortType?
    
    init(collectionsService: CollectionsService) {
        self.collectionsService = collectionsService
        loadCollections()
    }
    
    func updateService(_ service: CollectionsService) async {
        self.collectionsService = service
        loadCollections()
    }
    
    func loadCollections() {
        state = .loading
        
        Task { @MainActor in
            do {
                let networkModels = try await collectionsService.loadCollections()
                let collections = networkModels.map { CatalogCollectionDomain(from: $0) }
                
                originalCollections = collections
                state = .loaded(collections)
            } catch {
                state = .error(Self.mapError(error))
            }
        }
    }
    
    func sortCollection(by type: CatalogSortType) {
        currentSort = type
        
        guard case .loaded(var collections) = state else { return }
        
        switch type {
        case .byName:
            collections.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .byNftCount:
            collections.sort { $0.nftCount > $1.nftCount }
        }
        
        state = .loaded(collections)
    }
    
    func selectCollection(_ collection: CatalogCollectionDomain) {
        selectedCollection = collection
    }
    
    func retry() {
        loadCollections()
    }
    
    private static func mapError(_ error: Error) -> String {
        switch error {
        case NetworkClientError.httpStatusCode(let code):
            return "Ошибка сервера: \(code)"
        case NetworkClientError.urlSessionError:
            return "Нет соединения с интернетом"
        case NetworkClientError.parsingError:
            return "Ошибка обработки данных"
        default:
            return error.localizedDescription
        }
    }
    
}

import Foundation

public protocol BasketService {
    func loadBasket(completion: @escaping (Result<Basket, Error>) -> Void)
    func updateBasket(nftIds: [String], completion: @escaping (Result<Basket, Error>) -> Void)
    func loadNftDetails(ids: [String], completion: @escaping (Result<[BasketItem], Error>) -> Void)
    func loadCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
}

final class BasketServiceImpl: BasketService {
    private let networkClient: NetworkClient
    private let queue = DispatchQueue(label: "com.fakenft.basketService", qos: .userInitiated)
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadBasket(completion: @escaping (Result<Basket, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let request = BasketRequest()
            
            Task {
                do {
                    let basket: Basket = try await self.networkClient.send(request: request)
                    DispatchQueue.main.async {
                        completion(.success(basket))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func updateBasket(nftIds: [String], completion: @escaping (Result<Basket, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let request = UpdateBasketRequest(nftIds: nftIds)
            
            Task {
                do {
                    let basket: Basket = try await self.networkClient.send(request: request)
                    DispatchQueue.main.async {
                        completion(.success(basket))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func loadNftDetails(ids: [String], completion: @escaping (Result<[BasketItem], Error>) -> Void) {
        let group = DispatchGroup()
        let resultQueue = DispatchQueue(label: "com.fakenft.nftDetails", attributes: .concurrent)
        var items: [BasketItem] = []
        var loadError: Error?
        
        for id in ids {
            group.enter()
            queue.async { [weak self] in
                guard let self = self else {
                    group.leave()
                    return
                }
                
                let request = NFTByIdRequest(nftId: id)
                Task {
                    do {
                        let nft: NFTNetworkModel = try await self.networkClient.send(request: request)
                        
                        // Конвертируем строковые URL в URL объекты
                        let imageUrls = nft.images.compactMap { URL(string: $0) }
                        
                        let item = BasketItem(
                            id: nft.id,
                            name: nft.name,
                            rating: nft.rating,
                            price: nft.price,
                            images: imageUrls
                        )
                        resultQueue.async(flags: .barrier) {
                            items.append(item)
                        }
                    } catch {
                        resultQueue.async(flags: .barrier) {
                            loadError = error
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if let error = loadError {
                completion(.failure(error))
            } else {
                completion(.success(items))
            }
        }
    }
    
    func loadCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let request = CurrenciesRequest()
            
            Task {
                do {
                    let currencies: [Currency] = try await self.networkClient.send(request: request)
                    DispatchQueue.main.async {
                        completion(.success(currencies))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

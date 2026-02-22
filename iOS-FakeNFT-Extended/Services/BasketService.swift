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
        print("🌐 [BasketService] ========== START loadBasket ==========")
        queue.async { [weak self] in
            guard let self = self else { 
                print("🌐 [BasketService] ❌ self is nil")
                return 
            }
            let request = BasketRequest()
            print("🌐 [BasketService] Created BasketRequest")
            print("🌐 [BasketService] Endpoint: \(request.endpoint?.absoluteString ?? "nil")")
            
            // Используем семафор для синхронного ожидания async/await
            let semaphore = DispatchSemaphore(value: 0)
            var result: Result<Basket, Error>?
            
            Task {
                do {
                    print("🌐 [BasketService] Sending request...")
                    let basket: Basket = try await self.networkClient.send(request: request)
                    print("🌐 [BasketService] ✅ Response received")
                    print("🌐 [BasketService] Basket.nfts: \(basket.nfts)")
                    result = .success(basket)
                } catch {
                    print("🌐 [BasketService] ❌ Request failed: \(error)")
                    result = .failure(error)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        print("🌐 [BasketService] ========== END loadBasket (async) ==========")
    }
    
    func updateBasket(nftIds: [String], completion: @escaping (Result<Basket, Error>) -> Void) {
        print("🌐 [BasketService] ========== START updateBasket ==========")
        print("🌐 [BasketService] Updating basket with \(nftIds.count) items: \(nftIds)")
        queue.async { [weak self] in
            guard let self = self else { 
                print("🌐 [BasketService] ❌ self is nil in updateBasket")
                return 
            }
            let request = UpdateBasketRequest(nftIds: nftIds)
            print("🌐 [BasketService] Created UpdateBasketRequest")
            print("🌐 [BasketService] Endpoint: \(request.endpoint?.absoluteString ?? "nil")")
            print("🌐 [BasketService] Method: \(request.httpMethod.rawValue)")
            print("🌐 [BasketService] ContentType: \(request.contentType)")
            
            // Используем семафор для синхронного ожидания async/await
            let semaphore = DispatchSemaphore(value: 0)
            var result: Result<Basket, Error>?
            
            Task {
                do {
                    print("🌐 [BasketService] Sending update request...")
                    let basket: Basket = try await self.networkClient.send(request: request)
                    print("🌐 [BasketService] ✅ Update response received")
                    print("🌐 [BasketService] Updated basket.nfts: \(basket.nfts)")
                    result = .success(basket)
                } catch {
                    print("🌐 [BasketService] ❌ Update request failed: \(error)")
                    result = .failure(error)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        print("🌐 [BasketService] ========== END updateBasket (async) ==========")
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
                
                // Используем семафор для синхронного ожидания async/await
                let semaphore = DispatchSemaphore(value: 0)
                
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
                    semaphore.signal()
                }
                
                semaphore.wait()
                group.leave()
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
            
            // Используем семафор для синхронного ожидания async/await
            let semaphore = DispatchSemaphore(value: 0)
            var result: Result<[Currency], Error>?
            
            Task {
                do {
                    let currencies: [Currency] = try await self.networkClient.send(request: request)
                    result = .success(currencies)
                } catch {
                    result = .failure(error)
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}

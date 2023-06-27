//
//  HomeViewModel.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 01/04/23.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject{
    @Published var statistics: [StatisticModel] = []
    
    @Published var allCoins : [CoinModel] = []
    @Published var portfolioCoins : [CoinModel] = []
    @Published var isLoading : Bool = false
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    
    private var cancellables = Set<AnyCancellable>()
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    
    enum SortOption{
        case rank,rankReversed,holdings,holdingsReversed,price,priceReversed
    }
    
    init(){
        
        addSubscribers()
    }
    
    func addSubscribers(){
        // updates allcoins
        $searchText
            .combineLatest(coinDataService.$allCoins,$sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        
        //updates portfolioCoins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfoilioCoins)
            .sink {[weak self] returnedCoins in
                guard let self = self else{
                    return
                }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        
        
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink {[weak self] (returnedStats) in
                self?.statistics = returnedStats
                self?.isLoading=false;
            }
            .store(in: &cancellables)
    }
    
    private func mapAllCoinsToPortfoilioCoins(allCoins:[CoinModel],portfolioEntities:[PortfolioEntity])->[CoinModel]{
        allCoins
            .compactMap { coin -> CoinModel? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id}) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    func reloadData ( ) {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
    }
    
    private func mapGlobalMarketData(marketDataModel:MarketDataModel?,portfolioCoins:[CoinModel])->[StatisticModel]{
        var stats:[StatisticModel] = []
        guard let data = marketDataModel else{
            return stats
        }
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap,percentageChange: data.marketCapChangePercentage24HUsd)
        print("before3")

        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
//        let portfolioValue = portfolioCoins.map { (coin)->Double in
//            return coin.currentHoldingsValue
//        }
        
        let portfolioValue =
        portfolioCoins
            .map({$0.currentHoldingsValue})
            .reduce(0, +)
        
        let previousValue = portfolioCoins.map { (coin)->Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = coin.priceChangePercentage24H! / 100
            let previousValue = currentValue/(1+percentChange)
          return previousValue
        }
            .reduce(0,+)
        
        let percentageChange = ((portfolioValue-previousValue) / previousValue) * 100
        
        
        
        let portfolio = StatisticModel(
            title: "Potfolio Value",
            value: portfolioValue.asCurrencyWith6Decimals(),
            percentageChange: percentageChange)
        print("before4")

        stats.append(contentsOf:[
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        return stats
    }
    
    private func filterAndSortCoins(text:String,coins:[CoinModel],sort:SortOption)->[CoinModel]{
        var filteredCoins = filterCoins(text: text, coins: coins)
        let sortedCoins = sortCoins(sort: sort, coins: filteredCoins)
        //sort
        return sortedCoins
    }
    
    private func sortCoins(sort:SortOption,coins:[CoinModel])->[CoinModel]{
        
        switch sort{
        case.rank,.holdings:
            return coins.sorted { (coin1, coin2)->Bool in
                return coin1.rank < coin2.rank
            }
        case.rankReversed,.holdingsReversed:
            return coins.sorted { (coin1, coin2)->Bool in
                return coin1.rank < coin2.rank
            }
        case.price:
            return coins.sorted { (coin1, coin2)->Bool in
                return coin1.currentPrice < coin2.currentPrice
            }
        case.priceReversed:
            return coins.sorted { (coin1, coin2)->Bool in
                return coin1.currentPrice > coin2.currentPrice
            }
        }
        
    }
    
    private func sortPortfolioCoinsIfNeeded(coins:[CoinModel])->[CoinModel]{
        switch sortOption {
        case .holdings:
            return coins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingsReversed:
            return coins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
    }
    
    
    private func filterCoins(text:String,coins:[CoinModel]) -> [CoinModel]{
        guard !text.isEmpty else{
            return coins
        }
        
        let lowerCaseText = text.lowercased()
        
        return coins.filter { (coin)->Bool in
            return coin.name.lowercased().contains(lowerCaseText) ||
            coin.symbol.lowercased().contains(lowerCaseText) ||
            coin.id.lowercased().contains(lowerCaseText)
        }
    }
}

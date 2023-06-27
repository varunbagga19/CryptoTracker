//
//  DetailViewModel.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 23/05/23.
//

import Foundation
import Combine

class DetailViewModel:ObservableObject{
    
    @Published var overviewStatistics:[StatisticModel] = []
    @Published var additionalStatistics:[StatisticModel] = []
    @Published var coinDescription:String? = nil
    @Published var websiteURl:String? = nil
    @Published var redditURl:String? = nil
    
    
    @Published var coin:CoinModel
    private let coinDetailService : CoinDetailDataService
    private var cancellables = Set<AnyCancellable>()
    
    
    init(coin:CoinModel){
        self.coin = coin
        self.coinDetailService = CoinDetailDataService(coin: coin)
        addSubscribers()
    }
    
    private func addSubscribers(){
        coinDetailService.$coinDetails
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink {[weak self] (returnedArrays) in
                self?.overviewStatistics = returnedArrays.overview
                self?.additionalStatistics = returnedArrays.addtional
            }
            .store(in: &cancellables)
        
        coinDetailService.$coinDetails
            .sink {[weak self] (returnedCoinDetails) in
                self?.coinDescription = returnedCoinDetails?.readableDescription
                self?.websiteURl = returnedCoinDetails?.links?.homepage?.first
//                self?.redditURl = returnedCoinDetails.links?.subredditURL?
            }
            .store(in: &cancellables)
    }
    
    
    private func mapDataToStatistics(coinDetailModel:CoinDetailModel?,coinModel:CoinModel) -> (overview:[StatisticModel],addtional:[StatisticModel]){
        var overviewArray:[StatisticModel] = []
        let price = coinModel.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coinModel.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price,percentageChange: priceChange)
        
        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapChange = coinModel.marketCapChangePercentage24H
        let marketcapStat = StatisticModel(title: "Market Capitalization", value: marketCap,percentageChange: marketCapChange)
        
        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "rank", value: rank)
        
        let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        
        overviewArray = [
        priceStat,marketcapStat,rankStat,volumeStat
        ]
        
        //additional
        let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "n/a"
        let highStat = StatisticModel (title: "24h High", value: high)
        
        let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "n/a"
        let lowStat = StatisticModel(title: "24h Low", value: low)
        
        let pricechange = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a"
        let pricePercentChange2 = coinModel.priceChangePercentage24H
        let priceChangeStat = StatisticModel (title: "24h Price Change", value: pricechange, percentageChange: pricePercentChange2)
        
        let marketCapchange = "$" + (coinModel.marketCapChange24H?.formattedWithAbbreviations () ?? "")
        let marketCapPercentChange2 = coinModel.marketCapChangePercentage24H
        let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapchange, percentageChange:marketCapPercentChange2)
        
        let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
        let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
        
        let additionalArray: [StatisticModel] = [
        highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat
        ]
        
        return (overviewArray, additionalArray)
    }
    
}

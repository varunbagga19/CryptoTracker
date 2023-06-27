//
//  CoinDetailDataService.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 23/05/23.
//

import Foundation
import Combine
class CoinDetailDataService{
    
    @Published var coinDetails : CoinDetailModel? = nil
    
    var coinDetailSubscription : AnyCancellable?
    let coin : CoinModel
    init(coin:CoinModel){
        self.coin = coin
        getCoinsDetails()
    }
    
    func getCoinsDetails(){
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/bitcoin?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else { return }
        coinDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] (returnedCoinsDetails) in
                self?.coinDetails = returnedCoinsDetails
                self?.coinDetailSubscription?.cancel()
            })
    }
}

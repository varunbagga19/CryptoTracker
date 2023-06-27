//
//  PortfolioView.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 04/05/23.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var vm : HomeViewModel
    @State private var selectedCoin:CoinModel? = nil
    @State private var quantityText:String = ""
    @State private var showCheckMark:Bool = false
    
    
    
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading){
                    SearchBarView(searchText: $vm.searchText)
                    
                    coinLogoList
                    
                    if selectedCoin != nil{
                        portfolioInputView
                        .animation(.none)
                        .padding()
                        .font(.headline)
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    XMarkButton()
                }
                ToolbarItem(placement: .navigationBarLeading){
                    trailingnavBarButtons
                }
            })
            .onChange(of: vm.searchText) { newValue in
                if newValue == ""{
                    removeSelectedCoin()
                }
            }
            
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}
 

extension PortfolioView{
    private var coinLogoList : some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10){
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                   CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture(perform: {
                            withAnimation(.easeIn){
                               updateSelectedCoins(coin: coin)
                            }
                        })
                        .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedCoin?.id == coin.id ? Color.theme.green:Color.clear,lineWidth:1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.vertical,4)
            .padding(.leading)
        }
    }
    
    private func updateSelectedCoins(coin:CoinModel){
        
        selectedCoin = coin
        
        if let portfolioCoin = vm.portfolioCoins.first(where: {$0.id == coin.id}),
           let amount = portfolioCoin.currentHoldings{
            quantityText = "\(amount)"
        }else{
            quantityText = ""
        }
        
    }
    
    
    private func getCurrentValue() -> Double{
        
        if let quantity = Double(quantityText){
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
        
    }
    
    
    private var portfolioInputView : some View{
        VStack(spacing:20){
            HStack{
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? "") :")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            
            Divider()
            
            HStack{
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4",text: $quantityText)
                    .multilineTextAlignment(.trailing)
            }
            
            Divider()
            
            HStack{
                Text("Current Value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith6Decimals())
            }
        }
    }
    private var trailingnavBarButtons : some View {
        HStack(spacing:10){
            Button {
                saveButtonPressed()
            } label: {
                Text("Save".uppercased())
            }
            .opacity((selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0 )

            
            Image(systemName: "checkmark")
                .opacity(showCheckMark ? 1.0 :0.0)
        }
        .font(.headline)
    }
    private func saveButtonPressed(){
        
        guard let coin = selectedCoin,
         let amount = Double(quantityText)
        else {return}
        
        
        vm.updatePortfolio(coin: coin, amount: amount)
        
        //show checkMark
        withAnimation(.easeIn){
            showCheckMark = true
            removeSelectedCoin()
        }
        
        //hide
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
            withAnimation(.easeIn){
                showCheckMark = false
            }
        }
    }
    
    private func removeSelectedCoin(){
        selectedCoin = nil
        vm.searchText = ""
    }
}

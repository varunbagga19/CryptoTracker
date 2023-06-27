//
//  HomeView.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 01/04/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm :HomeViewModel
    
    @State private var showPortFolio:Bool = false //animate right
    @State private var showPortFolioView :Bool = false //new sheet
    
    
    @State private var selectedCoin :CoinModel? = nil
    @State private var showDetailView:Bool = false
    
    
    var body: some View {
        ZStack{
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortFolioView) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            
            VStack{
                
                homeHeader
                
                HomeStatView(showPortfolio: $showPortFolio)
                
                SearchBarView(searchText: $vm.searchText)
                
                columnTitles
                
                if !showPortFolio{
                   allCoinsList
                    .transition(.move(edge: .leading))
                }
                if showPortFolio{
                    portfolioCoinsList
                        .transition(.move(edge: .trailing))
                }
                
                
                
                Spacer(minLength: 0)
            }
        }
        .background(
            NavigationLink(
                destination:DetailLoadingView(coin: $selectedCoin),
                isActive: $showDetailView,
                label:{ EmptyView() }
            )
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .environmentObject(dev.homeVM)
    }
}


extension HomeView{
    private var homeHeader : some View{
        HStack{
            CircleButtonView(iconName: showPortFolio ? "plus" : "info")
                .animation(.none)
                .onTapGesture {
                    if showPortFolio {
                        showPortFolioView.toggle()
                    }
                }
                .background(
                CircleButtonAnimationView(animate: $showPortFolio)
                )
            Spacer()
            Text(showPortFolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortFolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortFolio.toggle()
                    }
                }
        }
        .padding(.horizontal)

    }
    
    private var allCoinsList :some View{
        List{
           
            ForEach(vm.allCoins) { coin in
                    CoinRowView(coin: coin, showHoldingsColumn: false)
                        .listRowInsets(.init(top: 10, leading: 0, bottom: 20, trailing: 10))
                        .onTapGesture {
                            segue(coin: coin)
                        }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.reloadData()
        }
    }
    private var portfolioCoinsList :some View{
        List{
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 20, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func segue(coin:CoinModel){
        selectedCoin = coin
        showDetailView.toggle()
        
    }
    private var columnTitles : some View{
        HStack{
            HStack(spacing: 4){
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0: 180))
            }
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                }
            }
           
            Spacer()
            if showPortFolio{
                HStack(spacing: 4){
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity((vm.sortOption == .holdings || vm.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0: 180))
                }
                .onTapGesture {
                    withAnimation(.default){
                        vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                    }
                }
            }
            HStack(spacing: 4){
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity((vm.sortOption == .price || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
            }
                .frame(width: UIScreen.main.bounds.width/3,alignment: .trailing)
                .onTapGesture {
                    withAnimation(.default){
                        vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                    }
                }
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .padding(.horizontal)
    }
}

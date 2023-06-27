//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 01/04/23.
//

import SwiftUI

@main
struct CryptoTrackerApp: App {
    @StateObject var vm = HomeViewModel()
    @State var showLaunchView:Bool = true
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            
            ZStack{
                NavigationView {
                    HomeView()
                        .toolbar(.hidden)
                }
                .environmentObject(vm)
                
                ZStack{
                    if showLaunchView{
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition((.move(edge: .leading)))
                    }
                }
                .zIndex(2.0)
                
            }
            
        }
    }
}

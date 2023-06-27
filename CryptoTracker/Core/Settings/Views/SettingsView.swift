//
//  SettingsView.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 23/05/23.
//

import SwiftUI

struct SettingsView: View {
    
    let defaultURL = URL(string:"https://www.google.com")!
    let youtubeURL = URL(string: "https://www.youtube.com/c/swiftfulthinking")!
    let coingeckoURL = URL(string:"https://www.coingecko.com")!
    
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    Text("Hi")
                } header: {
                    Text("header")
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

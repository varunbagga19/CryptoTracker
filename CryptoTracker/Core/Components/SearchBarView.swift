//
//  SearchBarView.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 26/04/23.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText:String 
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ? Color.theme.secondaryText:
                        Color.theme.accent)
            
            TextField("Search by name or symbol ...",text: $searchText)
                .foregroundColor(Color.theme.accent)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.theme.accent)
                        .autocorrectionDisabled(true)
                        .padding()
                        .offset(x:10)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                        },
                    alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(
                    color:Color.theme.accent.opacity(0.15),
                    radius: 10
                )
        )
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}

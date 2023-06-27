//
//  String.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 23/05/23.
//

import Foundation

extension String{
    var removingHTMLOccurances:String{
        return self.replacingOccurrences(of: "<[^>]+>", with:"",options:.regularExpression,range: nil)
    }
}

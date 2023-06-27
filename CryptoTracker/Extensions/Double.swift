//
//  Double.swift
//  CryptoTracker
//
//  Created by Varun Bagga on 01/04/23.
//

import Foundation

extension Double {
    ///Converts a double into currency with 2-6 decimal places
    ///  Convert
    private var currencyFormatter:NumberFormatter{
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
//        formatter.locale = .current
//        formatter.currencyCode = "usd"
//        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }
    
    func asCurrencyWith6Decimals()->String{
        let number = NSNumber(value: self)
        return currencyFormatter.string(from: number) ?? "$0.00"
    }
    
    func asNumberString() ->String {
        return String(format: "%.2f", self)
    }
    
    func asPrecentString()->String{
        return asNumberString() + "%";
    }
    func formattedWithAbbreviations() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "_": ""
        switch num {
        case 1_000_000_000_000...:
            let formatted = num / 1_000_000_000_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)Tr"
        case 1_000_000_000...:
            let formatted = num / 1_000_000_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)Bn"
        case 1_000_000...:
            let formatted = num / 1_000_000
            let stringFormatted = formatted.asNumberString()
            return "\(sign)\(stringFormatted)M"
        case 1_000...:
            let formatted = num / 1_000
            let stringFormatted = formatted.asNumberString ()
            return "\(sign)\(stringFormatted)K"
        case 0...:
            return self.asNumberString()
        default:
            return "\(sign)\(self)"
        }
    }
}

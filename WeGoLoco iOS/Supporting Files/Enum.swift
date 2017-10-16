//
//  Enum.swift
//  WeGoLoco iOS
//
//  Created by Dirk Hornung on 16/10/17.
//  Copyright © 2017 Dirk Hornung. All rights reserved.
//

import Foundation

// following https://stackoverflow.com/questions/24007461/how-to-enumerate-an-enum-with-string-type
// Example:
// enum Suit:String {
//    case Spades = "♠"
//    case Hearts = "♥"
//    case Diamonds = "♦"
//    case Clubs = "♣"
//}
//
//for f in iterateEnum(Suit) {
//    println(f.rawValue)
//}

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}


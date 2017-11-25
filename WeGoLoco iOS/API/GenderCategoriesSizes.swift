//
//  Categories.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import Foundation

// MARK: - Gender
enum Gender: String, Codable {
    case male = "male"
    case female = "female"
}

// MARK: - Categories
struct Categories {
    enum Category: String {
        case accessories = "Accessories"
        case blouses = "Blouses"
        case coats = "Coats"
        case dresses = "Dresses"
        case jeans = "Jeans"
        case shoes = "Shoes"
        case shorts = "Shorts"
        case shortsAndSkirts = "Shorts & Skirts"
        case sweaters = "Sweaters"
        case tShirtsAndPolos = "T-Shirts & Polos"
        case trousers = "Trousers"
        case trousersAndChinos = "Trousers & Chinos"
    }
    
    static var categories: [Gender: [Category]] = [
        .male : [
            .coats,
            .jeans,
            .shoes,
            .shorts,
            .sweaters,
            .tShirtsAndPolos,
            .trousersAndChinos
        ],
        .female : [
            .blouses,
            .coats,
            .dresses,
            .jeans,
            .shoes,
            .shortsAndSkirts,
            .sweaters,
            .trousers
        ]
    ]
    
    static func getCategoryfrom(name: String) -> Category {
        return Category(rawValue: name)!
    }
    
    static func getCategoriesFor(gender: Gender) -> [String] {
        var result = [String]()
        for category in self.categories[gender]! {
            result.append(category.rawValue)
        }
        return result
    }
}


// MARK: - Sizes
struct Sizes {
    static var sizes: [Gender : [Tinpon.Category : [Tinpon.Variation.Size]] ] = [
        .male : [
            .coats : doubleSizes(from: Array(stride(from: 28, through: 44, by: 1))),
            .jeans : doubleDoubleSizes( widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) ),
            .shoes : doubleSizes(from: Array(stride(from: 35, through: 50, by: 0.5)) ),
            .shorts : doubleSizes(from: Array(stride(from: 28, through: 44, by: 1)) ),
            .sweaters : stringSizes(from: ["XS", "S", "M", "L", "XL", "XXL"] ),
            .tShirtsAndPolos : stringSizes(from: ["XS", "S", "M", "L", "XL", "XXL"] ),
            .trousersAndChinos : doubleDoubleSizes(widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) )
        ],
        .female : [
            .coats : doubleSizes(from: Array(stride(from: 40, through: 78, by: 1)) ),
            .jeans : doubleDoubleSizes( widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) ),
            .shoes : doubleSizes(from: Array(stride(from: 35, through: 50, by: 0.5)) ),
            .sweaters : stringSizes(from: ["XS", "S", "M", "L", "XL", "XXL"] ),
            .trousers : doubleDoubleSizes( widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) )
        ]
    ]
    
    static func getSizesFor(gender: Gender, category: Tinpon.Category) -> [Tinpon.Variation.Size] {
        return self.sizes[gender]![category]!
    }
    
    // convert Array to Sizes
    private static func doubleSizes(from doubleArray: [Double]) -> [Tinpon.Variation.Size] {
        return doubleArray.map { Tinpon.Variation.Size.double($0) }
    }
    private static func doubleDoubleSizes(widths: [Double], lengths: [Double]) -> [Tinpon.Variation.Size] {
        var result = [Tinpon.Variation.Size]()
        for width in widths {
            for length in lengths {
                result.append(.doubleDouble(width, length))
            }
        }
        return result
    }
    private static func stringSizes(from stringArray: [String]) -> [Tinpon.Variation.Size] {
        return stringArray.map { Tinpon.Variation.Size.string($0) }
    }
}

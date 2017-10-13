//
//  Categories.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 18/8/17.
//
//

import Foundation

// MARK: - Gender
enum Gender: String {
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
            .accessories,
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
//Categories.getCategoriesFor(gender: .female)



// MARK: - Sizes
struct Sizes {
    enum Size {
        case StringSize([String])
        case DoubleSize([Double])
        // maps via a dictionary all possible lengths to very possible width
        case DoubleDoubleSize( [Double:[Double]] )
    }
    
    static var sizes: [Gender : [Categories.Category : Size] ] = [
        .male : [
            .coats : Size.DoubleSize( Array(stride(from: 40, through: 78, by: 1)) ),
            .jeans : initDoubleDoubleSizes(widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) ),
            .shoes : Size.DoubleSize( Array(stride(from: 35, through: 50, by: 0.5)) ),
            .shorts : Size.DoubleSize( Array(stride(from: 28, through: 44, by: 1)) ),
            .sweaters : Size.StringSize( ["XS", "S", "M", "L", "XL", "XXL"] ),
            .tShirtsAndPolos : Size.StringSize( ["XS", "S", "M", "L", "XL", "XXL"] ),
            .trousersAndChinos : initDoubleDoubleSizes(widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) )
        ],
        .female : [
            .coats : Size.DoubleSize( Array(stride(from: 40, through: 78, by: 1)) ),
            .jeans : initDoubleDoubleSizes(widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) ),
            .shoes : Size.DoubleSize( Array(stride(from: 35, through: 50, by: 0.5)) ),
            .sweaters : Size.StringSize( ["XS", "S", "M", "L", "XL", "XXL"] ),
            .trousers : initDoubleDoubleSizes(widths: Array(stride(from: 28, through: 44, by: 1)), lengths: Array(stride(from: 30, through: 36, by: 1)) )
        ]
    ]
    
    static func getSizesFor(gender: Gender, category: Categories.Category) -> Size {
        return self.sizes[gender]![category]!
    }
    
    // inits Double-Double size dictionary, which maps all possible lengths to every possible width
    private static func initDoubleDoubleSizes(widths: [Double], lengths: [Double]) -> Size {
        var result = [Double:[Double]]()
        for width in widths {
            result[width] = lengths
        }
        return Size.DoubleDoubleSize(result)
    }
}

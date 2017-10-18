//
//  Tinpon.swift
//  Tinpons
//
//  Created by Dirk Hornung on 31/7/17.
//
//

import Foundation
import IGListKit

import UIKit

// MARK: - Tinpon
class Tinpon: Codable {
    enum Category: String, Codable {
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
    struct Variation: Codable {
        enum Color: String, Codable {
            case multicolor, black, blue, brown, cyan, green, grey, magenta, orange, purple, red, yellow, white
            static let colorDictionary = ["multicolor" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "black" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "blue" : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), "brown" : #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), "cyan" : #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), "green" : #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), "grey" : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), "magenta" : #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1), "orange" : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), "purple" : #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), "red" : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), "yellow" : #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), "white": #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)]
        }
        enum Size {
            case string(String)
            case double(Double)
            case doubleDouble(Double, Double)
        }

        var color: Color
        var size: Size
        var quantity: Int
    }

    var category: Category?
    var gender: Gender?
    var id: Int?
    var name: String?
    var price: Double?
    var variations: [Variation]?

}

// MARK: - TinponImages

struct TinponImages {
    var main = [UIImage]()
}


// following http://proxpero.com/2017/07/11/encoding-and-decoding-custom-enums-with-associated-values-in-swift-4/
extension Tinpon.Variation.Size: Codable {
    private enum CodingKeys: String, CodingKey {
        case double
        case doubleDouble
        case string
    }
    enum CodingError: Error {
        case decoding(String)
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let code = try? values.decode(Double.self, forKey: .double) {
            self = .double(code)
            return
        }
        if let codes = try? values.decode(Array<Double>.self, forKey: .doubleDouble), codes.count == 2 {
            self = .doubleDouble(codes[0], codes[1])
            return
        }
        if let code = try? values.decode(String.self, forKey: .string) {
            self = .string(code)
            return
        }
        throw CodingError.decoding("Decoding Error: \(dump(values))")
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .double(let size):
            try container.encode(size, forKey: .double)
        case .doubleDouble(let width, let height):
            try container.encode([width, height], forKey: .doubleDouble)
        case .string(let size):
            try container.encode(size, forKey: .string)
        }
    }
}

// compare two Tinpon.Variation.Sizes'
// following https://stackoverflow.com/questions/24339807/how-to-test-equality-of-swift-enums-with-associated-values
func ==(lhs: Tinpon.Variation.Size, rhs: Tinpon.Variation.Size) -> Bool {
    switch (lhs, rhs) {
    case let (.double(a), .double(b)):
        return a == b
    case let (.string(a), .string(b)):
        return a == b
    case let (.doubleDouble(a1,a2), .doubleDouble(b1,b2)):
        return a1 == b1 && a2 == b2
    default:
        return false
    }
}


//struct ColorVariation {
//    var sizeVariations = [SizeVariation]()
//    var images = [TinponImage]()
//}
//
//struct SizeVariation {
//    var size: String
//    var quantity: Int
//}
//
//struct TinponImage {
//    var image: UIImage
//    var id: String
//    init(image: UIImage) {
//        self.image = image
//        self.id = UUID().uuidString
//    }
//}
//
//struct Tinpon {
//    var id: Int?
//    var active: Bool?
//    var category: Categories.Category?
//    var createdAt: Date?
//    var gender: Gender?
//    var imgUrl: String?
//    var latitude: Double?
//    var longitude: Double?
//    var name: String?
//    var price: Double?
//    var updatedAt: Date?
//    var userId: String?
//    var images = [UIImage]()
//    var productVariations = [Color : ColorVariation]()
//
//    // temporary for addProduct
//    var sizes: Sizes.Size?
//    var colors = [Color]()
//
//    var mainImageCount: Int?
//
//    var description: String {
//        return "id: \(id ?? 0)\n name: \(self.name ?? "nil")\n gender: \(self.gender?.rawValue ?? "nil")\n price: \(self.price ?? 0.00)\n mainImages: \(images.count)"
//    }
//
//    init() {}
//
//    init(testing: Bool) {
//        if testing {
//            self.name = "THis IS the Tinpon"
//            self.category = .jeans
//            self.price = 49.99
//
//            let blackColor = Color(spanishName: "negro")
//            let redColor = Color(spanishName: "rojo")
//            let sizeVariation = SizeVariation(size: "M", quantity: 1000)
//            let sizeVariations = [sizeVariation, sizeVariation]
//            let colorVariation = ColorVariation(sizeVariations: sizeVariations, images: [])
//            self.productVariations = [blackColor : colorVariation, redColor : colorVariation]
//
//        }
//    }
//}



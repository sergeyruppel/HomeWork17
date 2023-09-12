//
//  RandomUIColorExtension.swift
//  ColorPicker
//
//  Created by Sergey Ruppel on 07.09.2023.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

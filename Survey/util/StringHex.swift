//
//  StringHex.swift
//  Survey
//
//  Created by Qinjia Huang on 10/21/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import Swift

extension String {
    var hexa2Bytes: [UInt8] {
        let hexa = Array(characters)
        return stride(from: 0, to: characters.count, by: 2).flatMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
}

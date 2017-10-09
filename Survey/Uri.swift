//
//  Uri.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Uri: NSObject {
    static func encode(content: String) -> String{
        return content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

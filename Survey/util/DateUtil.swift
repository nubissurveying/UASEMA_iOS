//
//  DateUtil.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class DateUtil: NSObject {
    public static func stringifyAll(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.string(from: calendar)
    }
    public static func stringifyAllAlt(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: calendar)
    }
    public static func stringifyTime(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "kk:mm"
        return dateFormatter.string(from: calendar)
    }
    public static func stringifyDate( calendar : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: calendar)
    }
    
    public static func dateAll(calendar : String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return dateFormatter.date(from: calendar)
    }
    public static func dateTime(calendar : String) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "kk:mm"
        return dateFormatter.date(from: calendar)
    }
    public static func dateDate( calendar : String) -> Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: calendar)
    }
}

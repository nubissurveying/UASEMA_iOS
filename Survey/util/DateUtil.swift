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
    
    public static func stringifyHuman(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a, MMMM dd"
        return dateFormatter.string(from: calendar)
    }
    
    public static func stringifyHumanTime(calendar : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
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
    
    public static func stringifyDateUntilHour( calendar : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHH"
        return dateFormatter.string(from: calendar)
    }
    
    public static func stringifyDateUntilMin( calendar : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
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

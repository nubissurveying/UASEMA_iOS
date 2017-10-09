//
//  Survey.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Survey: NSObject {
    private var requestCode : Int;
    private var date : Date;
    private var taken : Bool;
    private var closed : Bool;
    
    init( requestCode : Int, date :Date) {
        self.requestCode = requestCode;
        self.date = date;
        self.taken = false;
        self.closed = false;
    }
    
    public func toString() -> String {
        var res = "Code: " + String(requestCode)
        res += " Taken: " + String(isTaken()) + " closed: "
        res += String(closed) + " Date: " + DateUtil.stringifyAll(calendar: date)
        return res
    }
    
    public func getRequestCode() -> Int{
    return requestCode;
    }
    
    public func getDate() -> Date{
    return date;
    }
    
    public func setAsTaken(){
    self.taken = true;
    }
    
    public func isTaken() -> Bool{
    return taken;
    }
    
    public func setClosed(){
    self.closed = true;
    }
    
    public func isClosed() ->Bool{
    return closed;
    }
    
    
    public static func getSurveyCode(requestCode : Int) -> Int{
    return requestCode - (requestCode % 3);
    }
}

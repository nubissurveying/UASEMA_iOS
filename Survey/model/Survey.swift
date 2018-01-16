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
    private var alarmed : Bool
    
    init( requestCode : Int, date :Date) {
        self.requestCode = requestCode;
        self.date = date;
        self.taken = false;
        self.closed = false;
        self.alarmed = false
    }
    
    public func toString() -> String {
        var res = "Code: " + String(requestCode)
        res += " Alarmed: " + String(getAlarmed())
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
    public func setAlarmed(){
        print(getRequestCode() ,"is alarmed")
        self.alarmed = true;
    }
    public func getAlarmed() -> Bool{
        return self.alarmed
    }
    public func setAsTaken(){
        print(getRequestCode() ,"is taken")
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
    public static func getSuveryFromString(input: String) -> Survey{
        
        let argus = input.split(separator: " ")
//                print(argus)
        
        let res = Survey(requestCode: Int(argus[1])!, date: DateUtil.dateAll(calendar: String(argus[9]) + " " + String(argus[10]))!)
        if(argus[3] == "true") {res.setAlarmed()}
        if(argus[5] == "true") {res.setAsTaken()}
        if(argus[7] == "true") {res.setClosed()}
        return res;
    }
    public static func updateClosed(settings : Settings){
        let limit = (Double)(Constants.TIME_TO_TAKE_SURVEY + 1) * 60;
        for sur in settings.getSurveys(){
            let cur = sur.getDate().timeIntervalSinceNow
            print(sur.getRequestCode(), " ", cur)
            if (cur + limit < 0) {
                print(sur.getRequestCode() ,"is closed")
                sur.setClosed()
            }
        }
    }
    
}


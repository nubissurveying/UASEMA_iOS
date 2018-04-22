//
//  UrlBuilder.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class UrlBuilder: NSObject {
    public static let
    DOWNLOAD = "download",
    DOWNLOAD_APP = "download.app",
    NO_INIT = "noinit",                         //  Used
    OTHER_DAY = "other.day",
    OTHER_DAY_RES = "other.day.res",
    OTHERDAY = "otherday",
    OTHERDAY_RES = "otherday.res",
    PARTICIPATE = "participate",
    PARTICIPATE_RES = "participate.res",
    PHONE_ALARM = "phone.alarm",                //  Shows alarm if rtid != null
    PHONE_DEMO = "phone.demo",                  //  Demo (Different with testing?)
    PHONE_INIT_NODATE = "phone.init.nodate",    //  Prevent
    PHONE_INIT_NOID = "phone.init.noid",        //  Prevent
    PHONE_LOGIN_RES = "phone.login.res",
    PHONE_NOREACTION = "phone.noreaction",      //  Passed: Selected time and date passed
    PHONE_OPTOUT = "phone.optout",              //  Opt out
    PHONE_START = "phone.start",                //  Start: Used if no user
    PHONE_LOGOUT = "logout",
    PHONE_NOALARMS = "noalarmsset",
    SENDMAIL = "sendmail",
    SETTINGS_CHANGE = "settings.change",        //  Used for block_between, passed, (master)
    TEST = "test",
    TEST_MODE = "testmode",                     //  Testing
    VIDEO_BEEP_MESSAGE = "video.beepmessage";   //  Default?
    
    public static let
    TIME_FIRST = "&first=1",
    TIME_MIDDLE = "&middle=1",
    TIME_LAST = "&last=1";
    
    private static func buildParams(page : String, settings : Settings, now : Date, reportTo : String) -> String{
        let dic = Bundle.main.infoDictionary!
        let buildNumber = dic["CFBundleShortVersionString"]! as! String
        return "&rtid=" + (settings.getRtid() == nil ? "" : Uri.encode(content: settings.getRtid()!)) +
    "&language=" + "en" +
    "&device=" + "iOS" +
    "&email=" +
            "&selecteddate=" + DateUtil.stringifyDate(calendar: settings.getbeginTime()) +    //  Not encoded?
            "&date=" + Uri.encode(content: DateUtil.stringifyAllAlt(calendar: now)) +
            "&starttime=" + Uri.encode(content: DateUtil.stringifyTime(calendar: settings.getbeginTime())) +
            "&endtime=" + Uri.encode(content: DateUtil.stringifyTime(calendar: settings.getEndTime())) +
            "&respondingto=" + reportTo + "&version=" + buildNumber + 
            "&pinginfo=" + (page == PHONE_ALARM ? Uri.encode(content: settings.alarmTags()) : "")
    }
    
    private static let baseURL = Constants.baseURL
    
    public static func build(page : String,  settings : Settings, now : Date, includeParams : Bool) -> String{
        let response = baseURL + "?ema=1&p=" + page + (includeParams ? buildParams(page: page, settings: settings, now: now, reportTo: "") : "");
//    LogUtil.e("TT", "UrlBuilder => build() == " + response);
        print(response)
    return response;
    }
    
    public static func build(page : String,  settings : Settings, now : Date, includeParams : Bool, reportTo : String) -> String{
        let response = baseURL + "?ema=1&p=" + page + (includeParams ? buildParams(page: page, settings: settings, now: now, reportTo: reportTo) : "");
        //    LogUtil.e("TT", "UrlBuilder => build() == " + response);
        print(response)
        return response;
    }
}

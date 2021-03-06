//
//  Constants.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Constants: NSObject {
    public static var isDemo = false
    public static let SETTINGSDEFAULT = "UASEma"
    let defaults = UserDefaults.standard
    public static let loggedInKey = "UASEmaloggedInKey"
    public static let rtidKey  = "UASEmartidKey"
    public static let beginTimeKey = "UASEmabeginTimeKey"
    public static let endTimeKey = "UASEmaendTimeKey"
    public static let surveysKey = "UASEmasurveysKey"
    public static let setAtTimeKey = "UASEmasetAtTimeKey"
    public static let NotificationsTimeKey = "NotificationsTimeKey"
    public static let AccelrecordingKey = "AccelrecordingKey"
    public static let VideorecordingKey = "VideorecordingKey"
    public static let TimeToReminderKey = "TimeToReminderKey"
    public static let TimeToTakeSurveyKey = "TimeToTakeSurveyKey"
    
    public static let CookieNameKey = "CookieNameKey"
    public static let CookieValueKey = "CookieValueKey"
    public static let CookieDomainKey = "CookieDomainKey"
    public static let CookiePathKey = "CookiePathKey"
    public static let CookieSOKey = "CookieSOKey"
    public static let CookieSKey = "CookieSKey"
    public static let CookieName = "PHPSESSION"
    public static let CookieDomain = "uas.usc.edu"
    public static let CookiePath = "/survey/uas/ema/daily"
    
    public static let CategoryName = "survey.steps"
    public static let notificationActionDo = "do.survey.action"
    public static let notificationActionIgnore = "ignore.action"
    
    public static let notificationLimit = 10;
    //    public static int TIME_BETWEEN_SURVEYS_PRO = 45;
    public static var TIME_BETWEEN_SURVEYS_PRO = 90;
    private static var TIME_TO_TAKE_SURVEY_PRO = 15;     //was 8
    private static var TIME_TO_REMINDER_PRO = 6;
    
    public static let TIME_BETWEEN_SURVEYS_DEV = 7;
    private static let TIME_TO_TAKE_SURVEY_DEV = 2;
    private static let TIME_TO_REMINDER_DEV = 1;
    
    public static var TIME_TO_TAKE_SURVEY = isDemo ? TIME_TO_TAKE_SURVEY_DEV : TIME_TO_TAKE_SURVEY_PRO;
    public static var TIME_TO_REMINDER = isDemo ? TIME_TO_REMINDER_DEV : TIME_TO_REMINDER_PRO;
    public static var baseURL = "https://uas.usc.edu/survey/uas/ema/daily/index.php";
//    public static var baseURL = "http://127.0.0.1/ema/index.php";
    
    public static var videoMaximumDuration = 240
    public static var audioMaximumDuration = 240
    public static var audioMinimumDuration = 10
    public static let VIDEO = "video"
    public static let SOUNDRECORDING = "soundrecording"
    public static let VIDEO_URL = "https://survey.usc.edu/ptus/index.php?p=showvideo"
    
    public static func setTimeToTakeSurvey(time: Int){
        self.TIME_TO_TAKE_SURVEY = time
    }
    
    public static func setTimeToReminder(time: Int){
        self.TIME_TO_REMINDER = time
    }
   
}

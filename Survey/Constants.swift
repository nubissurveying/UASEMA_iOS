//
//  Constants.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Constants: NSObject {
    public static var isDemo = true;
    public static let SETTINGSDEFAULT = "UASEma"
    let defaults = UserDefaults.standard
    public static let loggedInKey = "UASEmaloggedInKey"
    public static let rtidKey  = "UASEmartidKey"
    public static let beginTimeKey = "UASEmabeginTimeKey"
    public static let endTimeKey = "UASEmaendTimeKey"
    public static let surveysKey = "UASEmasurveysKey"
    public static let setAtTimeKey = "UASEmasetAtTimeKey"
    
    public static let notificationLimit = 10;
    //    public static int TIME_BETWEEN_SURVEYS_PRO = 45;
    public static var TIME_BETWEEN_SURVEYS_PRO = 90;
    private static var TIME_TO_TAKE_SURVEY_PRO = 15;     //was 8
    private static var TIME_TO_REMINDER_PRO = 6;
    
    public static let TIME_BETWEEN_SURVEYS_DEV = 10;
    private static let TIME_TO_TAKE_SURVEY_DEV = 2;
    private static let TIME_TO_REMINDER_DEV = 1;
    
    public static let TIME_TO_TAKE_SURVEY = isDemo ? TIME_TO_TAKE_SURVEY_DEV : TIME_TO_TAKE_SURVEY_PRO;
    public static let TIME_TO_REMINDER = isDemo ? TIME_TO_REMINDER_DEV : TIME_TO_REMINDER_PRO;
}

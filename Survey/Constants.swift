//
//  Constants.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Constants: NSObject {
    public static var isDemo = false;
    
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

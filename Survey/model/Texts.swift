//
//  Texts.swift
//  Survey
//
//  Created by Qinjia Huang on 4/15/18.
//  Copyright © 2018 Qinjia Huang. All rights reserved.
//

import UIKit
import SwiftyJSON

class Texts: NSObject {
    var menuContents = ["管理员","刷新","录音","技术问题","登出"]
    var notificationContents = ["调查问卷准备好了"]
    
    private static let NOTIFICATION_KEY = "notification"
    private static let MENU_KEY = "menu"
    
    enum MenuContent : Int{
        case Admin = 0
        case Refresh = 1
        case SoundRecording = 2
        case TechIssue = 3
        case Logout = 4
    }
    enum NotificationContent : Int{
        case title = 0
        
    }
    
    override init() {
        let defaults = UserDefaults.standard
        if let checkMenu  = defaults.object(forKey: "menu"){
            menuContents = checkMenu as! [String]
        }
        if let checknotification  = defaults.object(forKey: "notification"){
            notificationContents = checknotification as! [String]
        }
    }
    
    func getMenuText(menuType : MenuContent) -> String {
        if(menuType.rawValue < menuContents.count){
            return menuContents[menuType.rawValue]
        }
        else {
            return "menuType error"
        }
        
    }
    func getNotification(notificationType : NotificationContent) -> String {
        if(notificationType.rawValue < notificationContents.count){
            return notificationContents[notificationType.rawValue]
        } else {
            return "notificationType error"
        }
    }
    
    static func updateTextsSettings(json: JSON){
        print("Texts",json)
        let defaults = UserDefaults.standard
        var notificationTemp = [String]()
        var menuTemp = [String]()
        for jsonString in json[NOTIFICATION_KEY].arrayValue {
            notificationTemp.append(jsonString.stringValue)
        }
        for jsonString in json[MENU_KEY].arrayValue {
            menuTemp.append(jsonString.stringValue)
        }
        defaults.set(notificationTemp, forKey: NOTIFICATION_KEY)
        defaults.set(menuTemp, forKey: MENU_KEY)

    }
    
}

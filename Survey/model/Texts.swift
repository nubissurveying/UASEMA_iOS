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
    var menuContents = ["Admin","Refresh","Sound recording","Technical issue","Logout","Menu","Cancel","Please Enter the admin password"]
    var notificationContents = ["Survey is ready", "No need to click after "]
    var toast = ["Logout", "Wrong password", "Please login first"]
    var recording = ["Press the microphone button to start recording. Press the button again to stop and save.",
                     "After recording is done, you can save the recording. You can also start over with a new recording by pressing the microphone button again.",
                     "Make sure your video is longer then 10s and less then 4min. After recording, click use video to save and upload in recording result screen."]
    
    private static let NOTIFICATION_KEY = "notification"
    private static let MENU_KEY = "menu"
    private static let TOAST_KEY = "toast"
    private static let RECORDING_KEY = "recording"
    
    enum MenuContent : Int{
        case Admin = 0
        case Refresh = 1
        case SoundRecording = 2
        case TechIssue = 3
        case Logout = 4
        case Menu = 5
        case Cancel = 6
        case AdminPassword = 7
    }
    enum NotificationContent : Int{
        case title = 0
        case body = 1
    }
    enum ToastContent : Int{
        case Logout = 0
        case WrongPassword = 1
        case LoginAlert = 2
    }
    enum RecordContent : Int{
        case audioRecordInstruction = 0
        case audioSaveUpload = 1
        case videoInstruction = 2
    }
    
    override init() {
        let defaults = UserDefaults.standard
        if let checkMenu  = defaults.object(forKey: "menu"){
            menuContents = checkMenu as! [String]
        }
        if let checknotification  = defaults.object(forKey: "notification"){
            notificationContents = checknotification as! [String]
        }
        if let checknotification  = defaults.object(forKey: "toast"){
            toast = checknotification as! [String]
        }
        if let checknotification  = defaults.object(forKey: "recording"){
            recording = checknotification as! [String]
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
    
    func getToast(toastType: ToastContent) -> String {
        if(toastType.rawValue < toast.count){
            return toast[toastType.rawValue]
        } else {
            return "toastType error"
        }
    }
    func getRecording(recordingType : RecordContent) -> String {
        if(recordingType.rawValue < recording.count){
            return recording[recordingType.rawValue]
        } else {
            return "recordingType error"
        }
    }
    
    static func updateTextsSettings(json: JSON){
        print("Texts",json)
        let defaults = UserDefaults.standard
        var notificationTemp = [String]()
        var menuTemp = [String]()
        var toastTemp = [String]()
        var recordingTemp = [String]()
        for jsonString in json[NOTIFICATION_KEY].arrayValue {
            notificationTemp.append(jsonString.stringValue)
            defaults.set(notificationTemp, forKey: NOTIFICATION_KEY)
        }
        for jsonString in json[MENU_KEY].arrayValue {
            menuTemp.append(jsonString.stringValue)
            defaults.set(menuTemp, forKey: MENU_KEY)
        }
        for jsonString in json[TOAST_KEY].arrayValue{
            toastTemp.append(jsonString.stringValue)
            defaults.set(toastTemp, forKey: TOAST_KEY)
        }
        for jsonString in json[RECORDING_KEY].arrayValue{
            recordingTemp.append(jsonString.stringValue)
            defaults.set(recordingTemp, forKey: RECORDING_KEY)
        }

    }
    static func clearTexts(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: NOTIFICATION_KEY)
        defaults.removeObject(forKey: MENU_KEY)
        defaults.removeObject(forKey: TOAST_KEY)
        defaults.removeObject(forKey: RECORDING_KEY)
    }
    
}

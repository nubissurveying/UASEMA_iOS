//
//  Notification.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import UserNotifications


class Notification: NSObject {
    
    
    
    static func setNotification() -> Int{
        
        let center = UNUserNotificationCenter.current()
        
        let defaults = UserDefaults.standard
        let current = Date()
        var count = 0
        var toBeAdd = [Survey]()
        center.removeAllPendingNotificationRequests()
        if(defaults.object(forKey: Constants.surveysKey) == nil){
            return 0
        }
        let settings = Settings.getSettingFromDefault()
        print("set notification time to reminder", settings.gettimeToReminder())
        print("set notification time to take survey", settings.gettimeToTakeSurvey())
        if defaults.string(forKey: Constants.surveysKey) != "null"{
//            let surveysString = defaults.string(forKey: Constants.surveysKey)
//            let surveyArray = surveysString?.split(separator: "\n")
//
//            var surveys = [Survey]()
//            for str in surveyArray! {
//                surveys.append(Survey.getSuveryFromString(input:String(str)))
//            }
            
            // pick serveal surveys to add notification
            let settings = Settings.getSettingFromDefault()
            for sur in settings.getSurveys(){
                if(sur.getDate() < current) {
                    continue
                }
                count += 1
                if(count > Constants.notificationLimit) {
                    break;
                }
                
                toBeAdd.append(sur)
                
                
            }
            let texts = Texts()
            for sur in toBeAdd.reversed(){

                let content = UNMutableNotificationContent()
                let content2 = UNMutableNotificationContent()
                let first = sur.getDate()
                let second = Calendar.current.date(byAdding: .minute, value: settings.gettimeToReminder(), to: first)
                let third = Calendar.current.date(byAdding: .minute, value: settings.gettimeToTakeSurvey() , to: first)
                print("setNotification", DateUtil.stringifyAll(calendar: first), DateUtil.stringifyAll(calendar: second!), "\(settings.gettimeToReminder())")
                
                content.title = texts.getNotification(notificationType: .title) + " " + DateUtil.stringifyTime(calendar: first)
                content.body = texts.getNotification(notificationType: .body) + DateUtil.stringifyHuman(calendar: third!)
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = Constants.CategoryName
                // Deliver the notification in five seconds.
                
                var date = DateComponents()
                date.second = Calendar.current.component(.second, from: first)
                date.hour = Calendar.current.component(.hour, from: first)
                date.minute = Calendar.current.component(.minute, from: first)
                date.day = Calendar.current.component(.day, from: first)
                date.month = Calendar.current.component(.month, from: first)
                date.year = Calendar.current.component(.year, from: first)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                //            let trigger = UNCalendarNotificationTrigger(dateMatching: firstComp, repeats: false)
                let request = UNNotificationRequest.init(identifier: DateUtil.stringifyAll(calendar: first), content: content, trigger: trigger)
                
                content2.title = texts.getNotification(notificationType: .title) + " " + DateUtil.stringifyTime(calendar: second!)
                content2.body = texts.getNotification(notificationType: .body) + DateUtil.stringifyHuman(calendar: third!)
                content2.sound = UNNotificationSound.default()
                content2.categoryIdentifier = Constants.CategoryName
                // Deliver the notification in five seconds.
                date = DateComponents()
                date.second = Calendar.current.component(.second, from: second!)
                date.hour = Calendar.current.component(.hour, from: second!)
                date.minute = Calendar.current.component(.minute, from: second!)
                date.day = Calendar.current.component(.day, from: second!)
                date.month = Calendar.current.component(.month, from: second!)
                date.year = Calendar.current.component(.year, from: second!)
                let trigger2 = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                let request2 = UNNotificationRequest.init(identifier: DateUtil.stringifyAll(calendar: second!), content: content2, trigger: trigger2)
                // Schedule the notification.
                
                
                
                center.add(request2, withCompletionHandler:nil)
                center.add(request,withCompletionHandler: nil)
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
                var message = ""
                message += "\(requests.count) requests ------- \n"
                for request in requests.reversed(){
                    message += request.identifier + "\n"
                }
                UserDefaults.standard.set(message, forKey: Constants.NotificationsTimeKey)
            })
            print( count * 2 , "notificaitons should have been added")
        }
        
        
        
        


        
        
        return count;
    }
    static func removeNotification(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
//        center.removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            var message = ""
            message += "\(requests.count) requests ------- \n"
            for request in requests.reversed(){
                message += request.identifier + "\n"
            }
            UserDefaults.standard.set(message, forKey: Constants.NotificationsTimeKey)
            
        })
        
    }
    static func showNotificaiton(){
        
        print("here to print notificiaotn")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("\(requests.count) requests -------")
            for request in requests.reversed(){
                print(request.trigger!)
            }
        })
        
    }
    static func removeDeliveredNotification(){
        let center = UNUserNotificationCenter.current()
        
        
        center.removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            var message = ""
            message += "\(requests.count) requests ------- \n"
            for request in requests{
                message += request.identifier + "\n"
            }
            UserDefaults.standard.set(message, forKey: Constants.NotificationsTimeKey)
            
        })
        
    }
    static func removeNotificationForASurvey(SurveyDate: Date!){
        if(SurveyDate == nil){
            return ;
        }
        let center = UNUserNotificationCenter.current()
        var ids = [String]()
        let first = SurveyDate
        let settings = Settings.getSettingFromDefault()
        let second = Calendar.current.date(byAdding: .minute, value: settings.gettimeToReminder(), to: first!)
        ids.append(DateUtil.stringifyAll(calendar: first!))
        ids.append(DateUtil.stringifyAll(calendar: second!))
        center.removePendingNotificationRequests(withIdentifiers: ids)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            var message = ""
            message += "\(requests.count) requests ------- \n"
            for request in requests{
                message += request.identifier + "\n"
            }
            UserDefaults.standard.set(message, forKey: Constants.NotificationsTimeKey)
            
        })
        
    }

}

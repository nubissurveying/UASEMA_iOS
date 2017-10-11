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
        if(defaults.object(forKey: Constants.surveysKey) == nil){
            return 0
        }
        let surveysString = defaults.string(forKey: Constants.surveysKey)
        let surveyArray = surveysString?.split(separator: "\n")
        var surveys = [Survey]()
        for str in surveyArray! {
            surveys.append(Survey.getSuveryFromString(input:String(str)))
        }
        
        
        
        let current = Date()
        var count = 0
        for sur in surveys{
            if(sur.getDate() < current) {
                continue
            }
            count += 1
            if(count > Constants.notificationLimit) {
                break;
            }
            let content = UNMutableNotificationContent()
            let content2 = UNMutableNotificationContent()
            let first = sur.getDate()
            let second = Calendar.current.date(byAdding: .minute, value: 1, to: first)
            
            content.title = "Survey is Ready"
            content.body = "Survey is for" + DateUtil.stringifyTime(calendar: first)
            content.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            
            var date = DateComponents()
            date.hour = Calendar.current.component(.hour, from: first)
            date.minute = Calendar.current.component(.hour, from: first)
            date.day = Calendar.current.component(.day, from: first)
            date.month = Calendar.current.component(.month, from: first)
            date.year = Calendar.current.component(.year, from: first)
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: firstComp, repeats: false)
            let request = UNNotificationRequest.init(identifier: DateUtil.stringifyAll(calendar: first), content: content, trigger: trigger)
            // Schedule the notification.
            
            center.add(request,withCompletionHandler: nil)
            
            
            content2.title = "Survey is Ready"
            content2.body = "Survey is for" + DateUtil.stringifyTime(calendar: second!)
            content2.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            date = DateComponents()
            date.hour = Calendar.current.component(.hour, from: second!)
            date.minute = Calendar.current.component(.hour, from: second!)
            date.day = Calendar.current.component(.day, from: second!)
            date.month = Calendar.current.component(.month, from: second!)
            date.year = Calendar.current.component(.year, from: second!)
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            let request2 = UNNotificationRequest.init(identifier: DateUtil.stringifyAll(calendar: second!), content: content2, trigger: trigger2)
            // Schedule the notification.
            center.add(request2, withCompletionHandler: nil)
            
            
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
                var message = ""
                message += "\(requests.count) requests ------- \n"
                for request in requests{
                    message += request.identifier + "\n"
                }
                UserDefaults.standard.set(message, forKey: Constants.NotificationsTimeKey)
            })
            
        }
        print( count * 2 , "notificaitons should have been added")
        
        
        return count;
    }
    static func removeNotification(ids: [String]){
        let center = UNUserNotificationCenter.current()
//        print(ids)
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
    static func showNotificaiton(){
        
        print("here to print notificiaotn")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("\(requests.count) requests -------")
            for request in requests{
                print(request.identifier)
            }
        })
        
    }

}

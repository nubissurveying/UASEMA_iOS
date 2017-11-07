//
//  ViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import SwiftSpinner
import EasyToast
import SystemConfiguration
import Foundation
import UserNotifications
import WebKit

class ViewController: UIViewController , WKNavigationDelegate, UNUserNotificationCenterDelegate{

    var myWebView : WKWebView!
    private var settings : Settings = Settings();

    private var hasInternet = true;
    private var defaults = UserDefaults.standard

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        
        
        // init wkwebview
        setWKWebview()
//        myWebView.delegate = self
        
        // set notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // set title
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        let options = UIBarButtonItem.init(image: UIImage.init(named: "options"), style: .plain, target: self, action: #selector(self.showOptions))
        self.navigationItem.setRightBarButton(options, animated: true)

        
    }
    func setWKWebview(){
        let userContentController = WKUserContentController()
        let center = UserDefaults.standard
        if center.object(forKey: Constants.CookieValueKey) != nil{
            var cookieString = center.string(forKey: Constants.CookieValueKey)!
            cookieString = cookieString.replacingOccurrences(of: "(", with: "")
            cookieString = cookieString.replacingOccurrences(of: ")", with: "")
            cookieString = cookieString.replacingOccurrences(of: "Optional", with: "")
            cookieString = cookieString.replacingOccurrences(of: " ", with: "")
            let cookieWillBeInject = "document.cookie = \"" + cookieString + "\""
            print("wkwebview injected script content ", cookieWillBeInject)
            let cookieScript : WKUserScript = WKUserScript(source: cookieWillBeInject, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false )
            userContentController.addUserScript(cookieScript)
            print("wkwebview injected script ", cookieScript.debugDescription)
        }
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        print("wkwibview configuration ", configuration.debugDescription)
        myWebView = WKWebView(frame : CGRect(x: 0, y: 0, width: view.frame.width, height:view.frame.height),configuration: configuration)
        view.addSubview(myWebView)
        myWebView.navigationDelegate = self
    }
    
    @objc func applicationWillEnterForeground(notification: NSNotification) {
        print("did enter foreground")
        SwiftSpinner.show("Loading from notification...")
        settings = Settings.getSettingFromDefault()
        print("internet is :", isInternetAvailable())
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        route(settings: settings, now: Date())

    }
    override func viewWillAppear(_ animated: Bool) {
        SwiftSpinner.show("Loading...")
        settings = Settings.getSettingFromDefault()

        print("internet is :", isInternetAvailable())
        
        route(settings: settings, now: Date())
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    @IBOutlet weak var routeCondition: UILabel!
    func route(settings: Settings, now : Date){
        
        print("here comes route")
        //  User is logged in and during survey

        print("should show survey ",settings.shouldShowSurvey(calendar: now))
        if(settings.isLoggedIn() && settings.allFieldsSet() && settings.shouldShowSurvey(calendar: now)) {

            print("route comes to User is logged in and during survey")
            let survey = settings.getSurveyByTime(now: now);
            
            if(survey != nil) {
                Notification.removeNotificationForASurvey(SurveyDate: (survey?.getDate())!)
            }
            let requestCode = (survey == nil) ? -1: survey?.getRequestCode()
            var timeTag = (requestCode == -1) ? "":settings.getTimeTag(requestCode: requestCode!)
            if(timeTag == nil) {timeTag = ""}
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_ALARM, settings: settings, now: now, includeParams: true) + timeTag!)

//            self.view.showToast("Survey start", position: .bottom, popTime: 3, dismissOnTap: false)
            //  User is logged in, is not during survey, and has not skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
            print("route comes to User is logged in, is not during survey, and has not skipped previous")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_START, settings: settings, now: now, includeParams: true));
//            self.view.showToast("not in survey, not skip", position: .bottom, popTime: 3, dismissOnTap: false)

            //  User is logged in, but has skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && settings.skippedPrevious(now: now)){
            print("route comes to User is logged in, but has skipped previous")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOREACTION, settings: settings, now: now, includeParams: true));
//            self.view.showToast("skip", position: .bottom, popTime: 3, dismissOnTap: false)

            //  UserId set from APK; is logged in, but has no start and end times;
        } else if (settings.isLoggedIn() && !settings.allFieldsSet()){
            print("route comes to UserId set from APK; is logged in, but has no start and end times;")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_INIT_NODATE, settings: settings, now: now,  includeParams: true));
//            self.view.showToast("login no start and end", position: .bottom, popTime: 3, dismissOnTap: false)
            
            //  No user; either opted out, or started with APK with no RTID
        } else if (!settings.isLoggedIn()) {
            print("route comes to No user; either opted out, or started with APK with no RTID")
            showWebView(url: UrlBuilder.build(page: "testandroid", settings: settings, now: now,  includeParams: false));
            //showWebView(UrlBuilder.build(UrlBuilder.PHONE_START, settings, now,  false));
//            self.view.showToast("not login", position: .bottom, popTime: 3, dismissOnTap: false)
        }
    }
    func showWebView(url: String) {
        
        print(url)
        let urlrequest = URL(string: url)
        if(isInternetAvailable()){
            var request = URLRequest(url: urlrequest!)
//            let cookies = HTTPCookieStorage.shared.cookies
            print("in showWebView " , getCookie())
            request.setValue(getCookie(), forHTTPHeaderField: "Cookie")
//            request.httpShouldHandleCookies = false
            myWebView.load(request)
            
            
        } else{
            let noInternet = "<html><body><h3><font face=arial color=#5691ea>" +  "No internet connection detected. Make sure you are connected to the cellular network or wifi." + "</font></h3></body></html>"
            
            myWebView.loadHTMLString(noInternet, baseURL: urlrequest)
        }
//        myWebView.reload()
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("here comes did finish")
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: {(result: Any?, error: Error?) in
            if error == nil {
                let regex = "rtid\\~.*\\~\\d{4}-\\d{2}-\\d{2}"
                let resultString = String(describing: result)
//                print(resultString)
                if let range = resultString.range(of:regex, options: .regularExpression) {
                    let nresult = resultString.substring(with: range)
                    self.saveInfo(alert: nresult)
                }

            }
        })
        webView.evaluateJavaScript("document.cookie", completionHandler: {(result: Any?, error: Error?) in
            if error == nil {

                let resultString = String(describing: result)
                print("webcontent cookie in didfinish ",resultString)
                let cookieArray = resultString.components(separatedBy: ";")
                for cookie in cookieArray {
//                    print("print all cookie", cookie)
                    var parsedCookie = cookie
                    parsedCookie = parsedCookie.replacingOccurrences(of: "(", with: "")
                    parsedCookie = parsedCookie.replacingOccurrences(of: ")", with: "")
                    parsedCookie = parsedCookie.replacingOccurrences(of: "Optional", with: "")
                    parsedCookie = parsedCookie.replacingOccurrences(of: " ", with: "")
                    if cookie.range(of: Constants.CookieName + "=") != nil {
//                        print("cookie needed ",parsedCookie)
                        let center = UserDefaults.standard
                        center.set(parsedCookie, forKey: Constants.CookieValueKey)
//                        print("Cookie is stored")
                    }
                }
            }
                

        })
        

        SwiftSpinner.hide()
    }


    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SwiftSpinner.show("Loading...")
    }
    func saveInfo(alert: String){
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd"
        var infos = alert.split(separator: "~")
        print(infos[1])
        print(infos[2])
        let start = dateFomatter.date(from: String(infos[2]))
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start!)
        
        self.settings.updateAndSave(rtid: String(infos[1]), beginTime: start!, endTime: end!, setAtTime: Date())
        self.settings.saveSettingToDefault()
        print("notification is set during login", Notification.setNotification())

    }
    var tField: UITextField!
    func configurationTextField(textField: UITextField!)
    {
        
        textField.placeholder = "Enter an item"
        tField = textField
        tField.isSecureTextEntry = true
    }
    @objc func showOptions() {
        let optionMenu = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        

        let adminAction = UIAlertAction(title: "Admin", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("admin")
            
            let alert = UIAlertController(title: "admin", message: "Please Enter the admin password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: self.configurationTextField)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in

                if(self.tField.text == "bas"){
                    self.performSegue(withIdentifier: "admin", sender: nil)
                } else {
                    self.view.showToast("Wrong password", position: .bottom, popTime: 3, dismissOnTap: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
            
        })
        
        
        let refreshAction = UIAlertAction(title: "Show Notifications", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let notifications = self.defaults.string(forKey: Constants.NotificationsTimeKey)
            
            let alert = UIAlertController(title: "All notification in center", message: notifications, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
//            Notification.showNotificaiton()

        })
        
        let recordAction = UIAlertAction(title: "Sound recording", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if(self.settings.isLoggedIn()){
                self.performSegue(withIdentifier: "record", sender: nil)
            } else {
                self.view.showToast("Please loggin first", position: .bottom, popTime: 3, dismissOnTap: false)
            }
            
            
        })

        
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("logout")
            
            Notification.removeNotification()
            
            let center = UserDefaults.standard
           
            
            center.removeObject(forKey: Constants.CookieValueKey)
            
            center.synchronize()
            print("check delete correctly", center.object(forKey: Constants.CookieValueKey) == nil)
           
            
            print("Cookie is stored")
            
            Settings.clearSettingToDefault()
            self.settings = Settings()
            self.view.showToast("Logout", position: .bottom, popTime: 3, dismissOnTap: true)
            self.showWebView(url: UrlBuilder.build(page: "testandroid", settings: self.settings, now: Date(),  includeParams: false));
            
        })
        let issueAction = UIAlertAction(title: "Technical issue", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let dic = Bundle.main.infoDictionary!
            let buildNumber = dic["CFBundleVersion"]! as! String
//            print("buildNumber is ", buildNumber)
            
            var message = Strings.main_technicalissues_body  + buildNumber  + Strings.main_technicalissues_body2
            let rtid = self.settings.getRtid()!
            message +=  rtid == "" ? "null" : rtid
            let alert = UIAlertController(title: Strings.main_technicalissues_title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        })
        let refreshWebAction = UIAlertAction(title: "Refresh", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.route(settings: self.settings, now: Date())

        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel",style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(refreshWebAction)
//        optionMenu.addAction(SurveyAction)
        optionMenu.addAction(adminAction)
        optionMenu.addAction(refreshAction)
        optionMenu.addAction(recordAction)
        optionMenu.addAction(issueAction)
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        // 5
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
   
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.show("Loading...")
        route(settings: settings, now: Date())
    }
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        route(settings: settings, now: Date())

        

        completionHandler()
    }
    func loadLocalHtml(destinationURLForFile: String){
            print("here to load local")
            let htmlPath = Bundle.main.path(forResource: destinationURLForFile, ofType: "html")
            let url = URL(fileURLWithPath: htmlPath!)
            let request = URLRequest(url: url)
            self.myWebView.load(request)
    }
    func getCookie() -> String{
        
        let center = UserDefaults.standard
        if center.object(forKey: Constants.CookieValueKey) != nil{
            var cookieString = center.string(forKey: Constants.CookieValueKey)!
            cookieString = cookieString.replacingOccurrences(of: "(", with: "")
            cookieString = cookieString.replacingOccurrences(of: ")", with: "")
            cookieString = cookieString.replacingOccurrences(of: "Optional", with: "")
            cookieString = cookieString.replacingOccurrences(of: " ", with: "")
            return cookieString;
        }
        return ""
    }
   
}


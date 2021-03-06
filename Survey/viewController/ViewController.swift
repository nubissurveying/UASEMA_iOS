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
import CoreLocation
import CoreMotion
import Alamofire
import MessageUI

class ViewController: UIViewController , WKNavigationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate{

    var netTimer: Timer!
    var myWebView : WKWebView!
    private var settings : Settings = Settings()
    private var texts : Texts = Texts()
    
    private var hasInternet = true;
    private var defaults = UserDefaults.standard
    private var isInSurvey = false;
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var Hz = 50.0
    var LogUrl : URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
        
        // init wkwebview
        setWKWebview()

        
        // set notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // set title
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
//        imageView.contentMode = .s
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        //set menu
        let options = UIBarButtonItem.init(image: UIImage.init(named: "options"), style: .plain, target: self, action: #selector(self.showOptions))
        self.navigationItem.setRightBarButton(options, animated: true)
        
        
        //set service and documents
        startAccService()
        LogUrl = DocumentDirUrl.appendingPathComponent("UrlLog").appendingPathExtension("txt")
        LocalFileManager.setFile(fileURL: LogUrl!, writeString: "Log\n")
        
        //timeStringfiyTest
//        print("human readable date test ", DateUtil.stringifyHuman(calendar: Date()))
//        Notification.showNotificaiton()
        
    }
    
    // function to start acclerometer
    func startAccService(){
        
        if(settings.getAcc() == 1){
            print("viewController"," start accService")
            showDeveToast(message: "viewController start accService")
            setupCoreLocation()
            setFile()
            setAcce()
        } else {
            print("viewController"," accService is not required to start")
        }
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
//        SwiftSpinner.show("Loading from WillEnterForeground...")
        setSpinner(message: "Loading from WillEnterForeground...")
        settings = Settings.getSettingFromDefault()
        print("back from app will enter foreground")
//        self.view.showToast("app will enter foreground", position: .bottom, popTime: 3, dismissOnTap: false)
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        route(settings: settings, now: Date())
        
    }
    override func viewWillAppear(_ animated: Bool) {
//        SwiftSpinner.show("Loading from ViewWillAppear...")
        setSpinner(message: "Loading from ViewWillAppear...")
        settings = Settings.getSettingFromDefault()
//        self.view.showToast("enter view will applear", position: .bottom, popTime: 3, dismissOnTap: false)
        print("back from app will enter view will applear")
        
        route(settings: settings, now: Date())
        
    }
    
    
    /**
     set spinner with message and timer
     
     */
    func setSpinner(message: String){
        if let num = Int(settings.getRtid()!){
            if(num < 1000){
                SwiftSpinner.show(message)
            } else {
                SwiftSpinner.show("loading")
            }
        } else {
            SwiftSpinner.show("loading")
        }
        
        
        netTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeSpinner), userInfo: nil, repeats: false)
    }
    
    /**
     show toast when the rtid is less then 1000
     - parameter message: message content
     */
    func showDeveToast(message: String){
        if let num = Int(settings.getRtid()!){
            if(num < 1000){
                self.view.showToast(message, position: .bottom, popTime: 3, dismissOnTap: false)
            }
        }
        
        
    }
    
    /**
    close the spinner and timer
     */
    @objc func closeSpinner(){
        SwiftSpinner.hide()
        
        netTimer.invalidate()
//        self.view.showToast("Check ", position: .bottom, popTime: 3, dismissOnTap: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     show pages according to current time and settings
     - parameter settings : settings class recording current account info
     - parameter now: current time
     */
    func route(settings: Settings, now : Date){
        
        print("here comes route")

        print("should show survey ",settings.shouldShowSurvey(calendar: now))
        if(settings.isLoggedIn() && settings.allFieldsSet() && settings.shouldShowSurvey(calendar: now)) {
//        if(true) {
            // get current survey and set flag
            let survey = settings.getSurveyByTime(now: now);
            survey?.setAlarmed()
            let internet = isInternetAvailable()
            survey?.setInternet(internet: internet)
            if(internet) {
                survey?.setAsTaken()
            }
            // remove second notification is there there is one
            if(survey != nil) {
                Notification.removeNotificationForASurvey(SurveyDate: (survey?.getDate())!)
            }

            let indexTag = survey?.getNotificationTag(now: now, timeToReminder: settings.gettimeToReminder())
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_ALARM, settings: settings, now: now, includeParams: true, reportTo: indexTag!))

            isInSurvey = true;
            
            SwiftSpinner.hide()

            print("route comes to User is logged in and during survey, is in survey", isInSurvey)
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to User is logged in and during survey, is in survey \(isInSurvey) \n")
            showDeveToast(message: "Survey start")
            
            //  User is logged in, is not during survey, and has not skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_START, settings: settings, now: now, includeParams: true));
            
            showDeveToast(message: "not in survey, not skip")
//                self.view.showToast("not in survey, not skip", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            print("route comes to User is logged in, is not during survey, and has not skipped previous")
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to User is logged in, is not during survey, and has not skipped previous \n")
            
            //  User is logged in, but has skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && settings.skippedPrevious(now: now)){
//            if(isInSurvey){
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOREACTION, settings: settings, now: now, includeParams: true));
            
            showDeveToast(message: "skip")
//                self.view.showToast("skip", position: .bottom, popTime: 3, dismissOnTap: false)
            isInSurvey = false
//            }
            print("route comes to User is logged in, but has skipped previous")
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to User is logged in, but has skipped previous \n")
            
            //  UserId set from APK; is logged in, but has no start and end times;
        } else if (settings.isLoggedIn() && !settings.allFieldsSet()){
            print("route comes to UserId set from APK; is logged in, but has no start and end times;")
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_INIT_NODATE, settings: settings, now: now,  includeParams: true));
                //            self.view.showToast("login no start and end", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to UserId set from APK; is logged in, but has no start and end times \n")
            //  No user; either opted out, or started with APK with no RTID
        } else if (settings.isLoggedIn() && settings.hasNoAlarms() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
            
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOALARMS, settings: settings, now: now, includeParams: true))
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to noAlarms")
        } else if (!settings.isLoggedIn()) {
            
            print("route comes to No user; either opted out, or started with APK with no RTID")
            LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "route comes to No user; either opted out, or started with APK with no RTID \n")
            
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: "testandroid", settings: settings, now: now,  includeParams: false));
                //showWebView(UrlBuilder.build(UrlBuilder.PHONE_START, settings, now,  false));
                //            self.view.showToast("not login", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            
        }
        if(settings.getRtid() != ""){
            Survey.updateClosed(settings: settings)
            settings.saveSettingToDefault()
        }
        
    }
    func showWebView(url: String) {
        LocalFileManager.appendfile(fileURL: LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + " " + url + "\n")
        print("show webview ",url)
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
        print("here comes did finish ")
//        LocalFileManager.appendfile(fileURL: self.LogUrl!, dataString: DateUtil.stringifyAll(calendar: Date()) + "actual url loaded " + (webView.url?.absoluteString)! + "\n") 
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: {(result: Any?, error: Error?) in
            if error == nil {
//                print("html content", result)
                let regex = "\\{\"rtid.*\\}"
                let resultString = String(describing: result)
//                print("regex match",resultString)
                if let range = resultString.range(of:regex, options: .regularExpression) {
                    let nresult = resultString[range]
                    
                    print("regex match for json",nresult)
                    JsonParser.updateSetting(webpage: String(nresult), settings: self.settings)
                    self.saveInfo()
                    self.startAccService()
                    self.texts = Texts()
                    
                }
                let jsAlertRegex = "alert(.*)"
                if let range = resultString.range(of:jsAlertRegex, options: .regularExpression) {
                    let nresult = String(resultString[range])
                    
                    print("regex match for js alert",nresult)
                    if(nresult == "alert(\"\(Constants.VIDEO)\")"){
                        self.showWebView(url: Constants.VIDEO_URL)
                    } else if (nresult == "alert(\"\(Constants.SOUNDRECORDING)\")"){
                        self.performSegue(withIdentifier: "record", sender: nil)
                    }
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
            }})
           
        SwiftSpinner.hide()
    }


    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        SwiftSpinner.show("Loading from didStartProvisionalNavigation...")
        setSpinner(message: "Loading from didStartProvisionalNavigation...")
    }
    
        
    func saveInfo(){

        self.settings.saveSettingToDefault()
        if(self.settings.getSurveys().count > 0){
            print("notification is set during login", Notification.setNotification())
        }
        
        
    }
    var tField: UITextField!
    func configurationTextField(textField: UITextField!){

        textField.placeholder = "Enter an item"
        tField = textField
        tField.isSecureTextEntry = true
    
    }
    @objc func showOptions() {
        
        
            let optionMenu = UIAlertController(title: nil, message: texts.getMenuText(menuType: .Menu), preferredStyle: .actionSheet)
            
            print("MenuContent", texts.getMenuText(menuType: .Admin))
            let adminAction = UIAlertAction(title: texts.getMenuText(menuType: .Admin), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("admin")
                if(self.settings.isLoggedIn()){
                    let alert = UIAlertController(title: self.texts.getMenuText(menuType: .Admin), message: self.texts.getMenuText(menuType: .AdminPassword), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addTextField(configurationHandler: self.configurationTextField)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
                        
                        if(self.tField.text == "bas"){
                            self.performSegue(withIdentifier: "admin", sender: nil)
                        } else {
                            self.view.showToast(self.texts.getToast(toastType: .WrongPassword), position: .bottom, popTime: 3, dismissOnTap: true)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.view.showToast(self.texts.getToast(toastType: .LoginAlert), position: .bottom, popTime: 3, dismissOnTap: false)
                }
                

            })
            
            
//            let refreshAction = UIAlertAction(title: "Show Notifications", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//
//                let notifications = self.defaults.string(forKey: Constants.NotificationsTimeKey)
//
//                let alert = UIAlertController(title: "All notification in center", message: notifications, preferredStyle: UIAlertControllerStyle.alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                //            Notification.showNotificaiton()
//
//            })
        
            let recordAction = UIAlertAction(title: texts.getMenuText(menuType: .SoundRecording), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if(self.settings.isLoggedIn()){
                    self.performSegue(withIdentifier: "record", sender: nil)
                } else {
                    self.view.showToast(self.texts.getToast(toastType: .LoginAlert), position: .bottom, popTime: 3, dismissOnTap: false)
                }
            })
            
            
            let logoutAction = UIAlertAction(title: texts.getMenuText(menuType: .Logout), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("logout")
                
                
                
                self.showDeveToast(message: self.texts.getToast(toastType: .Logout))
                
                
                self.showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_LOGOUT, settings: self.settings, now: Date(),  includeParams: true));
                Settings.clearSettingToDefault()
                self.settings = Settings()
                Notification.removeNotification()
                
                let center = UserDefaults.standard
                
                
                center.removeObject(forKey: Constants.CookieValueKey)
                center.synchronize()
                print("check delete correctly", center.object(forKey: Constants.CookieValueKey) == nil)
                print("Cookie is stored")
                self.clearCache()
                Texts.clearTexts()
                self.texts = Texts()
            })
            let issueAction = UIAlertAction(title: texts.getMenuText(menuType: .TechIssue), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let dic = Bundle.main.infoDictionary!
                let buildNumber = dic["CFBundleShortVersionString"]! as! String
                //            print("buildNumber is ", buildNumber)
                
                var message = Strings.main_technicalissues_body  + buildNumber  + Strings.main_technicalissues_body2
                let rtid = self.settings.getRtid()!
                message +=  rtid == "" ? "null" : rtid
                let alert = UIAlertController(title: Strings.main_technicalissues_title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            })
            let refreshWebAction = UIAlertAction(title: texts.getMenuText(menuType: .Refresh), style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.route(settings: self.settings, now: Date())
                
            })
            let mailAction = UIAlertAction(title: "send log", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in

                if(MFMailComposeViewController.canSendMail()){
                    
                    LocalFileManager.appendfile(fileURL: self.LogUrl!, dataString: "\n" + DateUtil.stringifyAll(calendar: Date()) + self.settings.toString())
                    print("send mail", "can send")
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.mailComposeDelegate = self
                    
                    // set subject and message of the email
                    mailComposer.setSubject("Log send at " + DateUtil.stringifyAll(calendar: Date()))
                    mailComposer.setMessageBody("Log is at attachment\nPlease try to describe the bug", isHTML: false)
                    mailComposer.setToRecipients(["qinjiahu@usc.edu"])
                    
                    if let fileData = NSData(contentsOf:self.LogUrl!) {
                        print("send mail","file loaded")
                        mailComposer.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName: "Log.txt")
                    }
                    
                    self.present(mailComposer, animated: true, completion: nil)
                    
                } else {
                    print("send mail", "cannot send")
                    self.view.showToast("Please try bind email account to your phone first", position: .bottom, popTime: 3, dismissOnTap: false)
                }
                Notification.showNotificaiton()

            })
        
            //
            let cancelAction = UIAlertAction(title: texts.getMenuText(menuType: .Cancel),style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(adminAction)
            optionMenu.addAction(refreshWebAction)
            //        optionMenu.addAction(SurveyAction)
        
            //            optionMenu.addAction(refreshAction)
            if(settings.isLoggedIn()){
                optionMenu.addAction(recordAction)
            }
        
            optionMenu.addAction(issueAction)
            if(settings.isLoggedIn()){
                optionMenu.addAction(logoutAction)
                optionMenu.addAction(mailAction)
            }
        
        
            optionMenu.addAction(cancelAction)
            // 5
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(optionMenu, animated: true, completion: nil)
            
            
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            self.dismiss(animated: true, completion: nil)
        }
        override func viewDidAppear(_ animated: Bool) {
//            SwiftSpinner.show("Loading from viewDidAppear...")
            setSpinner(message: "Loading from viewDidAppear...")
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
    
    //location service
    var locationFileURL : URL!
    let locationFileName = "locationFileName"
    var locationUploadFlag = false;
    func setupCoreLocation()  {
        print("setupCoreLocation")
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("in setup ","not determined")
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            print("in setup ","authorized")
            enableLocationServices()
        default:
            break
        }
    }
    func enableLocationServices()  {
        if CLLocationManager.locationServicesEnabled() && settings.getAcc() == 1{
            
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 2
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            locationFileURL = DocumentDirUrl.appendingPathComponent(locationFileName).appendingPathExtension("txt")
            LocalFileManager.setFile(fileURL: locationFileURL, writeString: "location Service test\n")
        } else {
            print("location enabled but not start")
        }
    }
    func disableLocationServices(){
        locationManager.stopUpdatingLocation()
    }
    //location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("location authorized")
            enableLocationServices()
        case .denied, .restricted:
            print("not authorized")
        default:
            break
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("Date: ",DateUtil.stringifyAll(calendar: Date())," Coord: \(location.coordinate)")
        LocalFileManager.appendfile(fileURL: locationFileURL, dataString: "Date: " + DateUtil.stringifyAll(calendar: Date()) + " Coord: \(location.coordinate)\n")
        let threshold = self.calendar.component(.second, from: Date())
        if(threshold > 30 && !locationUploadFlag){
            locationUploadFlag = true
//            let localBase = "http://10.120.65.133:8888/ema/index.php"
//            Upload.upload(fileUrl: locationFileURL, desUrl: localBase)
            LocalFileManager.resetFile(fileURL: locationFileURL, settings: self.settings)
            print("LocationManager ","location is uploaded")
            
        } else if(threshold != 0) {
            locationUploadFlag = false
        }
    }
    
    
    //Accelerometer
    var count = 0.0
    var tempSum = 0.0
    var fileURL : URL! = nil
//    var basicUrl = "http://10.120.64.78:8888/TEST.php"
    var fileName = "rtid_replacement_acce_data"
    let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let calendar = Calendar.current
    var buffer = ""
    var uploaded = false
    var appended = false
    func setFile(){
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        let hardSave = DocumentDirUrl.appendingPathComponent("localSave").appendingPathExtension("txt")
        
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            let writeString = ""
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
        
        if fileManager.fileExists(atPath: hardSave.path){
            print("File exist")
        } else {
            print("File not exist")
            let writeString = "this is local copy\n"
            do{
                try writeString.write(to: hardSave,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
    }
    var filesToBeUpload : [URL] = []
    func setAcce() {
        
        motionManager.accelerometerUpdateInterval = 1.0/Hz
        motionManager.startAccelerometerUpdates(to : OperationQueue.current!){
            (data, error) in
            if let myData = data {
//                                print(myData)
                var svm = myData.acceleration.x * myData.acceleration.x +
                    myData.acceleration.y * myData.acceleration.y +
                    myData.acceleration.z * myData.acceleration.z
                
                svm = sqrt(svm) - 1
                self.tempSum = self.tempSum + svm
                self.count = self.count + 1.0
                if(self.count > self.Hz){
                    self.count = 0;
                    let message =  DateUtil.stringifyAllAlt(calendar: Date()) + " \(svm)" + "\n"
                    if(self.settings.isLoggedIn()){
                        let fileUrl = self.DocumentDirUrl.appendingPathComponent(self.settings.getRtid()! + DateUtil.stringifyDateUntilMin(calendar: Date())).appendingPathExtension("txt")
                        LocalFileManager.appendfile(fileURL: fileUrl, dataString: message)
                    }

//                    print("buffer test",self.buffer)
                    svm = 0.0;
                
                    
//                    upload part
                    let thresholdSec = self.calendar.component(.second, from: Date())
                    let thresholdMin = self.calendar.component(.minute, from: Date())
                    //thresholdHour == 0 &&
                    //                print(threshold)
                    if(thresholdSec == 59){
                        if(self.settings.isLoggedIn()){
                            let currentName = self.settings.getRtid()! + DateUtil.stringifyDateUntilMin(calendar: Date())
                            let fileUrl = self.DocumentDirUrl.appendingPathComponent(currentName).appendingPathExtension("txt")
                            if(!self.filesToBeUpload.contains(fileUrl)) {
                                self.filesToBeUpload.append(fileUrl)
                                print("acc", "add to array" + fileUrl.path)
                            }
                            if(thresholdMin == 59 && self.isInternetAvailable()){
                                print("acc", "upload all")
                                let desUrl = self.DocumentDirUrl.appendingPathComponent(DateUtil.stringifyAllAlt(calendar: Date())).appendingPathExtension("txt")
                                self.filesToBeUpload = LocalFileManager.combineAndUpload(filesToBeUpload: self.filesToBeUpload, desUrl: desUrl)
//                                self.filesToBeUpload = []
                            }
                        }
                    }
                }
            
                    
            }
        }
    }
    // new accelerometer code (without gravity)
    func setMotion(){
        print("setMotion")
        if motionManager.isDeviceMotionAvailable{
            print("setMotion start")
            motionManager.deviceMotionUpdateInterval = 1.0 / Hz
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!){
                (data, error) in
                if let myData = data {
                    //                print(myData)
                    var svm = myData.userAcceleration.x * myData.userAcceleration.x +
                        myData.userAcceleration.y * myData.userAcceleration.y +
                        myData.userAcceleration.z * myData.userAcceleration.z

                    svm = sqrt(svm)
                    self.tempSum = self.tempSum + svm
                    self.count = self.count + 1.0
                    if(self.count > self.Hz){
                        self.count = 0;
                        let message =  DateUtil.stringifyAllAlt(calendar: Date()) + " \(svm)" + "\n"
                        if(self.settings.isLoggedIn()){
                            let fileUrl = self.DocumentDirUrl.appendingPathComponent(self.settings.getRtid()! + DateUtil.stringifyDateUntilMin(calendar: Date())).appendingPathExtension("txt")
                            LocalFileManager.appendfile(fileURL: fileUrl, dataString: message)
                        }
                        
                        svm = 0.0;
                        
                        
                        //                    upload part
                        let thresholdSec = self.calendar.component(.second, from: Date())
                        let thresholdMin = self.calendar.component(.minute, from: Date())
                        //thresholdHour == 0 &&
                        //                print(threshold)
                        if(thresholdSec == 59){
                            if(self.settings.isLoggedIn()){
                                let currentName = self.settings.getRtid()! + DateUtil.stringifyDateUntilMin(calendar: Date())
                                let fileUrl = self.DocumentDirUrl.appendingPathComponent(currentName).appendingPathExtension("txt")
                                if(!self.filesToBeUpload.contains(fileUrl)) {
                                    self.filesToBeUpload.append(fileUrl)
                                    print("acc", "add to array" + fileUrl.path)
                                }
                                if(thresholdMin == 59 && self.isInternetAvailable()){
                                    print("acc", "upload all")
                                    let desUrl = self.DocumentDirUrl.appendingPathComponent(DateUtil.stringifyAllAlt(calendar: Date())).appendingPathExtension("txt")
                                    self.filesToBeUpload = LocalFileManager.combineAndUpload(filesToBeUpload: self.filesToBeUpload, desUrl: desUrl)
                                    //                                self.filesToBeUpload = []
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }

    func clearCache() {
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
        
}


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

class ViewController: UIViewController , WKNavigationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate{

    var netTimer: Timer!
    var myWebView : WKWebView!
    private var settings : Settings = Settings();
    
    private var hasInternet = true;
    private var defaults = UserDefaults.standard
    private var isInSurvey = false;
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var Hz = 50.0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().delegate = self
//        locationManager.delegate = self
        //json test
//        JsonParser.updateSettingSample()
        
        // init wkwebview
        setWKWebview()
        //        myWebView.delegate = self
        
        // set notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // set title
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
//        imageView.contentMode = .s
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        let options = UIBarButtonItem.init(image: UIImage.init(named: "options"), style: .plain, target: self, action: #selector(self.showOptions))
        self.navigationItem.setRightBarButton(options, animated: true)
        
        setupCoreLocation()
        setFile()
        setAcce()
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
    
    func setSpinner(message: String){
        SwiftSpinner.show(message)
        netTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(closeSpinner), userInfo: nil, repeats: false)
    }
    @objc func closeSpinner(){
        SwiftSpinner.hide()
        
        netTimer.invalidate()
//        self.view.showToast("Check ", position: .bottom, popTime: 3, dismissOnTap: true)
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
            if(!isInSurvey){
                let survey = settings.getSurveyByTime(now: now);
                survey?.setAlarmed()
                if(isInternetAvailable()) {
                    survey?.setAsTaken()
                }
                if(survey != nil) {
                    Notification.removeNotificationForASurvey(SurveyDate: (survey?.getDate())!)
                }
                let requestCode = (survey == nil) ? -1: survey?.getRequestCode()
                var timeTag = (requestCode == -1) ? "":settings.getTimeTag(requestCode: requestCode!)
                if(timeTag == nil) {timeTag = ""}
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_ALARM, settings: settings, now: now, includeParams: true) + timeTag!)
                isInSurvey = true;
            } else {
                SwiftSpinner.hide()
            }
            print("route comes to User is logged in and during survey, is in survey", isInSurvey)
            
            //            self.view.showToast("Survey start", position: .bottom, popTime: 3, dismissOnTap: false)
            //  User is logged in, is not during survey, and has not skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_START, settings: settings, now: now, includeParams: true));
                //            self.view.showToast("not in survey, not skip", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            print("route comes to User is logged in, is not during survey, and has not skipped previous")
            
            //  User is logged in, but has skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && settings.skippedPrevious(now: now)){
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOREACTION, settings: settings, now: now, includeParams: true));
                //            self.view.showToast("skip", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            print("route comes to User is logged in, but has skipped previous")
            
            //  UserId set from APK; is logged in, but has no start and end times;
        } else if (settings.isLoggedIn() && !settings.allFieldsSet()){
            print("route comes to UserId set from APK; is logged in, but has no start and end times;")
//            if(isInSurvey){
                showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_INIT_NODATE, settings: settings, now: now,  includeParams: true));
                //            self.view.showToast("login no start and end", position: .bottom, popTime: 3, dismissOnTap: false)
                isInSurvey = false
//            }
            
            //  No user; either opted out, or started with APK with no RTID
        } else if (!settings.isLoggedIn()) {
            
            print("route comes to No user; either opted out, or started with APK with no RTID")
            
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
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: {(result: Any?, error: Error?) in
            if error == nil {
//                print("html content", result)
                let regex = "\\{\"rtid.*\\}"
                let resultString = String(describing: result)
//                print("regex match",resultString)
                if let range = resultString.range(of:regex, options: .regularExpression) {
                    let nresult = resultString.substring(with: range)
                    
                    print("regex match",nresult)
                    JsonParser.updateSetting(webpage: nresult, settings: self.settings)
                    self.saveInfo()
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
            let bufferAction = UIAlertAction(title: "show Buffer", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                
                
                let message = "\(self.appended) \(self.count) \n" +  self.buffer
                let alert = UIAlertController(title: Strings.main_technicalissues_title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel",style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(adminAction)
            optionMenu.addAction(refreshWebAction)
            //        optionMenu.addAction(SurveyAction)
        
//            optionMenu.addAction(refreshAction)
            optionMenu.addAction(recordAction)
            optionMenu.addAction(issueAction)
            optionMenu.addAction(logoutAction)
            optionMenu.addAction(bufferAction)
            optionMenu.addAction(cancelAction)
            // 5
            optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(optionMenu, animated: true, completion: nil)
            
            
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
        if CLLocationManager.locationServicesEnabled(){
            
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //            locationManager.requestWhenInUseAuthorization()
            
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 2
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
            locationFileURL = DocumentDirUrl.appendingPathComponent(locationFileName).appendingPathExtension("txt")
            LocalFileManager.setFile(fileURL: locationFileURL, writeString: "location Service test\n")
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
            let localBase = "http://10.120.64.78:8888/ema/index.php"
            Upload.upload(fileUrl: locationFileURL, desUrl: localBase)
            print("LocationManager ","location is uploaded")
            
        } else if(threshold != 0) {
            locationUploadFlag = false
        }
    }
    
    
    //Accelerometer
    var count = 0.0
    var tempSum = 0.0
    var fileURL : URL! = nil
    var basicUrl = "http://10.120.64.78:8888/TEST.php"
    var fileName = "rtid_replacement_acce_data"
    let DocumentDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let calendar = Calendar.current
    var buffer = ""
    var uploaded = false
    var appended = false
    func setFile(){
        fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            let writeString = "ritd replacement\n"
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
    }
    func setAcce() {
        motionManager.accelerometerUpdateInterval = 1.0/Hz
        motionManager.startAccelerometerUpdates(to : OperationQueue.current!){
            (data, error) in
            if let myData = data {
                //                print(myData)
                var svm = myData.acceleration.x * myData.acceleration.x +
                    myData.acceleration.y * myData.acceleration.y +
                    myData.acceleration.z * myData.acceleration.z
                
                svm = sqrt(svm) - 1
                self.tempSum = self.tempSum + svm
                self.count = self.count + 1.0
                if(self.count > self.Hz){
                    self.count = 0;
                    self.buffer +=  DateUtil.stringifyAllAlt(calendar: Date()) + " \(svm)" + "\n"
                    print("buffer test",self.buffer)
                    svm = 0.0;
                    
                }
                let threshold = self.calendar.component(.second, from: Date())
                
//                print(threshold)
                if(threshold == 0 && !self.uploaded && self.count == 0){
                    print("upload and reset file")
                    let localBase = "http://10.120.64.78:8888/ema/index.php"
//                    self.view.showToast("upload from" + self.fileURL.path, position: .bottom, popTime: 3, dismissOnTap: false)
                    Upload.upload(fileUrl: self.fileURL, desUrl: localBase)
                    self.resetFile()
                    self.uploaded = true
                } else if (threshold == 30 && !self.appended && self.count == 0) {
                    print("append file")
                    self.appendfile(dataString: self.buffer)
                    self.buffer = ""
                    self.appended = true
                } else if(threshold != 0 && threshold != 30){
                    self.appended = false
                    self.uploaded = false
                }
            }
        }
    }
    func appendfile(dataString : String){
//        self.view.showToast("append to " + self.fileURL.path, position: .bottom, popTime: 3, dismissOnTap: false)
        //        print("data to be append ", dataString)
        do{
            let fileHandle = try FileHandle(forWritingTo: self.fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(dataString.data(using: .utf8)!)
            fileHandle.closeFile()
            
        } catch {
            print("Error writing to file \(error)")
        }
    }
    func resetFile(){
        self.fileURL = DocumentDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
//        self.view.showToast("reset to " + self.fileURL.path, position: .bottom, popTime: 3, dismissOnTap: false)
        do {
            try "".write(to: self.fileURL, atomically: true, encoding: .utf8)
        } catch let error {
            print(error)
        }
    }
    
        
}


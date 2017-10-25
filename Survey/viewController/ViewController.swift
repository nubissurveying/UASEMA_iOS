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

class ViewController: UIViewController , UIWebViewDelegate{
//    public static let URL = "URL";
//    private WebView webView;
//    private ProgressDialog dialog;
    private var settings : Settings = Settings();
//    private MyAlarmManager alarmManager;
    //  private FirebaseAnalytics mFirebaseAnalytics;
    private var hasInternet = true;
    private var defaults = UserDefaults.standard
//    private var comesFromNotification = false
    @IBOutlet weak var myWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading...")
        myWebView.delegate = self
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 39, height: 39))
        imageView.contentMode = .scaleToFill
        let image = UIImage(named: "uas_logo.png")
        imageView.image = image
        self.navigationItem.titleView = imageView
 
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let options = UIBarButtonItem.init(image: UIImage.init(named: "options"), style: .plain, target: self, action: #selector(self.showOptions))
        self.navigationItem.setRightBarButton(options, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
        settings = Settings.getSettingFromDefault()
//        SwiftSpinner.hide()
//        print(settings.toString())
        print("internet is :", isInternetAvailable())
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        
        
        route(settings: settings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func route(settings: Settings){
        let now = Date();
        
        //  User is logged in and during survey
        if(settings.isLoggedIn() && settings.allFieldsSet() && settings.shouldShowSurvey(calendar: now)) {
//            SwiftSpinner.hide()
            print("route comes to User is logged in and during survey")
//            self.performSegue(withIdentifier: "alarmAct", sender: nil)
            showWebView(url: "https://uas.usc.edu/survey/uas/ema/daily/index.php?android=1");
            //  User is logged in, is not during survey, and has not skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
            print("route comes to User is logged in, is not during survey, and has not skipped previous")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_START, settings: settings, now: now, includeParams: true));
            
            //  User is logged in, but has skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && settings.skippedPrevious(now: now)){
            print("route comes to User is logged in, but has skipped previous")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOREACTION, settings: settings, now: now, includeParams: true));
            
            //  UserId set from APK; is logged in, but has no start and end times;
        } else if (settings.isLoggedIn() && !settings.allFieldsSet()){
            print("route comes to UserId set from APK; is logged in, but has no start and end times;")
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_INIT_NODATE, settings: settings, now: now,  includeParams: true));
            
            //  No user; either opted out, or started with APK with no RTID
        } else if (!settings.isLoggedIn()) {
            print("route comes to No user; either opted out, or started with APK with no RTID")
            showWebView(url: UrlBuilder.build(page: "testandroid", settings: settings, now: now,  includeParams: false));
            //showWebView(UrlBuilder.build(UrlBuilder.PHONE_START, settings, now,  false));
        }
    }
    func showWebView(url: String) {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        let center = UserDefaults.standard
        if center.string(forKey: Constants.CookieNameKey) != nil{
            let cookieProps : [HTTPCookiePropertyKey:Any] = [
                HTTPCookiePropertyKey.name : center.string(forKey: Constants.CookieNameKey)!,
                HTTPCookiePropertyKey.value : center.string(forKey: Constants.CookieValueKey)!,
                HTTPCookiePropertyKey.domain : center.string(forKey: Constants.CookieDomainKey)!,
                HTTPCookiePropertyKey.path : center.string(forKey: Constants.CookiePathKey)!,
                HTTPCookiePropertyKey.secure : center.bool(forKey: Constants.CookieSKey)
            ]
            if let cookie = HTTPCookie(properties: cookieProps){
                HTTPCookieStorage.shared.setCookie(cookie)
                print(cookie,"cookie should be set")
            }
            print("cookie should be set")
        }
        
        
        print(url)
        let urlrequest = URL(string: url)
        if(isInternetAvailable()){
            
            myWebView.loadRequest(URLRequest(url: urlrequest!))
        } else{
            let noInternet = "<html><body><h3><font face=arial color=#5691ea>" +  "No internet connection detected. Make sure you are connected to the cellular network or wifi." + "</font></h3></body></html>"
            
            myWebView.loadHTMLString(noInternet, baseURL: urlrequest)
        }
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SwiftSpinner.hide()
        let doc = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
//        print(doc)
        let regex = "rtid\\~.*\\~\\d{4}-\\d{2}-\\d{2}"
        if let range = doc?.range(of:regex, options: .regularExpression) {
            let result = doc?.substring(with: range)
            print("regex result ",result!)
            saveInfo(alert: result!)
        }
        if let cookies = HTTPCookieStorage.shared.cookies{
            print("here is the cookies")
            for cookie in cookies{
//                print(cookie.name)
                print(cookie.name == "PHPSESSION")
                if(cookie.name == "PHPSESSION"){
                 
                    let center = UserDefaults.standard
                    center.set(cookie.name, forKey: Constants.CookieNameKey)
                    center.set(cookie.value, forKey: Constants.CookieValueKey)
                    center.set(cookie.path, forKey: Constants.CookiePathKey)
                    center.set(cookie.domain, forKey: Constants.CookieDomainKey)
                    center.set(cookie.isSessionOnly, forKey: Constants.CookieSOKey)
                    center.set(cookie.isSecure, forKey: Constants.CookieSKey)
                  
                    print("Cookie is stored")
                }
            }
        }
        
        
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
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
//        defaults.set(settings.toString(), forKey: Constants.SETTINGSDEFAULT)
//        print("saved", defaults.string(forKey: Constants.SETTINGSDEFAULT))
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
//                print("Item : \(self.tField.text)")
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
            self.performSegue(withIdentifier: "record", sender: nil)
            
        })
        let SurveyAction = UIAlertAction(title: "TestSurveyScreen", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "alarmAct", sender: nil)
            
        })
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("logout")
            
            let ids = [String]()
//            for sur in self.settings.getSurveys(){
//                let Date1 = sur.getDate()
//                let Date2 = Calendar.current.date(byAdding: .minute, value: 1, to: Date1)
//                ids.append(DateUtil.stringifyAll(calendar: Date1))
//                ids.append(DateUtil.stringifyAll(calendar: Date2!))
//            }
            Notification.removeNotification(ids: ids)
            
            Settings.clearSettingToDefault()
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
            self.myWebView.reload()

        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel",style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(refreshWebAction)
        optionMenu.addAction(SurveyAction)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "alarmAct" && settings.getSurveys().count > 0) {
            let now = Date()
            let survey = settings.getSurveyByTime(now: now);
//            print("this is the survey found by time",survey)
            //            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP);
//            let requestCode = (Int(now.timeIntervalSince((survey?.getDate())!)) < Constants.TIME_TO_REMINDER * 60) ?  survey?.getRequestCode() : (survey?.getRequestCode())! + 1;
            let requestCode = (survey == nil) ? -1: survey?.getRequestCode()
            let alarm: SurveyActionViewController = segue.destination as! SurveyActionViewController
            alarm.requestCode = requestCode
        }
       

    }
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.show("Loading...")
        route(settings: settings)
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

}


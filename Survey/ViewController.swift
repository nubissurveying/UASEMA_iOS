//
//  ViewController.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIWebViewDelegate{
//    public static let URL = "URL";
//    private WebView webView;
//    private ProgressDialog dialog;
    private var settings : Settings = Settings();
//    private MyAlarmManager alarmManager;
    //  private FirebaseAnalytics mFirebaseAnalytics;
    private var hasInternet = true;
    private var defaults = UserDefaults.standard
    @IBOutlet weak var myWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWebView.delegate = self
        
        self.title = "UASEma"
        
        let options = UIBarButtonItem.init(image: UIImage.init(named: "options"), style: .plain, target: self, action: #selector(self.showOptions))
        self.navigationItem.setRightBarButton(options, animated: true)
        // Do any additional setup after loading the view, typically from a nib.
        settings = Settings()
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
//            var survey = settings.getSurveyByTime(Calendar.getInstance());
//            Intent i = new Intent(this, AlarmActivity.class);
//            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP);
//            int requestCode =
//                (now.getTimeInMillis() - survey.getDate().getTimeInMillis() < Constants.TIME_TO_REMINDER * 60 * 1000) ?
//                    survey.getRequestCode() : survey.getRequestCode() + 1;
//            
//            i.putExtra(MyAlarmManager.REQUEST_CODE, requestCode);
//            startActivity(i);
//            finish();
//            
            //  User is logged in, is not during survey, and has not skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && !settings.skippedPrevious(now: now)){
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_START, settings: settings, now: now, includeParams: true));
            
            //  User is logged in, but has skipped previous
        }else if (settings.isLoggedIn() && settings.allFieldsSet() && !settings.shouldShowSurvey(calendar: now) && settings.skippedPrevious(now: now)){
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_NOREACTION, settings: settings, now: now, includeParams: true));
            
            //  UserId set from APK; is logged in, but has no start and end times;
        } else if (settings.isLoggedIn() && !settings.allFieldsSet()){
            showWebView(url: UrlBuilder.build(page: UrlBuilder.PHONE_INIT_NODATE, settings: settings, now: now,  includeParams: true));
            
            //  No user; either opted out, or started with APK with no RTID
        } else if (!settings.isLoggedIn()) {
            showWebView(url: UrlBuilder.build(page: "testandroid", settings: settings, now: now,  includeParams: false));
            //showWebView(UrlBuilder.build(UrlBuilder.PHONE_START, settings, now,  false));
        }
    }
    func showWebView(url: String) {
        let urlrequest = URL(string: url)
        myWebView.loadRequest(URLRequest(url: urlrequest!))
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let doc = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
//        print(doc)
        let regex = "rtid\\~.*\\~\\d{4}-\\d{2}-\\d{2}"
        if let range = doc?.range(of:regex, options: .regularExpression) {
            let result = doc?.substring(with: range)
            print("regex result ",result!)
            saveInfo(alert: result!)
        }
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
    @objc func showOptions() {
        let optionMenu = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        

        let adminAction = UIAlertAction(title: "Admin", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("admin")
            self.performSegue(withIdentifier: "admin", sender: nil)
        })
        
        
        let refreshAction = UIAlertAction(title: "Refresh", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("refresh")
            Notification.showNotificaiton()

        })
        
        let recordAction = UIAlertAction(title: "Sound recording", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "record", sender: nil)
            
        })
        
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("logout")
            Settings.clearSettingToDefault()
            var ids = [String]()
            for sur in self.settings.getSurveys(){
                let Date1 = sur.getDate()
                let Date2 = Calendar.current.date(byAdding: .minute, value: 1, to: Date1)
                ids.append(DateUtil.stringifyAll(calendar: Date1))
                ids.append(DateUtil.stringifyAll(calendar: Date2!))
            }
            Notification.removeNotification(ids: ids)
            
        })
        let issueAction = UIAlertAction(title: "Technical issue", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Share")
            
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel",style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(adminAction)
        optionMenu.addAction(refreshAction)
        optionMenu.addAction(recordAction)
        optionMenu.addAction(issueAction)
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }

}

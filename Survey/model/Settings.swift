//
//  Settings.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class Settings: NSObject {
    private static var mInstance : Settings!;
    private static var PTUS_SETTINGS = "PTUS_SETTINGS";
    
    private var loggedIn = false;
    private var rtid = ""
    private var beginTime : Date!;
    private var endTime : Date!;
    private var surveys : [Survey] = [];
    private var setAtTime: Date!;
    
    public var serverURL = "https://uas.usc.edu/survey/uas/ema/daily/index.php";
    
    override init() {
        
    }
    
    /** Used to create new Settings Object from Admin panel; this object is not saved; only used to build url parameters */
    init(rtid: String, beginTime: Date, endTime: Date) {
        self.rtid = rtid;
        self.beginTime = beginTime;
        self.endTime = endTime;
    }
    
    /** Getters && Setters */
    /** Update Settings (Only updated by ChromeView Alert; does not overwrite rtid unless rtid == null || "" ) */
    public func  updateAndSave(  rtid : String,   beginTime : Date,   endTime : Date,   setAtTime : Date){
        self.loggedIn = true;
        self.rtid = (rtid == "") ? self.rtid : rtid;   //  rtid == "" when changing settings after logging out;
        self.beginTime = beginTime;
        self.endTime = endTime;
        self.surveys = (Constants.isDemo) ? Settings.buildSurveysDev(start: beginTime, end: endTime) : Settings.buildSurveysPro(start: beginTime, end: endTime);
        self.setAtTime = setAtTime;
        
    }
    public func  updateUserIdAndSave(  rtid : String){
        loggedIn = true;
        self.rtid = rtid;
     
    }
    public func getSurveys() -> [Survey] {
        return surveys;
    }
    public func getbeginTime() -> Date {
        return beginTime;
    }
    public func getEndTime()-> Date {
        return endTime;
    }
    public func getRtid()-> String? {
        
        return rtid;
    }
    public func isLoggedIn()-> Bool {
        return loggedIn;
    }
    
    /** Should take survey; Set survey as taken */
    public func  setTakenSurveyAndSave( requestCode : Int){
        let currentSurvey = getSurveyByCode(requestCode: requestCode);
        if(currentSurvey != nil){
            currentSurvey?.setAsTaken();
    }
     
    }
    public func  setClosedSurveyAndSave( requestCode : Int){
        let currentSurvey = getSurveyByCode(requestCode: requestCode);
        if(currentSurvey != nil){
            currentSurvey?.setClosed();
    }
     
    }
    public func getSurveyByCode(requestCode: Int) -> Survey?{
        let surveyCode = Survey.getSurveyCode(requestCode: requestCode);
        for i in 0 ..< surveys.count {
            if(surveys[i].getRequestCode() == surveyCode) {
                return surveys[i];
            }
        }
        return nil
    }
    public func getSurveyByTime(now : Date) -> Survey?{
//        print("the date to find is ", now)
        
        for i in 0 ..< surveys.count {
//            print("current survey is",surveys[i].getDate())
            let timeDiffInMin = Int(now.timeIntervalSince(surveys[i].getDate())) /  (60 );
            if(0 < timeDiffInMin && timeDiffInMin < Constants.TIME_TO_TAKE_SURVEY) {
                print("founded", surveys[i].getDate())
                return surveys[i]
            }
        }
        return nil;
    }
    public func shouldShowSurvey(calendar : Date) -> Bool{
        let currentSurvey = getSurveyByTime(now: calendar);
        return currentSurvey != nil && !currentSurvey!.isTaken() && !currentSurvey!.isClosed();
    }
    
    /** User logged in && ready to take surveys */
    public func allFieldsSet()-> Bool{
    return !(rtid == nil || beginTime == nil || endTime == nil);
    }
    
    /** Time Tag */
    public func getTimeTag(requestCode: Int)-> String?{
        let position = requestCode / 3;
        if(position == surveys.count - 1){
            return UrlBuilder.TIME_LAST;
        } else if (position == 0) {
            return UrlBuilder.TIME_FIRST;
        } else if (surveys.count / 2 <= position){
            return UrlBuilder.TIME_MIDDLE;
        } else {
            return nil;
        }
    }
    
    /**Build alarm times as url param*/
    public func alarmTimes()->String{
        
        var dic = [Int : String]()
        if(surveys.count > 0){
            for i in 0 ..< surveys.count{
                let sur = surveys[i]
                dic[i + 1] = DateUtil.stringifyTime(calendar: sur.getDate());
            }
        }
        return dic.description
    }
    
    /** Load, Save, Clear */
//    public static  func getInstance()->Settings{
//        if(mInstance == nil) {
//            mInstance = build(loadSettings(context));
//        }
//        return mInstance;
//    }
//    private static func loadSettings() -> String{
//    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
//    return preferences.getString(PTUS_SETTINGS, "");
//    }
//    private static Settings build(String json){
//    if(json.equals("")){
//    return new Settings();
//    } else {
//    return gson.fromJson(json, Settings.class);
//    }
//    }
    
    public func  clearAndSave(){
        loggedIn = false;
        beginTime = nil;
        endTime = nil;
        surveys = [Survey]()
     
    }
//    private func save(){
//    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
//    SharedPreferences.Editor editor = preferences.edit();
//    editor.putString(PTUS_SETTINGS, toJson());
//    editor.commit();
//    }
//    private String toJson(){
//    return gson.toJson(this);
//    }
    
    /** Set alarms from dates */
    private static func buildSurveysDev(  start : Date,   end : Date) ->[Survey]{
    
        let minute = 60
        let minutesDiff = Int(end.timeIntervalSince(start))  / minute;
        var beepMinDiff = [Int]()
        for  i in stride(from: 0, to: minutesDiff, by: Constants.TIME_BETWEEN_SURVEYS_DEV) {
            beepMinDiff.append(i);
        }
        
        var alarmTimes = [Survey]();
        for  i in 0 ..< beepMinDiff.count{
            let calendar = Calendar.current.date(byAdding: .minute, value: beepMinDiff[i], to: start)
            alarmTimes.append(Survey(requestCode: i * 3, date: calendar!));
        }
            return alarmTimes;
    }
    
    
    public static func buildSurveysPro(  start : Date,   end : Date) ->[Survey]{
        
        let minute = 60
        let timeDiffInMin = Int(end.timeIntervalSince(start)) / minute;
        var counter = 0;
        
        
        var randomBeepsMinDiff = [Int]();
        while(counter <= timeDiffInMin){
            let random = Int(arc4random_uniform(15))
            let randNum = (counter == 0) ? 5 : random + Constants.TIME_BETWEEN_SURVEYS_PRO;
            counter += randNum;
            if(counter <= timeDiffInMin) {
                randomBeepsMinDiff.append(counter);
            }
        }
        
        var surveys = [Survey]();
        for i in 0 ..< randomBeepsMinDiff.count {
            let calendar = Calendar.current.date(byAdding: .minute, value: randomBeepsMinDiff[i], to: start)
            let hours = Calendar.current.component(.hour, from: calendar!)
            if (hours >= 10 && hours <= 20) { //don't add before 10 and after 9
                surveys.append(Survey(requestCode: i * 3, date: calendar!));
            }
        }
        return surveys;
    }
    

    
    /** Logging */
    
    public func toString()->String {
        var res = "TT Settings => "
         res +=   "\n allFieldsSet: " + String(allFieldsSet())
         res +=   "\n loggedIn: " + String(loggedIn)
         res +=   "\n rtid: " + rtid
        res +=   "\n begin: " + DateUtil.stringifyAll(calendar: beginTime)
        res +=   "\n end: " + DateUtil.stringifyAll(calendar: endTime)
         res +=   "\n surveys: " + ((surveys.count > 0) ? String(surveys.count) : "null")
        res +=   "\n" + stringifyAlarms(surveys: surveys);
        return res
    }
    
    private func stringifyAlarms(surveys:[Survey]) ->String{
        if(surveys.count > 0){
            var string = "";
            for sur in surveys {
                string += sur.toString() +  "\n";
            }
            return string;
        } else {
            return "null";
        }
    }
    
    public func skippedPrevious(  now : Date) ->Bool{
        let previous = getPreviousSurvey(now: now);
    //  If no previous surveys, obviously no surveys have been skipped
        if(previous == nil){
            print("TT", "Settings => A");
            return false;
    //  Last survey is last, don't show NO_REACTION screen
        } else if (previous!.getRequestCode() == surveys[surveys.count - 1].getRequestCode()) {
            print("TT", "Settings => B");
            return false;
    //  Don't show NO_REACTION if setAtTime is between previous survey time and now
        } else if (previous!.getDate() < setAtTime && setAtTime < now){
            print("TT", "Settings => C");
            return false;
    //  Show NO_REACTION if previous survey skipped
        } else {
            print("TT", "Settings => D");
            return !previous!.isTaken();
        }
        
    }
    private func  getPreviousSurvey( now : Date) ->Survey?{
        for sur in surveys.reversed() {
            if sur.getDate() < now {
                return sur;
            }
        }
        return nil;
    }
    
    public static func getSurveysFromSetting(settings: Settings)->[Survey]{
        return [Survey]()
    }
    public func saveSettingToDefault(){
        let defaults = UserDefaults.standard
        defaults.set(self.loggedIn, forKey: Constants.loggedInKey)
        defaults.set(self.rtid , forKey: Constants.rtidKey)
        defaults.set(self.stringifyAlarms(surveys: self.surveys), forKey: Constants.surveysKey)
        defaults.set(DateUtil.stringifyAll(calendar: beginTime), forKey: Constants.beginTimeKey)
        defaults.set(DateUtil.stringifyAll(calendar: endTime), forKey: Constants.endTimeKey)
        defaults.set(DateUtil.stringifyAll(calendar: setAtTime), forKey: Constants.setAtTimeKey)

    }
    static  func clearSettingToDefault(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.loggedInKey)
        defaults.removeObject(forKey: Constants.rtidKey)
        defaults.removeObject(forKey: Constants.surveysKey)
        defaults.removeObject(forKey: Constants.beginTimeKey)
        defaults.removeObject(forKey: Constants.endTimeKey)
        defaults.removeObject(forKey: Constants.setAtTimeKey)
        
    }
    public static func getSettingFromDefault() -> Settings{
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: Constants.rtidKey) == nil) {
            return Settings()
        }else {
            let res = Settings();
            res.rtid = defaults.string(forKey: Constants.rtidKey)!
            res.loggedIn = defaults.bool(forKey: Constants.loggedInKey)
            res.beginTime = DateUtil.dateAll(calendar: defaults.string(forKey: Constants.beginTimeKey)!)
            res.endTime = DateUtil.dateAll(calendar: defaults.string(forKey: Constants.endTimeKey)!)
            res.setAtTime = DateUtil.dateAll(calendar: defaults.string(forKey: Constants.setAtTimeKey)!)
            
            let surveysString = defaults.string(forKey: Constants.surveysKey)
            let surveyArray = surveysString?.split(separator: "\n")
            var ss = [Survey]()
            for str in surveyArray! {
                ss.append(Survey.getSuveryFromString(input:String(str)))
            }
            res.surveys = ss
            return res
            
        }
    }
}

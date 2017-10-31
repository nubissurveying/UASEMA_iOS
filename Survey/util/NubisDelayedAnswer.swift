//
//  NubisDelayedAnswer.swift
//  Survey
//
//  Created by Qinjia Huang on 10/15/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class NubisDelayedAnswer: NSObject {
    
    static public var N_GET = 1;
    static public var N_POST = 2;
    static public var N_POST_FILE = 3;
    static public var N_GET_READ = 4;
    static public var N_CHECK_SERVER = 5;
    
    static public var N_lineEnd = "\r\n";
    static public var N_twoHyphens = "--";
    static public var N_boundary = "*****";
    
//    private ByteArrayOutputStream bos = null;
    
    private var postData = "";
    private var type : Int!
    public var sent = false; //tag to indicate whether this one has been sent already!
    
    var POST_fileName: String!
    
    
    private var map : [String : String]
    
    override init() {
        map = [String : String]()
    }
    init(type : Int) {
        map = [String : String]()
        self.type = type
    }
    public func getType()-> Int?{
        return self.type!;
    }
    
    
    public func addGetParameter(key : String,value : Int){
        map[key] = String(value)
    }
    
    public func addGetParameter(key : String, value : String){
        map[key] = value
    }
    
    public func  setPostData(data : String){
        self.postData = data;
    }
    
    public func getPostData() -> String{
        return self.postData;
    }
    
    public func addFileName(filename : String){
        POST_fileName = filename;
    }
    
//    public func setByteArrayOutputStream(){
//        try {
//            FileInputStream fis = new FileInputStream(POST_fileName);
//            bos = new ByteArrayOutputStream();
//            byte[] buf = new byte[1024];
//            for (int readNum; (readNum = fis.read(buf)) != -1;) {
//                bos.write(buf, 0, readNum); //no doubt here is 0
//            }
//        }
//            catch (Exception e){
//
//        }
//    }
    
    
    
//    public ByteArrayOutputStream getByteArrayOutputStream(){
//        try {
//            if (bos == null){ //null -> set it
//            FileInputStream fis = new FileInputStream(POST_fileName);
//            ByteArrayOutputStream bos = new ByteArrayOutputStream();
//            byte[] buf = new byte[1024];
//            for (int readNum; (readNum = fis.read(buf)) != -1;) {
//                bos.write(buf, 0, readNum); //no doubt here is 0
//            }
//        }
//            return bos;
//        }
//        catch (Exception e){
//            return null;
//        }
//    }
    
    public func getGetString() -> String? {
        do {
            let jsonDate = try JSONSerialization.data(withJSONObject: map, options: .prettyPrinted)
            return String(data : jsonDate, encoding: String.Encoding.utf8)
    /*
     String outputStr = "";
     if (map.size() > 0){
     for (String key : map.keySet()) {
     outputStr += "&" + key + "=" + URLEncoder.encode((String) map.get(key), "utf-8");
     }
     //return "?" + outputStr.substring(1);
     return outputStr.substring(1);*/
    
        }
        catch let error as NSError {
        print("\(error.localizedDescription)")
    }
    return "";
    }


}

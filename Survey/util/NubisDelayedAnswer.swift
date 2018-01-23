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
    
    private var bos : OutputStream!
    
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
    
    public func setByteArrayOutputStream(){
        
            
            let fis = InputStream(fileAtPath: POST_fileName);
            bos = OutputStream();
            let bufferSize = 1024
            let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            while (fis?.hasBytesAvailable)! {
                let read = fis?.read(buf, maxLength: bufferSize)
                print("input stream reader count : " , read!)
                bos.write(buf, maxLength: read! )
            }
            buf.deallocate(capacity: bufferSize)
            
            fis?.close()
        
        

    }

    
    
    public func getByteArrayOutputStream(output: OutputStream){
        
            
            let fis = InputStream(fileAtPath: POST_fileName);
            
            let bufferSize = 1024
            let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            while (fis?.hasBytesAvailable)! {
                let read = fis?.read(buf, maxLength: bufferSize)
                print("input stream reader count : " , read!)
                output.write(buf, maxLength: read! )
            }
            buf.deallocate(capacity: bufferSize)
            
            fis?.close()
    }
    
    public func getGetString() -> String? {
        do {
//            let jsonDate = try JSONSerialization.data(withJSONObject: map, options: .prettyPrinted)
//            let currString = String(data : jsonDate, encoding: String.Encoding.utf8)
//            let temp = currString?.replacingOccurrences(of: " ", with: "")
//
//            return temp?.replacingOccurrences(of: "\n", with: "")
    /*
     String outputStr = "";
     if (map.size() > 0){
     for (String key : map.keySet()) {
     outputStr += "&" + key + "=" + URLEncoder.encode((String) map.get(key), "utf-8");
     }
     //return "?" + outputStr.substring(1);
     return outputStr.substring(1);*/
            var res = "{"
            for (key, value) in map {
                res += "\"\(key)\":\"\(value)\","
            }
            res.removeLast()
            res += "}"
//            print("delayanswer string:",res.count, res)
//            for ch in res.unicodeScalars {
//                print(ch, ch.value)
//            }
            return res
    
        }
        catch let error as NSError {
        print("\(error.localizedDescription)")
    }
    return "";
    }
    

}

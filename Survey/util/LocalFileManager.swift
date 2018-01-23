//
//  LocalFileManager.swift
//  Survey
//
//  Created by Qinjia Huang on 1/8/18.
//  Copyright © 2018 Qinjia Huang. All rights reserved.
//

import UIKit

class LocalFileManager: NSObject {
    static func setFile(fileURL: URL, writeString: String){
        
        print("file path : \(fileURL.path)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
        } else {
            print("File not exist")
            
            do{
                try writeString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
    }
    static func appendfile(fileURL:URL, dataString : String){
        print("local FileManager", "append string" + dataString)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path){
            print("File exist")
            do{
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(dataString.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("Error writing to file \(error)")
            }
        } else {
//            print("File not exist")
            do{
                try dataString.write(to:fileURL,atomically: true,encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("fail to write to url")
                print(error)
            }
            
        }
        
        
    }
    static func resetFile(fileURL: URL, settings : Settings){
        
        do {
            try settings.getRtid()?.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch let error {
            print(error)
        }
    }
    static func combineAndUpload(filesToBeUpload : [URL], desUrl: URL) -> [URL]{
        var noUploaded : [URL] = []
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: desUrl.path){
            print("localFileManager"," File exist")
        } else {
            
            if(filesToBeUpload.count > 0){
                setFile(fileURL: desUrl, writeString: "")
                do {
                    for currUrl in filesToBeUpload {
                        if fileManager.fileExists(atPath: currUrl.path) {
                            let message = try String(contentsOf: currUrl)
                            appendfile(fileURL: desUrl, dataString: message)
                            print("localFileManager"," file deleted \(currUrl.path)")
                            try fileManager.removeItem(at: currUrl)
                            
                        } else {
                            noUploaded.append(currUrl)
                        }
                        
                    }
                    
                    let localBase = "http://10.120.65.133:8888/ema/index.php"
                    Upload.upload(fileUrl: desUrl, desUrl: Constants.baseURL)
                    
//                    try fileManager.removeItem(at: desUrl)
                    print("localFileManager"," file uploaded")
                } catch let error {
                    print("combine and upload: \(error)")
                }
                
                
            }
        }
        return noUploaded
    }
}

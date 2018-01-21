//
//  Upload.swift
//  Survey
//
//  Created by Qinjia Huang on 1/6/18.
//  Copyright © 2018 Qinjia Huang. All rights reserved.
//

import UIKit
import Alamofire

class Upload: NSObject {
    
    static var settings = Settings.getSettingFromDefault()
    static func upload(fileUrl : URL, desUrl: String){
        print("try to upload using alamofire to local ema")
        
        
        
        let delayedAnswer = NubisDelayedAnswer(type: NubisDelayedAnswer.N_POST_FILE)
        dispatchDelayedAnswer(delayedAnswer: delayedAnswer, url: fileUrl)
        
        print("here comes upload encrypt string", Encrypt(inputStr: delayedAnswer.getGetString()!))
        
        print(desUrl + "?ema=1&q=" + Encrypt(inputStr: delayedAnswer.getGetString()!))
        
        uploadFile(filePath: fileUrl, uploadURL: desUrl + "?ema=1&q=" + Encrypt(inputStr: delayedAnswer.getGetString()!))
        print("end uploading using alamofire")
    }
    static func dispatchDelayedAnswer(delayedAnswer : NubisDelayedAnswer, url: URL){
//        let fileManager = FileManager.default
        let dic = Bundle.main.infoDictionary!
        let buildNumber = dic["CFBundleVersion"]! as! String
        delayedAnswer.addGetParameter(key: "version", value: buildNumber)
        delayedAnswer.addGetParameter(key: "rtid", value: settings.getRtid()!)
        delayedAnswer.addGetParameter(key: "phonets", value: DateUtil.stringifyAllAlt(calendar: Date()))
        delayedAnswer.addGetParameter(key: "p", value: "uploadacceldata")
        delayedAnswer.addGetParameter(key: "ema", value: "1")
        delayedAnswer.addFileName(filename: url.path)
        //        delayedanswer.setByteArrayOutputStream()
//        let output = OutputStream(toFileAtPath: fileManager.getDocumentsDirectory().appendingPathComponent(streamName).path, append:true)
//        output?.open()
//        var input = NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_boundary + NubisDelayedAnswer.N_lineEnd
//        output?.write(input, maxLength: input.count)
//
//        input = "Content-Disposition: form-data; name=\"uploadedfile\";filename=\"" + "test" + "\"" + NubisDelayedAnswer.N_lineEnd
//        output?.write(input, maxLength: input.count)
//
//        output?.write(NubisDelayedAnswer.N_lineEnd, maxLength: NubisDelayedAnswer.N_lineEnd.count)
//        delayedAnswer.getByteArrayOutputStream(output: output!)
//
//        output?.write(NubisDelayedAnswer.N_lineEnd, maxLength: NubisDelayedAnswer.N_lineEnd.count)
//        input = NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_boundary + NubisDelayedAnswer.N_twoHyphens + NubisDelayedAnswer.N_lineEnd
//        output?.write(input, maxLength: input.count)
//        output?.close()
    }
    static func Encrypt(inputStr:String)->String{
        do {
            let mcrypt = MCrypt();
            return try MCrypt.bytesToHex( data: mcrypt.encrypt(text: inputStr)! )!;
        }
        catch let error as NSError{
            print("mycrypt in record uploading error \(error.localizedDescription)")
        }
        return inputStr;
    }
    static func uploadFile(filePath : URL, uploadURL: String){
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                multipartFormData.append(filePath, withName: "uploadedfile", fileName: "test.txt", mimeType: "text/plain")
                //服务器地址
        },to: uploadURL,encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //json处理
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    print("json:\(result)")
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("file upload progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}

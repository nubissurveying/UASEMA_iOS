//
//  MCrypt.swift
//  Survey
//
//  Created by Qinjia Huang on 10/21/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import CryptoSwift
import Foundation

class MCrypt: NSObject {

    private let iv = "fei28fjwf24f8sf2";//Dummy iv (CHANGE IT!)
   
    
    private let SecretKey = "f29fjamvcnvq01md";//Dummy secretKey (CHANGE IT!)
    
//    override init() {
//        ivspec = new IvParameterSpec(iv.getBytes());
//
//        keyspec = new SecretKeySpec(SecretKey.getBytes(), "AES");
//
//        try {
//        cipher = Cipher.getInstance("AES/CBC/NoPadding");
//        } catch (NoSuchAlgorithmException e) {
//        // TODO Auto-generated catch block
//        e.printStackTrace();
//        } catch (NoSuchPaddingException e) {
//        // TODO Auto-generated catch block
//        e.printStackTrace();
//        }
//    }
//
    enum cryptError: Error {
        case encrypt
        case decrypt
        case deCryptEmptyInput
        case enCryptEmptyInput
    }
    public func encrypt(text :String? )throws -> [UInt8]? {
        if(text == nil || text?.count == 0){
            throw cryptError.enCryptEmptyInput
            return nil
        }

        var encrypted =  [UInt8]()

        do{
            let input = text?.data(using: String.Encoding.utf8)
            
            let inbytes:[UInt8] = input!.bytes
//            AES(SecKey,iv,.CBC)
            encrypted = try! AES(key: Array(SecretKey.utf8), blockMode: .CBC(iv: Array(iv.utf8)), padding: .pkcs7).encrypt(inbytes)
            
//            let dData: NSData = NSData(bytes: encryptedDeviceID)
            
//            let strDeviceID = dData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//            cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec);
//
//            encrypted = cipher.doFinal(padString(text).getBytes());
        } catch {
            throw cryptError.encrypt
        }

        return encrypted;
    }

    public func decrypt(code : String?) throws-> [UInt8]? {
        if(code == nil || code?.count == 0){
            throw cryptError.deCryptEmptyInput
            return nil
        }
        

        var decrypted = [UInt8]()

        do {
            
            let input = code?.data(using: String.Encoding.utf8)
            
            let inbytes:[UInt8] = input!.bytes
            //            AES(SecKey,iv,.CBC)
            decrypted = try! AES(key: Array(SecretKey.utf8), blockMode: .CBC(iv: Array(iv.utf8)), padding: .pkcs7).decrypt(inbytes)
//            cipher.init(Cipher.DECRYPT_MODE, keyspec, ivspec);
//
//            decrypted = cipher.doFinal(hexToBytes(code));
        } catch {
            throw cryptError.decrypt
        }
        return decrypted;
    }

    
    
    public static func bytesToHex(data : [UInt8]) -> String?
    {
        if (data.count == 0)
        {
            return nil;
        }
    
        let len = data.count
        var str = "";
        for i in 0 ..< len {
            if ((data[i]&0xFF)<16){
                str = str + "0" + String(format:"%2X", data[i]&0xFF)
            }
            else{
                str = str + String(format:"%2X", data[i]&0xFF)
            }
            
        }
        let nstr = str.replacingOccurrences(of: " ", with: "")
        return nstr;
    }
    
    
    public static func hexToBytes(str : String?) -> [UInt8]? {
        if (str == nil) {
            return nil;
        } else if ((str?.count)! < 2) {
            return nil;
        } else {
            let len = (str?.count)! / 2;
            var buffer = [UInt8]()
            for i in 0 ..< len{
                let start = str?.index((str?.startIndex)!, offsetBy: i * 2)
                let end = str?.index((str?.startIndex)!, offsetBy: i * 2 + 2)
                let newStr = String(str![start!...end!])
                buffer[i] = newStr.hexa2Bytes[0]
            }
            return buffer;
        }

    }
    
    
    
    private static func padString(source : String) -> String{
        var res = source
        let paddingChar = " ";
        let size = 16;
        let x = source.count % size;
        let padLength = size - x;
        
        for _ in 0 ..< padLength
        {
            res += paddingChar;
        }
        
        return res
    }
    
    
}


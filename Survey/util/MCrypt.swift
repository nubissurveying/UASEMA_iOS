//
//  MCrypt.swift
//  Survey
//
//  Created by Qinjia Huang on 10/21/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit
import CryptoSwift

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
//    public byte[] encrypt(String text) throws Exception
//{
//    if(text == null || text.length() == 0)
//    throw new Exception("Empty string");
//
//    byte[] encrypted = null;
//
//    try {
//    cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec);
//
//    encrypted = cipher.doFinal(padString(text).getBytes());
//    } catch (Exception e)
//    {
//    throw new Exception("[encrypt] " + e.getMessage());
//    }
//
//    return encrypted;
//    }
//
//    public byte[] decrypt(String code) throws Exception
//{
//    if(code == null || code.length() == 0)
//    throw new Exception("Empty string");
//
//    byte[] decrypted = null;
//
//    try {
//    cipher.init(Cipher.DECRYPT_MODE, keyspec, ivspec);
//
//    decrypted = cipher.doFinal(hexToBytes(code));
//    } catch (Exception e)
//    {
//    throw new Exception("[decrypt] " + e.getMessage());
//    }
//    return decrypted;
//    }
    
    
    
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
        return str;
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
                var temp = str![start!...end!]
                
                let newStr = String(temp)
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


//
//  Reource.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/15.
//

import Foundation
import CommonCrypto
import CryptoKit

public struct Task{
    public var request:URLRequest
    public var id:URLSessionTask
    public var localFile:URL
}


public class Downloader{
    
    public var session:URLSession = URLSession(configuration: .default)
    
//    public func download(url:String)->Task{
//        
//    }
    
    public func key(info:String)->String?{
        if #available(iOS 13.0, *) {
            self.md5Hash(for: info)
        } else {
            self.md5(info)
        }
    }
    @available(iOS 13.0, *)
    func md5Hash(for string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        let hash = data.withUnsafeBytes { bytes in
            Insecure.MD5.hash(data: bytes)
        }
        return hash.map { i in
            String(format: "%02hhx", i)
        }.joined()
    }
    func md5(_ source: String) -> String? {
        var hash = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        defer{
            hash.deallocate()
        }
        guard let data = source.data(using: .utf8) else { return nil }
        let hashData = data.withUnsafeBytes { b in
            
            CC_MD5(b.baseAddress, CC_LONG(b.count), hash)
            return Data(bytes: hash, count:Int(CC_MD5_DIGEST_LENGTH))
        }
        return hashData.reduce(into: "") { partialResult, i in
            partialResult += String(format: "%02hhx", i)
        }
    }
    deinit{
        session.invalidateAndCancel()
    }
}

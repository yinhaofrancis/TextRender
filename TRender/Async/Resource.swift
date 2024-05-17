//
//  Reource.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/15.
//

import Foundation
import CommonCrypto
import CryptoKit




public class Downloader{
    
    public var session:URLSession = URLSession(configuration: .default)
    
    private var semaphore:DispatchSemaphore = DispatchSemaphore(value: 1)
    private var tasks:[String:Task] = [:]
    public init() {
        
    }
    public var cacheDictionary:URL?{
        guard let u = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("TextRender") else { return nil }
        try! FileManager.default.createDirectory(at: u, withIntermediateDirectories: true, attributes: nil)
        return u
    }
    
    public func download(url:String) throws ->Task{
        
        guard let local = self.localFile(url: url) else { throw NSError(domain: "local url can't located", code: 0)}
        let key = self.key(info: url)!
        if FileManager.default.fileExists(atPath: local){
            return Task(localFile: URL(string: local)!)
        }
        semaphore.wait()
        if let task = self.tasks[key]{
            semaphore.signal()
            return task
        }
        semaphore.signal()
        guard let url = URL(string: url) else { throw NSError(domain: "URL create fail", code: 0)}
        let req = URLRequest(url: url)
        let dt = Task(localFile:URL(string:local)!)
        let task = self.session.downloadTask(with: req) { [weak self] url, rep, err in
            guard let self else { return }
            dt.cachefile(temp: url, error: err)
            self.semaphore.wait()
            self.tasks.removeValue(forKey: key)
            self.semaphore.signal()
        }
        semaphore.wait()
        
        dt.request = req
        dt.task = task
        self.tasks[key] = dt
        semaphore.signal()
        task.resume()
        return dt
    }
    
    func localFile(url:String)->String?{
        guard let key = self.key(info: url) else { return nil }
        guard let cacheDictionary else { return nil }
        return cacheDictionary.appendingPathComponent(key).path
    }
    
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
        let hash = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
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
extension Downloader{
    
    
    public class Task{
        fileprivate var request:URLRequest?
        fileprivate var task:URLSessionTask?
        private var sem:DispatchSemaphore = DispatchSemaphore(value: 1)

        public var localFile:URL
        public var error:Error?
        
        private var observer:[(Task)->Void] = []
        
        public func load(_ callback:@escaping (Task)->Void){
            sem.wait()
            if(task == nil){
                sem.signal()
                callback(self)
            }else{
                self.observer.append(callback)
                sem.signal()
            }
        }
        func cachefile(temp:URL?,error:Error?){
            if let temp {
                do{
                    try FileManager.default.moveItem(atPath: temp.path, toPath: self.localFile.path)
                }catch{
                    self.error = NSError(domain: "create local file error", code: 0)
                }
                
            }
            sem.wait()
            self.task = nil
            let ob = self.observer
            sem.signal()
            for i in ob{
                i(self)
            }
        }
        public init(request: URLRequest? = nil, task: URLSessionTask? = nil, localFile: URL) {
            self.request = request
            self.task = task
            self.localFile = localFile
        }
    }
}


import Foundation

class ImageFileManager: NSObject {
    
    private var cacheFolder: URL? = {
        if let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first{
            let bundleID = (Bundle.main.bundleIdentifier ?? "") + "-imageCache"
            let path = cacheDir.appendingPathComponent(bundleID)
            
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            
            return path
        }
        
        return nil
    }()
    
    private func md5(string: String) -> Data? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    func isExistCacheFile(urlStr: String) -> Bool {
        if let filePath = imageFilePath(urlStr: urlStr){
            return FileManager.default.fileExists(atPath: filePath.path)
        }
        return false
    }
    
    func imageFilePath(urlStr: String) -> URL? {
        let fileName = md5(string: urlStr)!.map { String(format: "%02hhx", $0) }.joined() + ".png"
        return cacheFolder?.appendingPathComponent(fileName)
    }
}

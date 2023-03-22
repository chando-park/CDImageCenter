

import UIKit

/**
 public enum Folder: String{
     case intro = "Intro"
     case `class` = "Class"
     case coach = "Coach"
     case etc = "Etc"
     case quiz = "Quiz"
     case record = "Record"
     case flash_card = "FlashCards"
     case gnb = "GNB"
     case game = "Game"
     
     var path: String{
         switch self {
         case .class:
             if AngDevice.current.deviceType.deviceFamily.isPad{
                 return "\(self.rawValue)/pad/"
             }else{
                 return "\(self.rawValue)/phone/"
             }
         default:
             return "\(self.rawValue)/"
         }
     }
 }
 */

protocol FolderType{
    var path: String {get}
}

class LFE_Images<F: FolderType>: NSObject {
    
    public enum ImageType {
        case png
        case jpg
        
        var extentionName: String{
            switch self {
            case .png:
                return "png"
            case .jpg:
                return "jpg"
            }
        }
    }

    private var _imageCaches : NSCache = NSCache<AnyObject,AnyObject>()
    private var _loadOperations : NSCache = NSCache<AnyObject,AnyObject>()
    private var _imageLoadQueue : OperationQueue = {
        let ilq = OperationQueue()
        ilq.name = "imageLoadQueueName"
        ilq.maxConcurrentOperationCount = 1
        return ilq
    }()

    func obtainImgae(by key: String) -> UIImage? {
        return self._imageCaches.object(forKey: key as AnyObject) as? UIImage
    }
    
    func loadImages(folder: F, imageNames: [String], imageType: ImageType = .png, completion: @escaping (NSCache<AnyObject, AnyObject>, Bool) -> ()) {
        
        var loadedCount: Int = 0
        let _imageCaches : NSCache = NSCache<AnyObject,AnyObject>()
        DispatchQueue.global(qos: .userInteractive).async {
            for name in imageNames {
                if let f_o = Bundle.main.path(forResource: folder.path + name, ofType: imageType.extentionName), let image = UIImage(named: f_o) {
                    if let _ = _imageCaches.object(forKey: name as AnyObject){
                    }else{
                        _imageCaches.setObject(image, forKey: name as AnyObject)
                    }
                }
                loadedCount += 1
            }
            
            DispatchQueue.main.async {
                if loadedCount == imageNames.count  {
                    completion(_imageCaches, true)
                }else{
                    completion(_imageCaches, false)
                }
            }
        }
    }

    public func loadImage(urlStr: String, completedCallback: @escaping ImageloaderCompletedCallback) {
        
        if _isExistOperation(key: urlStr){
            return
        }
        
        let downOP = ImageloaderOperation(keyType: .bundle(path: "")) { image, error in
            if let image = image{
                self.saveCache(image, key: "")
            }
            completedCallback(image, error)
        }
        self._saveOperation(downOP, key: urlStr)
        self._imageLoadQueue.addOperation(downOP)
    }
    
    public func saveCache(_ image: UIImage, key: String) {
        _imageCaches.setObject(image, forKey: key as AnyObject)
    }
    
    //캐시된 이미지
    private func _savedCache(key: String) -> UIImage? {
        _imageCaches.object(forKey: key as AnyObject) as? UIImage
    }
    
    //오퍼레이션 저장...
    private func _saveOperation(_ op: ImageloaderOperation, key: String) {
        _loadOperations.setObject(op, forKey: key as AnyObject)
    }
    
    //오퍼레이션 삭제
    private func _removeOperation(key: String){
        if _isExistOperation(key: key){
            _loadOperations.removeObject(forKey: key as AnyObject)
        }
    }
    //오페레이션?
    private func _isExistOperation(key: String) -> Bool{
        if let _ = _loadOperations.object(forKey: key as AnyObject){
            return true
        }
        return false
    }
    //모든 캐시 삭제
    @objc private func removeAllCache(){
        self._imageCaches.removeAllObjects()
    }

    func removeAllCaches() {
        self._imageCaches.removeAllObjects()
    }
}

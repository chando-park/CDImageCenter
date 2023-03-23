

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

 }
 */

public protocol FolderType{
    var path: String {get}
}


public class LFE_Images: NSObject {
    
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
    
    public enum ImageLocationType{
        case bundle(folder: FolderType)
        case web(address: String)
        
        var path: String?{
            ""
        }
        
        var key: String?{
            path?.md5
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

    func obtainImage(by key: String) -> UIImage? {
        return self._imageCaches.object(forKey: key.md5 as AnyObject) as? UIImage
    }
    
    func loadImages(imageNames: [ImageLocationType], imageType: ImageType = .png, completion: @escaping (Bool) -> ()) {
        
        var loadedCount: Int = 0
        let _imageCaches : NSCache = NSCache<AnyObject,AnyObject>()
        DispatchQueue.global(qos: .userInteractive).async {
            for name in imageNames {
//                if let f_o = Bundle.main.path(forResource: folder.path + name, ofType: imageType.extentionName), let image = UIImage(named: f_o) {
                if let f_o = name.path, let image = UIImage(named: f_o) {
                    if let _ = _imageCaches.object(forKey: name as AnyObject){
                    }else{
                        _imageCaches.setObject(image, forKey: name as AnyObject)
                    }
                }
                loadedCount += 1
            }
            
            DispatchQueue.main.async {
                if loadedCount == imageNames.count  {
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }

    public func loadImage(op: ImageloaderOperation, completedCallback: @escaping ImageloaderCompletedCallback) {
        
        if _isExistOperation(key: op.key){
            return
        }

        op.setCompleted { image, error in
            if let image = image{
                self._saveCache(image, key: op.key)
            }
            completedCallback(image, error)
        }
        self._saveOperation(op, key: op.key)
        
    }
    
    private func _saveCache(_ image: UIImage, key: String?) {
        guard let key = key else{
            return
        }
        
        _imageCaches.setObject(image, forKey: key.md5 as AnyObject)
    }

    //오퍼레이션 저장...
    private func _saveOperation(_ op: ImageloaderOperation, key: String?) {
        guard let key = key else{
            return
        }
        
        _loadOperations.setObject(op, forKey: key as AnyObject)
        self._imageLoadQueue.addOperation(op)
    }
    
    //오퍼레이션 삭제
    private func _removeOperation(key: String?){
        
        guard let key = key else{
            return
        }
        
        if _isExistOperation(key: key){
            _loadOperations.removeObject(forKey: key as AnyObject)
        }
    }
    //오페레이션?
    private func _isExistOperation(key: String?) -> Bool{
        guard let key = key else{
            return false
        }
        
        if let _ = _loadOperations.object(forKey: key as AnyObject){
            return true
        }
        return false
    }
    //모든 캐시 삭제
    @objc private func removeAllCache(){
        self._imageCaches.removeAllObjects()
    }
}

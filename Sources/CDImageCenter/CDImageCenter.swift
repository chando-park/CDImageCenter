

import UIKit

public protocol FolderType{
    var path: String {get}
}

public class CDImagesCenter: NSObject {
    
    public typealias ImageloaderCompletedCallback = (_ image: UIImage?,_ error: Error?) -> ()
    
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

    func obtainImage(by key: String) -> UIImage? {
        return self._imageCaches.object(forKey: key.md5 as AnyObject) as? UIImage
    }

    public func loadImage(factory: ImageOperationFactory, completedCallback: @escaping ImageloaderCompletedCallback) {
        
        if _isExistOperation(key: factory.key){
            completedCallback(nil, nil)
            return
        }

        let op = factory.operation
        op.setCompleted { image, error in
            if let image = image{
                self._saveCache(image, key: factory.key)
            }
            completedCallback(image, error)
        }
        self._saveOperation(op, key: factory.key)
        
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

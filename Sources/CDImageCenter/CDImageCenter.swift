

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

    private var imageCaches : NSCache = NSCache<AnyObject,AnyObject>()
    
//    static let center = LFE_Images()
    
    func getfilePathImgagData(key: String) -> UIImage? {
        return self.imageCaches.object(forKey: key as AnyObject) as? UIImage
    }
    
    func loadImages(folder: F, imageNames: [String], imageType: ImageType = .png, completion: @escaping (NSCache<AnyObject, AnyObject>, Bool) -> ()) {
        
        var loadedCount: Int = 0
        let imageCaches : NSCache = NSCache<AnyObject,AnyObject>()
        DispatchQueue.global(qos: .userInteractive).async {
            for name in imageNames {
                if let f_o = Bundle.main.path(forResource: folder.path + name, ofType: imageType.extentionName), let image = UIImage(named: f_o) {
                    if let _ = imageCaches.object(forKey: name as AnyObject){
                    }else{
                        imageCaches.setObject(image, forKey: name as AnyObject)
                    }
                }
                loadedCount += 1
            }
            
            DispatchQueue.main.async {
                if loadedCount == imageNames.count  {
                    completion(imageCaches, true)
                }else{
                    completion(imageCaches, false)
                }
            }
        }
    }
    
    func loadImage(folder: F, imageName: String?, imageType: ImageType = .png) -> UIImage? {
        if let image = imageCaches.object(forKey: imageName as AnyObject){
            return image as? UIImage
        }else{
            
            guard let imageName = imageName else {
                return nil
            }

            if let f_o = Bundle.main.path(forResource: folder.path + imageName, ofType: imageType.extentionName), let image = UIImage(named: f_o) {
                imageCaches.setObject(image, forKey: imageName as AnyObject)
//                print("folder in \(folder.path) loaded")
                return image
            }else{
                print("\(folder)m \(imageName) load fail")
                return nil
            }
        }
    }
    
    func loadImage(url: URL?, complted: @escaping (_ image: UIImage?)->()){
//        SDWebImageManager.shared().loadImage(with: url, options: .retryFailed, progress: nil) { image, data, error, type, success, url in
//            complted(image)
//        }
    }
    
    func removeAllCaches() {
        self.imageCaches.removeAllObjects()
    }
}

//
//  ImageloaderOperation.swift
//  
//
//  Created by Littlefox iOS Developer on 2023/03/22.
//

import UIKit


public typealias ImageloaderCompletedCallback = (_ image: UIImage?,_ error: Error?) -> ()

public class ImageloaderOperation: Operation {
    
    enum KeyType{
        case bundle(path: String)
        case url(address: String)
        
        var key: String{
            switch self {
            case .url(let address):
                return address
            case .bundle(let path):
                return path
            }
        }
    }

    private let _keyType : KeyType
    private var _completedCallback : ImageloaderCompletedCallback?
    
    var key: String{
        _keyType.key
    }
    
    init(keyType: KeyType) {
        self._keyType = keyType
    }
    
    func setCompleted(completedCallback: @escaping ImageloaderCompletedCallback){
        self._completedCallback = completedCallback
    }
    
    override public func main() {
        
        if self.isCancelled {
            return
        }

        
        var error: Error?
        
        
        let image : UIImage? = {

            switch self._keyType {
            case .bundle(let path):
                
                let image = UIImage(contentsOfFile: path)
                return image
                
            case .url(let address):
                
                do{
                    let url = try address.asURL()
                    let data = try Data(contentsOf: url)
     
                    let imageFromData = UIImage(data: data)

                    return imageFromData
                }catch let e{
                    error = e
                }
                
                return nil
                
            }
        }()

        DispatchQueue.main.async {
            self._completedCallback?(image,error)
        }
    }
}


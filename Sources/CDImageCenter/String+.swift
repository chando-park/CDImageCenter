//
//  File.swift
//  
//
//  Created by Littlefox iOS Developer on 2023/03/22.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG


public extension String {
    
    enum DataConetedError: Error{
        case invalidURL(urlStr: String)
    }
    
    var md5: String {
        guard let messageData = self.data(using:String.Encoding.utf8) else { return self }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }

        return String(data: digestData, encoding: .utf8) ?? self
    }

    public func asURL() throws -> URL {
        guard let url = URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            throw DataConetedError.invalidURL(urlStr: self)
        }
        return url
    }
}

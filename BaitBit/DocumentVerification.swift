//
//  DocumentVerification.swift
//  BaitBit
//
//  Created by Akhilesh Lamba on 28/4/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import FirebaseMLVision

class DocumentVerification: NSObject {
    
    static func checkLicense(pickedImage: UIImage, complete : @escaping ([String:NSDate?]) ->Void ){
        var a : [String:NSDate?] = [:]
        var textRecognizer : VisionTextRecognizer!
        let vision = Vision.vision()
        let visionImage = VisionImage(image: pickedImage)
        textRecognizer.process(visionImage) { result, error in
            
            guard error == nil, let result = result else {
                a["Problem in recognising the image"] = nil
                complete(a)
                return
            }
            
            let range = NSRange(location: 0, length: result.text.utf16.count)
            let regex = try! NSRegularExpression(pattern: "[0-9]{2}[-/][0-9]{2}[-/][0-9]{4}")
            
            let matches = regex.firstMatch(in: result.text, options: [], range: range)
            
            let substrings = result.text.split(separator: "\n")
            if !substrings.contains("Agricultural Chemical User Permit") {
                a["Invalid License"] = nil
                complete(a)
            } else {
                let date = Util.convertStringToDate(string: matches.map {String(result.text[Range($0.range, in: result.text)!])}!)
                a["Success"] = date
                complete(a)
            }
        }
    }
    
}

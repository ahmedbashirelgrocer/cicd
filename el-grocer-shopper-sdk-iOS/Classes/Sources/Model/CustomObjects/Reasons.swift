//
//  Reason.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 04/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

class Reasons : NSObject, NSCoding, NSSecureCoding {
   
    
    static var supportsSecureCoding: Bool = true
    var reasonKey : NSNumber = -1
    var reasonString : String = ""
    
    override init() {
        
        super.init()
    }
    
    convenience init(key : NSNumber , reason : String) {
        
        self.init()
        self.reasonKey = key
        self.reasonString = reason
    }
    
    convenience init(_ data : NSDictionary) {
        
        self.init()
        self.reasonKey = data["Key"] as? NSNumber ?? -1
        self.reasonString = data["Value"] as? String ?? ""
    }
    
    required convenience init(coder decoder: NSCoder) {
        
        self.init()
        if (decoder.decodeObject(forKey: "reasonKey") != nil) {
            self.reasonKey = decoder.decodeObject(forKey: "reasonKey") as! NSNumber
        }
        if (decoder.decodeObject(forKey: "reasonString") != nil) {
            self.reasonString = decoder.decodeObject(forKey: "reasonString") as! String
        }
    }
    func encode(with coder: NSCoder) {
        
        coder.encode(self.reasonKey, forKey: "reasonKey")
        coder.encode(self.reasonString, forKey: "reasonString")
    }
    
}

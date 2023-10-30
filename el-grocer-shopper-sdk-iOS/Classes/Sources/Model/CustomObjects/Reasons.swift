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
        self.reasonKey = decoder.decodeObject(of: [ NSNumber.self], forKey: "reasonKey") as? NSNumber ?? NSNumber.init(value: 0)
        self.reasonString = decoder.decodeObject(of: [ NSString.self], forKey: "reasonString") as? String ?? ""
      
    }
    func encode(with coder: NSCoder) {
        
        coder.encode(self.reasonKey, forKey: "reasonKey")
        coder.encode(self.reasonString, forKey: "reasonString")
    }
    
}

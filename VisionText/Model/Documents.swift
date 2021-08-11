//
//  Documents.swift
//  VisionText
//
//  Created by Jared Kozar on 7/9/21.
//

import UIKit

class Documents: NSObject, NSCoding {
    var thumbnail: String
    var name: String = ""
    var date: String = ""
    var isStarred: Bool
    var uuid:String
    
    init(thumbnail: String, name: String, date: String, isStarred: Bool, uuid: String) {
        self.thumbnail = thumbnail
        self.name = name
        self.date = date
        self.isStarred = isStarred
        self.uuid = uuid
    }
    
    required init(coder aDecoder: NSCoder) {
        thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as? String ?? ""
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        date = aDecoder.decodeObject(forKey: "date") as? String ?? ""
        isStarred = ((aDecoder.decodeBool(forKey: "isStarred") as? Bool)!)
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(thumbnail, forKey: "thumbnail")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(isStarred, forKey: "isStarred")
        aCoder.encode(uuid, forKey: "uuid")
    }
    
}

//
//  Extension.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/25/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
    
    var length:Int{
        return characters.count
    }
    
    subscript (i: Int, j: Int)->NSRange{
        return NSRange(location: i, length: j)
    }
}

extension NSMutableString{
    
    subscript (i: Int) -> String {
        return String(self.characterAtIndex(i))
    }
    
    subscript (i: Int, j: Int)->NSRange{
        return NSRange(location: i, length: j)
    }
}
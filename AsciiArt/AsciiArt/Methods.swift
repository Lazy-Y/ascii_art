//
//  Methods.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/22/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation
import Darwin

func arrayFromContentsOfFileWithName(fileName: String) -> NSMutableString? {
    do {
        let content = try NSMutableString(contentsOfFile:"/Users/ZhenyangZhong/Desktop/" + fileName, encoding: NSUTF8StringEncoding)
        return content//.componentsSeparatedByString("\n")
    }
    catch _ as NSError {
        return nil
    }
}

func loadTemplate()->Array<Array<String>>{
    var retVal = Array<Array<String>>()
    let content = try! NSString(contentsOfFile: "template.txt", encoding: NSUTF8StringEncoding)
    let source = content.componentsSeparatedByString("\n&\n")
    for item in source{
        var variable = Array<String>()
        let temp = item.componentsSeparatedByString("\n")
        for line in temp{
            variable.append(line)
        }
        retVal.append(variable)
    }
    return retVal
}

func parseType(inout content: NSMutableString)->String{
    removeSome(&content, patternString: "\\\\\n", replace: "`")
    let pattern = try! NSRegularExpression(pattern: "#([^\"\n]|(\"[^\"\n]*\"))*\n", options: [])
    let matches = pattern.matchesInString(content as String, options: [], range: content[0,content.length])
    var str = ""
    for match in matches{
        str.appendContentsOf(content.substringWithRange(match.range))
    }
    removeSome(&content, patternString: pattern.pattern)
    str.appendContentsOf("\n\n")
    var newStr = NSMutableString(string: str)
    removeSome(&newStr, patternString: "`", replace: "\\\\\n")
    return newStr as String
}

func removeNonsense(inout content: NSMutableString)->NSMutableString{
    var commentText = NSMutableString()
    var pattern = "//.*(\n)?"
    var re = try! NSRegularExpression(pattern: pattern, options: [])
    var matches = re.matchesInString(content as String, options: [], range: NSRange(location: 0, length: content.length))
    for match in matches{
        let str = content.substringWithRange(match.range)
        commentText.appendString(str)
    }
    removeSome(&content, patternString: pattern)
    removeSome(&content, patternString: "[\n\t\r]")
    pattern = "/\\*.*\\*/"
    re = try! NSRegularExpression(pattern: pattern, options: [])
    matches = re.matchesInString(content as String, options: [], range: NSRange(location: 0, length: content.length))
    for match in matches{
        let str = content.substringWithRange(match.range)
        commentText.appendString(str)
    }
    removeSome(&content, patternString: pattern)
    removeSome(&content, patternString: "\\\\", replace: "\\\\")
    
    removeSome(&commentText, patternString: "[^a-zA-Z0-9]", replace: "")
    return commentText.length > 0 ? commentText : generateComments()
}

func generateComments()->NSMutableString{
    let str = "Q W E R T Y U I O P A S D F G H J K L Z X C V B N M q w e r t y u i o p a s d f g h j k l z x c v b n m 1 2 3 4 5 6 7 8 9 0"
    let arr = str.componentsSeparatedByString(" ")
    let retVal = NSMutableString()
    srand48(0)
    for _ in 0..<100{
        retVal.appendString(arr[(Int(arc4random_uniform(62)))])
    }
    return retVal
}

func removeSome(inout content : NSMutableString, patternString : String, replace : String = " "){
    let pattern = try! NSRegularExpression(pattern: patternString, options: [])
    pattern.replaceMatchesInString(content, options: [], range: NSRange(location: 0, length: content.length), withTemplate: replace)
}

func combineAllString(inout arr:Array<Token>){
    for (var i = 0; i < arr.count-2; i++){
        if arr[i] is MutableCString && arr[i+1].val == "+" && arr[i+2] is MutableCString{
            (arr[i] as! MutableCString).combineString(arr[i+2].val)
            arr.removeAtIndex(i+1)
            arr.removeAtIndex(i+1)
            i--
        }
    }
}

func optimizeCode(inout arr:Array<Token>){
    combineAllString(&arr)
}

func printTokenArray(arr:Array<Token>){
    for token in arr{
        print(token,token.val)
    }
}

func parseContent(inout content : NSMutableString)->(Array<Token>,NSMutableString){
    let commentText = removeNonsense(&content)
    var arr = Array<Token>()
    while let token = Token.Consume(&content){
        arr.append(token)
    }
    optimizeCode(&arr)
    return (arr,commentText)
}
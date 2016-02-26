//
//  Output.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/24/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation

internal class Comment: NSObject {
    private var comment:NSMutableString!
    private var index = 0
    required init(content:NSMutableString) {
        comment = content
    }
    func getString(var length:Int)->NSMutableString{
        if index + length <= comment.length{
            let str = comment.substringWithRange(NSRange(location: index, length: length))
            index += length
            return NSMutableString(string: str)
        }
        else {
            var str = comment.substringWithRange(NSRange(location: index, length: comment.length-index))
            length-=comment.length-index
            index = 0
            str.appendContentsOf(getString(length) as String)
            return NSMutableString(string: str)
        }
    }
}

internal class Tokens: NSObject {
    private var tokenArray:Array<Token>!
    private var index = 0
    var finished:Bool{
        return index >= tokenArray.count
    }
    required init(arr:Array<Token>) {
        tokenArray = arr
    }
    var peek:NSMutableString{
        return tokenArray[index].val
    }
    var peekNextLength:Int{
        return index+1 < tokenArray.count ? tokenArray[index+1].val.length : 0
    }
    func consume(){
        index++
    }
    func shouldHaveSpace()->Bool{
        return index+1 < tokenArray.count ? tokenArray[index] is Type && tokenArray[index+1] is Type : false
    }
    func isSpecialType()->Bool{
        return tokenArray[index] is Type
    }
}

internal class Template: NSObject{
    private var template : Array<String>!
    private(set) var output = Array<String>()
    private(set) var line = 0
    private(set) var index = 0
    private var num = 0
    private let nonSpace = try! NSRegularExpression(pattern: "[^ ]", options: [])
    private let space = try! NSRegularExpression(pattern: " ", options: [])
    private var tokens : Tokens!
    private var comments : Comment!
    
    var endLine:Bool{
        return index >= currLine.length
    }
    var endTempate:Bool{
        return endLine && line-20*num == 17
    }
    var currLine:String{
        return template[line-20*num]
    }
    var matchRange:NSRange{
        return NSRange(location: index,length: currLine.length - index)
    }
    
    required init(var input:NSMutableString, t:Tokens, comments : Comment) {
        self.comments = comments
        tokens = t
        removeSome(&input, patternString: "[^a-zA-Z0-9]")
        let str = input.uppercaseString
        let templates = loadTemplate()
        var inputTemplates = Array<String>(count: 18, repeatedValue: "")
        for char in str.utf8{
            var index = 0
            if char > 60{
                index = Int(char) - 65
            }
            else if Int(char) == 32{
                index = 36
            }
            else {
                index = Int(char) - 48 + 26
            }
            for i in 0..<16{
                inputTemplates[i+1].appendContentsOf("  " + templates[index][i] + "  ")
            }
        }
        let temp = String(count: inputTemplates[1].length, repeatedValue: Character(" "))
        inputTemplates[0] = temp
        inputTemplates[17] = temp
        template = inputTemplates
        output.append("")
    }
    
    private func autoAdvance(){
        let match = space.firstMatchInString(currLine, options: [], range: matchRange)
        if let match = match{
            let length = match.range.location - index
            index = match.range.location
            output[line].appendContentsOf(String(count: length, repeatedValue: Character(" ")))
        }
    }
    
    internal func getLength()->Int{
        let match = nonSpace.firstMatchInString(currLine, options: [], range: matchRange)
        if let match = match{
            return match.range.location - index
        }
        else {
            return currLine.length - index
        }
    }
    
    private func fillType(){
        finishCurrLine()
        let arr = tokens.peek.componentsSeparatedByString(" ")
        for i in 0..<arr.count{
            fillWord(arr[i], isEnd: i == arr.count-1)
        }
        finishCurrLine()
    }
    
    private func fillWord(str:String, isEnd:Bool){
        let length = getLength()
        if length > str.length+1{
            index+=str.length
            output[line].appendContentsOf(str+" ")
        }
        else if length == str.length+1{
            if index+str.length+1 == currLine.length{
                if isEnd{
                    output[line].appendContentsOf(str)
                    autoEndl()
                }
                else {
                    output[line].appendContentsOf(String(count: str.length, repeatedValue: Character(" ")))
                    index+=str.length+1
                }
            }
            else {
                output[line].appendContentsOf(str + " ")
                index+=str.length+1
            }
        }
        else if length == str.length{
            if index+length == currLine.length{
                if length < 5{
                    output[line].appendContentsOf(String(count: length-1, repeatedValue: Character(" "))+"\\")
                }
                else {
                    output[line].appendContentsOf("/*"+((comments.getString(length-5)) as String)+"*/\\")
                }
                index+=length
                autoEndl()
                fillWord(str, isEnd: isEnd)
            }
            else{
                output[line].appendContentsOf(str)
                index+=length
                autoAdvance()
            }
        }
        else {
            if length < 4{
                output[line].appendContentsOf(String(count: length, repeatedValue: Character(" ")))
            }
            else {
                output[line].appendContentsOf("/*"+((comments.getString(length-4)) as String)+"*/")
            }
            index+=length
            if index == currLine.length && !isEnd{
                output[line].replaceRange(output[line].getRange(index-1, j: 1), with: "\\")
                autoEndl()
            }
            else {
                autoAdvance()
            }
            fillWord(str, isEnd: isEnd)
        }
    }
    
    private func finishCurrLine(){
        if index == 0{
            return
        }
        let length = getLength()
        if length == 0{
            autoAdvance()
        }
        if getLength() > 2{
            if index+length != currLine.length{
                output[line].appendContentsOf("/*")
                index+=2
                for i in index..<currLine.length-2{
                    if currLine[i] == " "{
                        output[line].appendContentsOf(comments.getString(1) as String)
                    }
                    else {
                        output[line].appendContentsOf(" ")
                    }
                }
                output[line].appendContentsOf("*/")
            }
            else if length > 3{
                output[line].appendContentsOf("/*"+(comments.getString(length-4) as String) + "*/")
            }
            else{
                output[line].appendContentsOf(String(count: length, repeatedValue: Character(" ")))
            }
            index = currLine.length
            autoEndl()
        }
        else {
            output[line].appendContentsOf(String(count: length, repeatedValue: Character(" ")))
            index+=length
            if endLine{
                autoEndl()
                return
            }
            finishCurrLine()
        }
    }
    
    internal func fill(var word:NSMutableString, consume:Bool = true)->Bool{
        if consume && tokens.isSpecialType(){
            fillType()
            tokens.consume()
            return true
        }
        var retVal = true
        if (getLength() > word.length && tokens.shouldHaveSpace()) || (word.substringToIndex(1) == "/" && index > 0 && output[line][index-1] == "*"){
            if word.length == 2{
                word = "  "
                retVal = false
            }
            else {
                word = NSMutableString(string: " " + (word.substringToIndex(word.length-1) as String))
            }
        }
        if getLength() >= word.length{
            index += word.length
            if getLength() == 1 && tokens.peekNextLength != 1{
                index -= word.length
                return false
            }
            output[line].appendContentsOf(word as String)
            if consume{
                tokens.consume()
            }
            autoEndl()
            return retVal
        }
        else {
            return false
        }
    }
    
    private func autoEndl(){
        if getLength() == 0{
            if endTempate{
                num++
                line+=3
                index = 0
                output.append("")
                output.append("")
                output.append("")
            }
            else if endLine{
                line++
                index = 0
                output.append("")
            }
            else{
                autoAdvance()
            }
        }
    }
}

class ArtManager: NSObject {
    private var comments:Comment!
    private var tokens:Tokens!
    private var template:Template!
    private var include:String!
    required init(input_tokens:Array<Token>, input_comments:NSMutableString, input:NSMutableString) {
        tokens = Tokens(arr: input_tokens)
        comments = Comment(content: input_comments)
        template = Template(input: input, t: tokens, comments: comments)
    }
    func makeArt()->String{
        while !tokens.finished{
            let text = tokens.peek
            if !template.fill(text){
                let length = template.getLength()
                if length == 1{
                    template.fill(" ", consume: false)
                    continue
                }
                let str = "/*" + (comments.getString(length-2) as String)
                if !template.fill(NSMutableString(string: str), consume: false){
//                    print("Fail",str,template.getLength())
                    continue
                }
                if tokens.finished{
                    while !template.fill("*/", consume: false){
                        template.fill(comments.getString(template.getLength()), consume: false)
                    }
                    break
                }
                else {
                    while !template.fill(NSMutableString(string: "*/" + (tokens.peek as String)), consume: true){
                        template.fill(comments.getString(template.getLength()), consume: false)
                    }
                }
            }
        }
        return template.output.joinWithSeparator("\n")
    }
}
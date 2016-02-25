//
//  Token.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/22/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation

internal func startMatch(let content : NSMutableString, patternString : String)->NSString?{
    if content.length < 1{
        return nil
    }
    while content.substringToIndex(1) == " "{
        content.deleteCharactersInRange(NSRange(location: 0,length: 1))
        if content.length < 1{
            return nil
        }
    }
    let pattern = try! NSRegularExpression(pattern: patternString, options: [])
    let match = pattern.firstMatchInString(content as String, options: [], range: NSRange(location: 0, length: content.length))
    if match == nil || match!.range.location != 0{
        Token.tempMatch = nil
        return nil
    }
    else {
        Token.tempMatch = NSMutableString(UTF8String: content.substringToIndex(match!.range.length))
        return Token.tempMatch
    }
}

internal func consumeToken(inout content: NSMutableString)->NSMutableString{
    let temp = Token.tempMatch!
    Token.tempMatch = nil
    content.deleteCharactersInRange(NSRange(location: 0, length: temp.length))
    return temp
}

class Token : NSObject {
    internal(set) var val:NSMutableString!
    internal static var tempMatch:NSMutableString?
    class var pattern:String { get { return "" } }
    init (str:NSMutableString){
        val = str
    }
    internal class func Match(let content:NSMutableString)->Bool{
        return startMatch(content, patternString: pattern) != nil
    }
    class func Consume(inout content:NSMutableString)->Token?{
        if let token = Operator.Consume(&content){
            return token
        }
        else if let token = Type.Consume(&content){
            return token
        }
        else if let token = Constant.Consume(&content){
            return token
        }
        else if let token = Variable.Consume(&content){
            return token
        }
        else {
            return nil
        }
    }
}

class Operator: Token {
    override class func Consume(inout content:NSMutableString)->Operator?{
        if Operator2.Match(content){
            return Operator2.Consume(&content)
        }
        else {
            return Operator1.Consume(&content)
        }
    }
}

class Operator1: Operator {
//    [*=+-/%^&!;:~?,|\\\\\\.\\(\\)\\{\\}\\[\\]]
    override class var pattern:String { get { return "[^a-zA-Z0-9\'\"<]" } }
    override class func Consume(inout content:NSMutableString)->Operator1?{
        if !Match(content){
            return nil
        }
        return Operator1(str: consumeToken(&content))
    }
}

class Operator2: Operator {
    override class var pattern:String { get { return "(==)|(\\+=)|(-=)|(\\+\\+)|(--)|(!=)|(&&)|(\\|\\|)|(<<)|(>>)|(->)|(::)" } }
    override class func Consume(inout content:NSMutableString)->Operator2?{
        if !Match(content){
            return nil
        }
        return Operator2(str: consumeToken(&content))
    }
}

class Type : Token{
    override class var pattern:String { get { return "#((include)|(ifn?def)|(pragma)|(define)|endif)" } }
    override class func Consume(inout content:NSMutableString)->Type?{
        if !Match(content){
            return nil
        }
        return Type(str: consumeToken(&content))
    }
}

class Variable : Token{
    override class var pattern:String { get { return "[a-zA-Z_][a-zA-Z0-9_]* ?" } }
    internal func rename(name: NSMutableString) {
        val = name
    }
    override class func Consume(inout content:NSMutableString)->Variable?{
        if !Match(content){
            return nil
        }
        return Variable(str: consumeToken(&content))
    }
}

class Constant: Token {
    override class func Consume(inout content:NSMutableString)->Constant?{
        if let char = Char.Consume(&content){
            return char
        }
        else if let number = Number.Consume(&content){
            return number
        }
        else if let cstring = CString.Consume(&content){
            return cstring
        }
        else {
            return nil
        }
    }
}

class Char: Constant {
    override class var pattern:String { get { return "'[a-zA-Z0-9]'" } }
    override class func Consume(inout content:NSMutableString)->Char?{
        if !Match(content){
            if !SpecialChar.Match(content){
                return nil
            }
            else {
                return SpecialChar.Consume(&content)
            }
        }
        return Char(str: consumeToken(&content))
    }
}

class SpecialChar : Char {
    override class var pattern:String { get { return "'\\\\[t\"s\\abfnrv\'0]'"} }
    override class func Consume(inout content:NSMutableString)->SpecialChar?{
        if !Match(content){
            return nil
        }
        return SpecialChar(str: consumeToken(&content))
    }
}

class Number: Constant {
    override class var pattern:String { get { return "\\d+(\\.\\d+f?)?"} }
    override class func Consume(inout content:NSMutableString)->Number?{
        if !Match(content){
            return nil
        }
        return Number(str: consumeToken(&content))
    }
}

class CString: Constant {
    override class var pattern:String { get { return "<[^ (]*>"} }
    override class func Consume(inout content:NSMutableString)->CString?{
        if !Match(content){
            return MutableCString.Consume(&content)
        }
        return CString(str: consumeToken(&content))
    }
}

class MutableCString: CString {
//  \"([^\\\"]|\\n|\\t)*\"
//    \"[^\"]*\"
    override class var pattern:String { get { return "\"([^\\\"]|\\n|\\t)*\""} }
    override class func Consume(inout content:NSMutableString)->CString?{
        if !Match(content){
            return nil
        }
        return MutableCString(str: consumeToken(&content))
    }
    func combineString(other:NSString){
        val.deleteCharactersInRange(NSRange(location: val.length-1, length: 1))
        val.appendString(other.substringFromIndex(1) as String)
    }
}
//
//  main.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/22/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation


if var content = arrayFromContentsOfFileWithName("try.cpp"){
    let include = parseType(&content)
    let (arr,comments) = parseContent(&content)
    let artManager = ArtManager(include: include, input_tokens: arr, input_comments: comments, input: "hello")
    print(artManager.makeArt())
//    for item in arr{
//        print(item, item.val)
//    }
}
else {
    print("Cannnot find the file")
}

//var hello:NSMutableString = "\"Point size %d is unsupported\""
//print(Token.Consume(&hello)?.val)
//print(hello)

//loadTemplate()

//Template(input: NSMutableString(string: "hello"))
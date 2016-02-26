//
//  main.swift
//  AsciiArt
//
//  Created by 钟镇阳 on 2/22/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import Foundation


// regular mode
//print("Input the path of the file, default path is Desktop. The generated file will be on the Desktop")
//if var content = arrayFromContentsOfFileWithName(cin()){
//    while true{
//        print("Input your word")
//        let input = cin()
//        if input.length < 2{
//            print("Input has to contain at least 2 characters, please try again")
//        }
//        else {
//            let include = parseType(&content)
//            let (arr,comments) = parseContent(&content)
//            let artManager = ArtManager(include: include, input_tokens: arr, input_comments: comments, input: NSMutableString(string: input))
//            writeToFile(artManager.makeArt())
//            break
//        }
//    }
//}
//else {
//    print("Cannnot find the file")
//}




// testing mode
if var content = arrayFromContentsOfFileWithName("try.cpp"){
    let (arr,comments) = parseContent(&content)
    let artManager = ArtManager(input_tokens: arr, input_comments: comments, input: NSMutableString(string: "interview"))
    print(artManager.makeArt())
}
else {
    print("Cannnot find the file")
}
//
//  GLService.swift
//  GuLu
//
//  Created by 张洋威 on 16/2/19.
//  Copyright © 2016年 YangWei Zhang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Kanna

let fuliBaseUrl = "http://www.dbmeinv.com/dbgroup/rank.htm?pager_offset="
let itemBaseUrl = "http://www.dbmeinv.com/dbgroup/show.htm?cid="
let meipaiBaseUrl  = "http://www.dbmeinv.com/dbgroup/videos.htm?pager_offset="

struct MeiPaiLinks {
    var imageUrl: String?
    var htmlUrl: String?
}

func cidByItemNumber(number: Int) -> String {
    switch number{
    case 0:
        return "0"
    case 1:
        return "2"
    case 2:
        return "6"
    case 3:
        return "7"
    case 4:
        return "3"
    case 5:
        return "4"
    case 6:
        return "5"
    default:
        return "0"
    }
}


func requestItemImages(type: String, page: Int, failure: (NSError? -> Void)?, completion: [String]? -> Void){
    let url = itemBaseUrl + type + "&pager_offset=" + "\(page)"
    Alamofire.request(.GET, url).validate().responseString { (response) -> Void in
        let isSuccess = response.result.isSuccess
        let html = response.result.value
        if isSuccess {
            var urls = [String]()
            if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)

                for node in doc.css("img"){
                    urls.append(node["src"]!)
                }
                if urls.count > 0 {
                    completion(urls)
                }
            }
        } else {
            if failure != nil {
                failure!(response.result.error)
            }
            
        }
    }
}

func requestFuliImages(page: Int, failure: (NSError? -> Void)?, completion: [String]? -> Void){
    let url = fuliBaseUrl + "\(page)"
    Alamofire.request(.GET, url).validate().responseString { (response) -> Void in
        let isSuccess = response.result.isSuccess
        let html = response.result.value
        if isSuccess {
            var urls = [String]()
            if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
  
                for node in doc.css("img"){
                    urls.append(node["src"]!)
                }
                if urls.count > 0 {
                    completion(urls)
                }
            }
        } else {
            if failure != nil {
                failure!(response.result.error)
            }
            
        }
    }
}

func requestMeiPai(page: Int, failure: (NSError? -> Void)?, completion: [MeiPaiLinks]? -> Void){
    let url = meipaiBaseUrl + "\(page)"
    Alamofire.request(.GET, url).validate().responseString { (response) -> Void in
        let isSuccess = response.result.isSuccess
        let html = response.result.value
        if isSuccess {

            var links = [MeiPaiLinks]()
            if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                for node in doc.css("a"){
                    if (node["target"] != nil &&  node["target"] == "_videos_detail") {
                        let innerNode = node.css("img").first
                        links.append(MeiPaiLinks(imageUrl: innerNode!["src"], htmlUrl: node["href"]))
                    }
                }
                if links.count > 0 {
                    completion(links)
                }
            }
        } else {
            if failure != nil {
                failure!(response.result.error)
            }
            
        }
    }
}

func requestVideo(url: String, failure: (NSError? -> Void)?, completion: String? -> Void){
    Alamofire.request(.GET, url).validate().responseString { (response) -> Void in
        let isSuccess = response.result.isSuccess
        let html = response.result.value
        
        if isSuccess {
            var videoUrl: String? = nil
            if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)

                for node in doc.css("source") {
                    if (node["src"]!.hasSuffix(".mp4")) {
                        videoUrl = node["src"]
                        break
                    }
                }
                
                if videoUrl == nil {
                    for node in doc.css("embed") {
                       videoUrl = handleVideoUrl(node["src"]!)
                    }
                }
                
                completion(videoUrl)
                
            }
        } else {
            if failure != nil {
                failure!(response.result.error)
            }
            
        }
    }
}

func handleVideoUrl(sourceUrl: String) -> String? {
    let f = "http://wscdn.miaopai.com/splayer2.0.8.swf?scid="
    let b = "&token=&autopause=false&fromweibo=false"
    if (sourceUrl.hasPrefix(f) && sourceUrl.hasSuffix(b)) {
        let range = Range(start: f.endIndex, end: sourceUrl.endIndex.advancedBy(-b.characters.count))
        return "http://gslb.miaopai.com/stream/" + sourceUrl.substringWithRange(range) + ".mp4"
    }
    return nil
}

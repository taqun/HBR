//
//  Hatena.swift
//  HBR
//
//  Created by taqun on 2015/06/23.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

enum HatenaCategory: String {
    case All            = "総合"
    case General        = "一般"
    case Social         = "世の中"
    case Economics      = "政治と経済"
    case Life           = "暮らし"
    case Knowledge      = "学び"
    case It             = "テクノロジー"
    case Fun            = "おもしろ"
    case Entertainment  = "エンタメ"
    case Anime          = "アニメとゲーム"
}

class HBRHatena: NSObject {
    
    static var Categories: [HatenaCategory] = [
        HatenaCategory.All, HatenaCategory.General, HatenaCategory.Social, HatenaCategory.Economics, HatenaCategory.Life,
        HatenaCategory.Knowledge, HatenaCategory.It, HatenaCategory.Fun, HatenaCategory.Entertainment, HatenaCategory.Anime
    ]
   
}

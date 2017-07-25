//
//  HighlightModel.swift
//  helloworld
//
//  Created by iOS Dev Log on 2017/7/18.
//  Copyright © 2017年 iOSDevLog. All rights reserved.
//

import Foundation
import Highlightr

class HighlightModel {
    let layoutManager = NSLayoutManager()
    let textStorage = CodeAttributedString()
    let textContainer = NSTextContainer(size: CGSize.zero)
    var highlightr : Highlightr!
    
    static let sharedInstance = HighlightModel()
    
    private init() {
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        highlightr = textStorage.highlightr
    }
    
    func invertColor(_ color: UIColor) -> UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red:1.0-r, green: 1.0-g, blue: 1.0-b, alpha: 1)
    }
}

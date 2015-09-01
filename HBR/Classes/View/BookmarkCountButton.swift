//
//  BookmarkCountButton.swift
//  HBR
//
//  Created by taku on 2015/09/02.
//  Copyright (c) 2015年 envoixapp. All rights reserved.
//

import UIKit

class BookmarkCountButton: UIButton {

    // MARK: Initialize
    
    init() {
        super.init(frame: CGRectZero)
        
        self.titleLabel?.font = UIFont.systemFontOfSize(17)
        
        self.backgroundColor = UIColor.clearColor()
        self.frame = CGRectMake(0, 0, 80, 28)
        self.layer.cornerRadius = 5.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private Method
    
    private func updateStyle() {
        if self.selected {
            self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.15), forState: UIControlState.Highlighted)
            
            self.backgroundColor = self.tintColor?.colorWithAlphaComponent(0.9)
            
        } else {
            self.setTitleColor(self.tintColor, forState: UIControlState.Normal)
            self.setTitleColor(self.tintColor!.colorWithAlphaComponent(0.15), forState: UIControlState.Highlighted)
            
            self.backgroundColor = UIColor.clearColor()
        }
    }
    
    private func adjustLayout() {
        self.sizeToFit()
        
        var frame = self.frame
        frame.size.width += 16.0
        frame.size.height = 28.0
        
        self.frame = frame
    }
    
    // MARK: Getter, Setter
    
    override var tintColor: UIColor? {
        set {
            super.tintColor = newValue
            
            self.updateStyle()
        }
        
        get {
            return super.tintColor
        }
    }
    
    var title: String {
        set {
            self.setTitle(newValue, forState: UIControlState.Normal)
            
            self.adjustLayout()
        }
        
        get {
            return self.title
        }
    }
    
    private var _selected: Bool = false
    
    override var selected: Bool {
        set {
            _selected = newValue
            
            self.updateStyle()
        }
        
        get {
            return _selected
        }
    }

}

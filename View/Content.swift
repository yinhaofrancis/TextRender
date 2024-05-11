//
//  Content.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/10.
//

import UIKit

public protocol Drawable{
    func draw(render:TROfflineRender)
}

public protocol Element{
    var frame:CGRect { get }
}
extension Element{
    public func enterElement(render:TROfflineRender){
        
    }
    
    public func leaveElement(render:TROfflineRender){
        
    }
}

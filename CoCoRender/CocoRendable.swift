//
//  CocoRendable.swift
//  CoCoRender
//
//  Created by FN-540 on 2024/5/21.
//

import Foundation

public protocol CocoRenderFrame{

    var frame:CGRect { get }
}

public protocol CocoContent{
    
    var contentMode:CocoContentMode { get }
    
    func render(frame:CGRect,render:CocoOfflineRender)
}

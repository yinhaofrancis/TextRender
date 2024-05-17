//
//  TRView.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/10.
//

import UIKit

public protocol TRRenderFrame{

    var frame:CGRect { get }
}

public protocol TRContent{
    
    var contentMode:TRContentMode { get }
    
    func render(frame:CGRect,render:TROfflineRender)
}

public protocol TRRenderable:TRRenderFrame{
    
    associatedtype T:TRContent
    
    var content:T { get }

}
extension TRRenderable{
    public func draw(render:TROfflineRender){
        self.draw(frame: self.frame, render: render)
    }
    public func draw(frame:CGRect, render:TROfflineRender){
        content.render(frame: frame, render: render)
    }
}

public struct TRView<T:TRContent>:TRRenderable{
        
    public var content: T
    
    public var frame: CGRect
    
    public init(content: T, frame: CGRect = .zero) {
        self.content = content
        self.frame = frame
    }
    
}

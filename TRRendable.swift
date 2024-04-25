//
//  TRRendable.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/25.
//

import Foundation
import CoreGraphics


public protocol TRRenderFrame{

    var frame:CGRect { get }
}

public protocol TRContent{
    
    var contentMode:TROfflineRender.ContentMode { get }
    
    func render(frame:CGRect,ctx:CGContext)
}

public protocol TRRenderable:TRRenderFrame{
    
    associatedtype T:TRContent
    
    var content:T { get }

}
extension TRRenderable{
    public func draw(ctx:CGContext){
        content.render(frame: self.frame, ctx: ctx)
    }
}

public struct TRView<T:TRContent>:TRRenderable{
    public var content: T
    
    public var frame: CGRect
    
    public init(content: T, frame: CGRect) {
        self.content = content
        self.frame = frame
    }
}

public struct TRVectorImage:TRContent{
    
    
    public var contentMode: TROfflineRender.ContentMode
    
    
    public var image:TRVerterImage
    
    public init(contentMode: TROfflineRender.ContentMode, image: TRVerterImage) {
        self.contentMode = contentMode
        self.image = image
    }
    
    public func render(frame: CGRect, ctx: CGContext) {
        let frame = TROfflineRender.contentMode(itemFrame: image.frame, containerFrame: frame, mode: contentMode)
        image.draw(ctx: ctx, frame: frame)
    }
}

public struct TRImage:TRContent{
    
    public var image:CGImage
    
    public var contentMode: TROfflineRender.ContentMode
    
    public init(image: CGImage, contentMode: TROfflineRender.ContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
    
    public func render(frame: CGRect, ctx: CGContext) {
        let frame = TROfflineRender.contentMode(itemFrame: CGRect(x: 0, y: 0, width: image.width, height: image.height), containerFrame: frame, mode: contentMode)
        ctx.draw(image, in: frame, byTiling: false)
    }
}

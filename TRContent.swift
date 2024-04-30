//
//  TRTextContent.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import Foundation
import CoreGraphics
import CoreText


extension CGColor:TRContent{
    public var contentMode: TROfflineRender.ContentMode {
        .scaleToFill
    }
    
    public func render(frame: CGRect, render:TROfflineRender) {
        render.context.saveGState()
        render.context.setFillColor(self)
        render.context.fill([frame])
        render.context.restoreGState()
    }
    
}

public struct TRVectorImage:TRContent{
    
    
    public var contentMode: TROfflineRender.ContentMode
    
    
    public var image:TRPDFImage
    
    public init(contentMode: TROfflineRender.ContentMode, image: TRPDFImage) {
        self.contentMode = contentMode
        self.image = image
    }
    
    public func render(frame: CGRect, render:TROfflineRender) {
        let frame = TROfflineRender.contentMode(itemFrame: image.frame, containerFrame: frame, mode: contentMode)
        image.draw(ctx: render.context, frame: frame)
    }
}

public struct TRImage:TRContent{
    
    public var image:CGImage
    
    public var contentMode: TROfflineRender.ContentMode
    
    public init(image: CGImage, contentMode: TROfflineRender.ContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
    
    public func render(frame: CGRect,render:TROfflineRender) {
        let frame = TROfflineRender.contentMode(itemFrame: CGRect(x: 0, y: 0, width: image.width, height: image.height), containerFrame: frame, mode: contentMode)
        render.context.draw(image, in: frame, byTiling: false)
    }
}


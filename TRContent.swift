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
    public var contentMode: TRContentMode {
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
    
    
    public var contentMode: TRContentMode
    
    
    public var image:TRPDFImage
    
    public var tintColor:CGColor?
    
    public init(contentMode: TRContentMode, image: TRPDFImage) {
        self.contentMode = contentMode
        self.image = image
    }
    
    public func render(frame: CGRect, render:TROfflineRender) {
        let frame = TROfflineRender.contentModeFrame(itemFrame: image.frame, containerFrame: frame, mode: contentMode)
        render.context.saveGState()
        if let color = self.tintColor {
            render.context.setFillColor(color)
            render.context.fill([frame])
            render.context.setBlendMode(.destinationIn)
            render.context.beginTransparencyLayer(in: frame, auxiliaryInfo: nil)
            image.draw(ctx: render.context, frame: frame)
            render.context.endTransparencyLayer()
        }else{
            image.draw(ctx: render.context, frame: frame)
        }
        render.context.restoreGState()
    }
}

public struct TRImage:TRContent{
    
    public var image:CGImage
    
    public var tintColor:CGColor?
    
    public var contentMode: TRContentMode
    
    public init(image: CGImage, contentMode: TRContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
    
    public func render(frame: CGRect,render:TROfflineRender) {
        let frame = TROfflineRender.contentModeFrame(itemFrame: CGRect(x: 0, y: 0, width: image.width, height: image.height), containerFrame: frame, mode: contentMode)
        
        render.context.saveGState()
        
        if let color = self.tintColor {
            render.context.setFillColor(color)
            render.context.fill([frame])
            render.context.setBlendMode(.destinationIn)
            render.context.beginTransparencyLayer(in: frame, auxiliaryInfo: nil)
            render.context.draw(image, in: frame, byTiling: false)
            render.context.endTransparencyLayer()
        }else{
            render.context.draw(image, in: frame, byTiling: false)
        }
        render.context.restoreGState()
    }
}


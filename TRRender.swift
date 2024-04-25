//
//  TRRender.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/25.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit


public class TROfflineRender{
    public let width:Int
    public let height:Int
    public let context:CGContext
    public let scale:Int
    public init(width: Int, height: Int,scale:Int) throws {
        self.width = width
        self.height = height
        self.scale = scale
        guard let ctx = CGContext(data: nil, width: width * scale, height: height * scale, bitsPerComponent: 8, bytesPerRow: width * scale * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            throw NSError(domain: "create cgctx fail", code: 0)
        }
        self.context = ctx
    }
    
    public func draw(call:(TROfflineRender)->Void)->CGImage?{
        self.context.scaleBy(x: CGFloat(self.scale), y: CGFloat(self.scale))
        call(self)
        return self.context.makeImage()
    }
    
    public func layer(size:CGSize,call:(CGContext)->Void)->CGLayer?{
        guard let layer = CGLayer(self.context, size: size, auxiliaryInfo: nil) else { return nil }
        guard let ctx = layer.context else { return nil }
        layer.context?.scaleBy(x: CGFloat(self.scale), y: CGFloat(self.scale))
        call(ctx)
        return layer
    }
}


// contentMode

extension TROfflineRender {
    fileprivate static func centerAndScale(percentX:CGFloat = 0.5,percentY:CGFloat = 0.5,containerFrame: CGRect, itemFrame: CGRect, ratioX: CGFloat,ratioY:CGFloat)->CGAffineTransform {
        let deltaX = containerFrame.width * percentX  - itemFrame.width * ratioX * percentX +  containerFrame.minX - itemFrame.minX
        let deltaY = containerFrame.height *  percentY - itemFrame.height * ratioY * percentY + containerFrame.minY - itemFrame.minY
        return CGAffineTransformMakeTranslation(deltaX, deltaY).scaledBy(x: ratioX, y: ratioY)
    }
    
    public enum ContentMode{
        case scaleToFill
        case scaleAspectFit(CGFloat)
        case scaleAspectFill
        case center(CGFloat)
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case percent(x:CGFloat,y:CGFloat,scaleX:CGFloat,scaleY:CGFloat)
    }
    
    public static func contentMode(itemFrame:CGRect,containerFrame:CGRect,mode:ContentMode)->CGRect{
        switch(mode){
        case .scaleToFill:
            return self.scaleToFill(itemFrame: itemFrame, containerFrame: containerFrame)
        case .scaleAspectFit(let p):
            return self.scaleAspectFit(itemFrame: itemFrame, containerFrame: containerFrame, percent: p)
        case .scaleAspectFill:
            return self.scaleAspectFill(itemFrame: itemFrame, containerFrame: containerFrame)
        case .center(let scale):
            return self.center(itemFrame: itemFrame, containerFrame: containerFrame, scale: scale)
        case .top:
            return self.top(itemFrame: itemFrame, containerFrame: containerFrame)
        case .bottom:
            return self.bottom(itemFrame: itemFrame, containerFrame: containerFrame)
        case .left:
            return self.left(itemFrame: itemFrame, containerFrame: containerFrame)
        case .right:
            return self.right(itemFrame: itemFrame, containerFrame: containerFrame)
        case .topLeft:
            return self.topLeft(itemFrame: itemFrame, containerFrame: containerFrame)
        case .topRight:
            return self.topRight(itemFrame: itemFrame, containerFrame: containerFrame)
        case .bottomLeft:
            return self.bottomLeft(itemFrame: itemFrame, containerFrame: containerFrame)
        case .bottomRight:
            return self.bottomRight(itemFrame: itemFrame, containerFrame: containerFrame)
        case .percent(x: let x, y: let y, scaleX: let scaleX, scaleY: let scaleY):
            let transform =  self.centerAndScale(percentX: x, percentY: y, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: scaleX, ratioY: scaleY)
            return itemFrame.applying(transform)
        }
    }
    
    public static func scaleAspectFill(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let ratio = max(containerFrame.width / itemFrame.width, containerFrame.height / itemFrame.height)
        let transform = centerAndScale( containerFrame: containerFrame, itemFrame: itemFrame, ratioX: ratio, ratioY: ratio)
        return itemFrame.applying(transform)
    }
    public static func scaleAspectFit(itemFrame:CGRect,containerFrame:CGRect,percent:CGFloat)->CGRect{
        let ratio = min(containerFrame.width / itemFrame.width, containerFrame.height / itemFrame.height)
        let transform = centerAndScale(percentX:percent,percentY: percent, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: ratio, ratioY: ratio)
        return itemFrame.applying(transform)
    }
    public static func scaleToFill(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        
        let ratioX = containerFrame.width / itemFrame.width
        let ratioy = containerFrame.height / itemFrame.height
        let tra = centerAndScale(containerFrame: containerFrame, itemFrame: itemFrame, ratioX: ratioX, ratioY: ratioy)
        return itemFrame.applying(tra)
    }
    
    public static func center(itemFrame:CGRect,containerFrame:CGRect,scale:CGFloat)->CGRect{
        let item = centerAndScale(containerFrame: containerFrame, itemFrame: itemFrame, ratioX: scale, ratioY: scale)
        return itemFrame.applying(item)
    }
    
    public static func top(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentY:0, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    public static func bottom(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentY:1, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    
    public static func left(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX:0, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    public static func right(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX:1, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    
    public static func topLeft(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX: 0,percentY:0, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    public static func bottomLeft(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX: 0,percentY:1, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    
    public static func topRight(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX: 1,percentY:0, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
    public static func bottomRight(itemFrame:CGRect,containerFrame:CGRect)->CGRect{
        let item = centerAndScale(percentX:1,percentY:1, containerFrame: containerFrame, itemFrame: itemFrame, ratioX: 1, ratioY: 1)
        return itemFrame.applying(item)
    }
}



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


/// cpu离线渲染
public class TROfflineRender{
    public let width:CGFloat
    public let height:CGFloat
    public var context:CGContext{
        layer?.context ?? origin
    }
    private var origin:CGContext
    public let scale:CGFloat
    private(set) public var layer:CGLayer?
    /// 创建离线渲染
    /// - Parameters:
    ///   - width: 宽
    ///   - height: 高
    ///   - scale: 缩放倍数
    ///   - context: 上下文
    ///   - layer: 图层
    init(width: CGFloat, height: CGFloat,scale:CGFloat,context:CGContext,layer:CGLayer?){
        self.width = width
        self.height = height
        self.scale = scale
        self.origin = context
        self.layer = layer
    }
    /// 创建离线渲染
    /// - Parameters:
    ///   - width: 宽
    ///   - height: 高
    ///   - scale: 缩放倍数
    public init(width: CGFloat, height: CGFloat,scale:CGFloat) throws {
        self.width = width
        self.height = height
        self.scale = scale
        guard let ctx = CGContext(data: nil, width: Int(ceil(width * scale)), height: Int(ceil(height * scale)), bitsPerComponent: 8, bytesPerRow: Int(ceil(width * scale * 4)), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            throw NSError(domain: "create cgctx fail", code: 0)
        }
        ctx.scaleBy(x: self.scale, y: self.scale)
        self.origin = ctx
    }
    
    /// 执行绘制
    /// - Parameter call: 绘制回调
    /// - Returns: 绘制的pixel image
    public func draw(call:(TROfflineRender)->Void)->CGImage?{
        call(self)
        guard let rawimage = self.context.makeImage() else { return nil }
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else { return rawimage }
        guard let dest = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil) else { return rawimage }
        CGImageDestinationAddImage(dest, rawimage, nil)
        CGImageDestinationFinalize(dest)
        guard let source = CGImageSourceCreateWithData(data, nil) else { return rawimage }
        return CGImageSourceCreateImageAtIndex(source, 0, nil) ?? rawimage
    }

    var screenTransform:CGAffineTransform {
        CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -CGFloat(self.height))
    }
    var mathTransform:CGAffineTransform {
        CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -CGFloat(self.height)).inverted()
    }
    public var screenCoodinate:Bool = false{
        didSet{
            if oldValue != screenCoodinate{
                if(screenCoodinate == true){
                    self.context.concatenate(screenTransform)
                }else{
                    self.context.concatenate(mathTransform)
                }
            }
        }
    }
    public func draw(size:CGSize,call:(TROfflineRender)->Void)->CGLayer?{
        let realSize = CGSize(width: size.width * CGFloat(self.scale), height: size.height * CGFloat(self.scale))
        let layer = TROfflineRender(width: realSize.width, height: realSize.height, scale: self.scale, context: self.context, layer: CGLayer(self.context, size: realSize, auxiliaryInfo: nil))
        layer.screenCoodinate = self.screenCoodinate
        layer.context.scaleBy(x: CGFloat(self.scale), y: CGFloat(self.scale))
        call(layer)
        return layer.layer
    }
}


// contentMode
public enum TRContentMode{
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



extension TROfflineRender {
    fileprivate static func centerAndScale(percentX:CGFloat = 0.5,percentY:CGFloat = 0.5,containerFrame: CGRect, itemFrame: CGRect, ratioX: CGFloat,ratioY:CGFloat)->CGAffineTransform {
        let deltaX = containerFrame.width * percentX  - itemFrame.width * ratioX * percentX +  containerFrame.minX - itemFrame.minX
        let deltaY = containerFrame.height *  percentY - itemFrame.height * ratioY * percentY + containerFrame.minY - itemFrame.minY
        return CGAffineTransformMakeTranslation(deltaX, deltaY).scaledBy(x: ratioX, y: ratioY)
    }
    
    public static func contentModeFrame(itemFrame:CGRect,containerFrame:CGRect,mode:TRContentMode)->CGRect{
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
    public func transformCoodination(leftTop:CGPoint)->CGPoint{
        let transform = self.transformCoodinationTransform()
        return leftTop.applying(transform)
    }
    public func transformCoodinationTransform()->CGAffineTransform{
        return CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -CGFloat(self.height))
    }
    public func transformCoodinationToLeftTopTransform()->CGAffineTransform{
        return CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -CGFloat(self.height))
    }
}
extension TROfflineRender{
    public static func registerFont(url:URL)->String?{
        guard let dat = CGDataProvider(url: url as CFURL) else { return nil }
        guard let cgfont = CGFont(dat) else { return nil }
        guard let name = cgfont.fullName as? String else { return nil }
        var err:Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgfont, &err)
        if(err != nil){
            return nil
        }
        return name
    }
}
func +(_ p1:CGPoint,_ p2:CGPoint)->CGPoint{
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

func -(_ p1:CGPoint,_ p2:CGPoint)->CGPoint{
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

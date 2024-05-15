//
//  Modify.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/15.
//

import UIKit


public protocol Modify:FrameDrawable{
    associatedtype D:FrameDrawable
    var content:D { get set }
}

public struct Corner<T:FrameDrawable>:Modify{
    public var contentSize: CGSize{
        get{
            self.content.contentSize
        }
    }
    
    
    public var content: T
    
    public var corner:CGFloat
    
    public func draw(container :CGRect,render: TROfflineRender) {
        let path = CGPath(roundedRect: container, cornerWidth: corner, cornerHeight: corner, transform: nil)
        render.context.saveGState()
        render.context.addPath(path)
        render.context.clip()
        content.draw(container: container, render: render)
        render.context.restoreGState()
    }
}

public struct Shadow<T:FrameDrawable>:Modify{
    
    public var contentSize: CGSize {
        get{
            self.content.contentSize
        }
    }
    
    
    public var content: T
    

    public func draw(container :CGRect,render: TROfflineRender) {
        render.context.saveGState()
        if let shadowColor{
            render.context.setShadow(offset: shadowOffset, blur: self.shadowRadius, color:shadowColor)
        }else{
            render.context.setShadow(offset: shadowOffset, blur: self.shadowRadius)
        }
        self.content.draw(container: container, render: render)
        render.context.restoreGState()
    }
    
    public init(content: T, shadowColor: CGColor? = nil, shadowRadius: CGFloat, shadowOffset: CGSize) {
        self.content = content
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
    
    public var shadowColor:CGColor?
    
    public var shadowRadius:CGFloat
    
    public var shadowOffset:CGSize
    
}

public struct TransparencyLayer<T:FrameDrawable>:Modify{
    
    public var contentSize: CGSize {
        get{
            self.content.contentSize
        }
    }
    public var blend:CGBlendMode
    
    public var content: T
    
    public init(blend: CGBlendMode = .normal, content: T) {
        self.blend = blend
        self.content = content
    }
    
    public func draw(container :CGRect,render: TROfflineRender) {
        render.context.saveGState()
        render.context.setBlendMode(self.blend)
        render.context.beginTransparencyLayer(in:container,auxiliaryInfo: nil)
        content.draw(container: container, render: render)
        render.context.endTransparencyLayer()
        render.context.restoreGState()
    }
}

public struct Resize<T:FrameDrawable>:Modify{
    
    public var content: T
    
    public var contentSize: CGSize
    
    public var contentMode:TRContentMode
    
    public func draw(container :CGRect,render: TROfflineRender) {
        let nf = TROfflineRender.contentModeFrame(itemFrame: CGRect(origin: .zero, size: content.contentSize), containerFrame: container, mode: contentMode)
        content.draw(container: nf, render: render)
    }
    
    public init(content: T, frame: CGSize, contentMode: TRContentMode) {
        self.content = content
        self.contentSize = frame
        self.contentMode = contentMode
    }
}
public struct Background<T:FrameDrawable>:Modify{
    public func draw(container :CGRect,render: TROfflineRender) {
        print(container)
        render.context.saveGState()
        render.context.addPath(CGPath(rect: container, transform: nil))
        render.context.setFillColor(self.color)
        render.context.fillPath()
        self.content.draw(container: container, render: render)
        render.context.restoreGState()
    }
    
    public var content: T
    
    public var contentSize: CGSize{
        get{
            self.content.contentSize
        }
    }
    
    public var color:CGColor
    
    public init(content: T, color: CGColor) {
        self.content = content
        self.color = color
    }
}
public struct Padding<T:FrameDrawable>:Modify{

    public var content: T
    
    public var contentSize: CGSize{
        let w = self.content.contentSize.width + self.padding.left + self.padding.right
        let h = self.content.contentSize.width + self.padding.bottom + self.padding.top
        return CGSize(width: w, height: h)
    }
    
    public func draw(container: CGRect, render: TROfflineRender) {
        let rect = CGRect(x: self.padding.left + container.minX, y: self.padding.top + container.minY, width: container.width - self.padding.left - self.padding.right, height: container.height - self.padding.top - self.padding.bottom)
        self.content.draw(container: rect, render: render)
    }
    
    public var padding:UIEdgeInsets
    
    
    public init(content: T, padding: UIEdgeInsets) {
        self.content = content
        self.padding = padding
    }
}

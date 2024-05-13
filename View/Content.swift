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


public protocol FrameDrawable:Drawable{
    var frame:CGRect { get set }
}

public protocol Modify:FrameDrawable{
    associatedtype D:FrameDrawable
    var content:D { get set }
}

public struct Block:FrameDrawable{
    public func draw(render: TROfflineRender) {
        render.context.setFillColor(self.color)
        render.context.addPath(CGPath(rect: self.frame, transform: nil))
        render.context.fillPath()
    }
    
    public var frame: CGRect
    
    public var color:CGColor = UIColor.black.cgColor
    
    public init(frame: CGRect, color: CGColor) {
        self.frame = frame
        self.color = color
    }
}
public struct Pixel:FrameDrawable{
    public func draw(render: TROfflineRender) {
        render.context.saveGState()
        let l = render.draw(size: frame.size) { r in
            r.context.draw(self.image, in: CGRect(origin: .zero, size: frame.size), byTiling: false)
        }
        if let l {
            render.context.draw(l, in: frame)
        }
        render.context.restoreGState()
    }
    public var frame: CGRect
    
    public var image:CGImage
    
    public init(frame: CGRect, image: CGImage) {
        self.frame = frame
        self.image = image
    }
}


public struct Corner<T:FrameDrawable>:Modify{
    public var frame: CGRect{
        get{
            self.content.frame
        }
        set{
            self.content.frame = newValue
            
        }
    }
    
    
    public var content: T
    
    public var corner:CGFloat
    
    public func draw(render: TROfflineRender) {
        let path = CGPath(roundedRect: content.frame, cornerWidth: corner, cornerHeight: corner, transform: nil)
        render.context.saveGState()
        render.context.addPath(path)
        render.context.clip()
        content.draw(render: render)
        render.context.restoreGState()
    }
}

public struct Shadow<T:FrameDrawable>:Modify{
    
    public var frame: CGRect {
        get{
            self.content.frame
        }
        set{
            self.content.frame = newValue
        }
    }
    
    
    public var content: T
    

    public func draw(render: TROfflineRender) {
        render.context.saveGState()
        if let shadowColor{
            render.context.setShadow(offset: shadowOffset, blur: self.shadowRadius, color:shadowColor)
        }else{
            render.context.setShadow(offset: shadowOffset, blur: self.shadowRadius)
        }
        self.content.draw(render: render)
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
    
    public var frame: CGRect {
        get{
            self.content.frame
        }
        set{
            self.content.frame = newValue
        }
    }
    
    public var content: T
    
    public func draw(render: TROfflineRender) {
        render.context.beginTransparencyLayer(auxiliaryInfo: nil)
        content.draw(render: render)
        render.context.endTransparencyLayer()
    }
}

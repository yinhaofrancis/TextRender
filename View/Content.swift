//
//  Content.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/10.
//

import UIKit


public protocol Drawable{
    func draw(container:CGRect, render:TROfflineRender)
}


public protocol FrameDrawable:Drawable{
    var contentSize:CGSize { get }
}

public protocol Modify:FrameDrawable{
    associatedtype D:FrameDrawable
    var content:D { get set }
}

public struct Block:FrameDrawable{
    public func draw(container :CGRect,render: TROfflineRender) {
        render.context.setFillColor(self.color)
        render.context.addPath(CGPath(rect: container, transform: nil))
        render.context.fillPath()
    }
    
    public var contentSize: CGSize
    
    public var color:CGColor = UIColor.black.cgColor
    
    public init(frame: CGSize, color: CGColor) {
        self.contentSize = frame
        self.color = color
    }
}
public struct Pixel:FrameDrawable{
    public func draw(container :CGRect,render: TROfflineRender) {
        render.context.saveGState()
        let l = render.draw(size: container.size) { r in
            r.context.draw(self.image, in: CGRect(origin: .zero, size: container.size), byTiling: false)
        }
        if let l {
            render.context.draw(l, in: container)
        }
        render.context.restoreGState()
    }
    public var contentSize: CGSize
    
    public var image:CGImage
    
    public init(image: CGImage) {
        self.contentSize = CGSize(width: image.width, height: image.height)
        self.image = image
    }
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

public struct Spacing:FrameDrawable{
    public var contentSize: CGSize
    
    public func draw(container: CGRect, render: TROfflineRender) {
        
    }
    public init(contentSize: CGSize) {
        self.contentSize = contentSize
    }
}

public struct Stack:FrameDrawable{
    
    public enum Align{
        case start
        case center
        case end
        case fill
    }
    public enum Axis{
        case row
        case col
    }
    public var align:Align = .fill
    public var axis:Axis = .row
    
    public var contents:[FrameDrawable]
    public var contentSize: CGSize{
        switch(self.axis){
            
        case .row:
            let h = self.contents.max { l, r in
                l.contentSize.height < r.contentSize.height
            }?.contentSize.height ?? 0
            let w = self.contents.reduce(into: 0) { partialResult, r in
                partialResult += r.contentSize.width
            }
            return CGSize(width: w, height: h)
        case .col:
            let w = self.contents.max { l, r in
                l.contentSize.width < r.contentSize.width
            }?.contentSize.width ?? 0
            let h = self.contents.reduce(into: 0) { partialResult, r in
                partialResult += r.contentSize.height
            }
            return CGSize(width: w, height: h)
            
        }
        
    }
    func alignOffset(align:Align,container:CGFloat,item:CGFloat)->CGFloat{
        switch(align){
        case .start:
            return 0
        case .center:
            return (container - item) / 2
        case .end:
            return (container - item)
        case .fill:
            return 0
        }
    }
    func alignSize(align:Align,container:CGFloat,item:CGFloat)->CGFloat{
        switch(align){
        case .start:
            return item
        case .center:
            return item
        case .end:
            return item
        case .fill:
            return container
        }
    }
    func drawV(container: CGRect, render: TROfflineRender){
        var startoffset:CGFloat = 0
        for i in self.contents {
            let rect = CGRect(
                x: alignOffset(align: self.align, container: container.width, item: i.contentSize.width),
                y: startoffset,
                width: alignSize(align: self.align, container: container.width, item: i.contentSize.width),
                height: i.contentSize.height)
            i.draw(container: rect, render: render)
            startoffset += i.contentSize.height
        }
    }
    func drawH(container: CGRect, render: TROfflineRender){
        var startoffset:CGFloat = 0
        for i in self.contents {
            let rect = CGRect(
                x: startoffset,
                y:alignOffset(align: self.align, container: container.height, item: i.contentSize.height),
                width: i.contentSize.width,
                height: alignSize(align: self.align, container: container.height, item: i.contentSize.height))
            i.draw(container: rect, render: render)
            startoffset += i.contentSize.width
        }
    }
    public func draw(container: CGRect, render: TROfflineRender) {
        render.context.saveGState()
        render.context.translateBy(x: container.minX, y: container.minY)
        switch self.axis {
        case .row:
            self.drawH(container: container, render: render)
            break
        case .col:
            self.drawV(container: container, render: render)
            break
        }
        render.context.restoreGState()
    }
    
    public init(@ContentBuilder contents: ()->Contents) {
        self.contents = contents().drawables
    }
    
    
}
public struct TransparencyLayer<T:FrameDrawable>:Modify{
    
    public var contentSize: CGSize {
        get{
            self.content.contentSize
        }
    }
    
    public var content: T
    
    public func draw(container :CGRect,render: TROfflineRender) {
        render.context.beginTransparencyLayer(auxiliaryInfo: nil)
        content.draw(container: container, render: render)
        render.context.endTransparencyLayer()
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

public struct Contents{
    var drawables:[FrameDrawable]
}

@resultBuilder
public struct ContentBuilder{
    public static func buildBlock(_ components: FrameDrawable...) -> Contents {
        Contents(drawables: components)
    }
    public static func buildArray(_ components: [Contents]) -> Contents {
        Contents(drawables: components.flatMap({ c in
            c.drawables
            
        }))
    }
    public static func buildEither(first component: Contents) -> Contents {
        component
    }
    public static func buildEither(second component: Contents) -> Contents {
        component
    }
    
}

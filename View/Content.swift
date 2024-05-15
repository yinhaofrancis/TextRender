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

public struct RichText:FrameDrawable{
    public var contentSize: CGSize{
        self.makeTextFrame(w: CGSize(width: CGFloat.infinity, height: .infinity)).size
    }
    
    public func draw(container: CGRect, render: TROfflineRender) {
        render.context.saveGState()
        let f = self.makeTextFrame(w: container.size)
        f.render(frame: container, render: render)
        render.context.restoreGState()
    }
    
    public var text:NSAttributedString
    
    public func makeTextFrame(w:CGSize)->TRTextFrame{
        let tr = NSAttributedString(string: "……")
        return TRTextFrame(constaint: w, string: text, truncation: tr)
    }
}

public struct Text:FrameDrawable{
    
    public var text:String
    public var font:UIFont
    public var textColor:UIColor
    
    public var contentSize: CGSize {
        return self.makeTextFrame(w: CGSize(width: CGFloat.infinity, height: .infinity)).size
    }
    
    public func makeTextFrame(w:CGSize)->TRTextFrame{
        let text = NSAttributedString(string: text, attributes: [
            .font:self.font,
            .foregroundColor:self.textColor
        ])
        let tr = NSAttributedString(string: "……", attributes: [
            .font:self.font,
            .foregroundColor:self.textColor
        ])
        return TRTextFrame(constaint: w, string: text, truncation: tr)
    }
    
    public func draw(container: CGRect, render: TROfflineRender) {
        render.context.saveGState()
        let f = self.makeTextFrame(w: container.size)
        f.render(frame: container, render: render)
        render.context.restoreGState()
    }
    
    public init(text: String, font: UIFont, textColor: UIColor) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }
    
    
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
        
        let layer = render.draw(size: CGSize(width: self.image.width, height: self.image.height)) { r in
            r.context.draw(self.image, in: CGRect(origin: .zero, size: CGSize(width: self.image.width, height: self.image.height)), byTiling: false)
        }
        guard let layer else { return }
        render.context.draw(layer, in: container)
        render.context.restoreGState()
    }
    public var contentSize: CGSize
    
    public var image:CGImage
    
    public init(image: CGImage) {
        self.contentSize = CGSize(width: image.width, height: image.height)
        self.image = image
    }
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


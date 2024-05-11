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

public protocol Element{
    
    associatedtype D:Element
    
    var element:D { get }
    
    var isRoot:Bool { get }
}

extension Never:Element{
    public var isRoot: Bool {
        true
    }
    
    public typealias D = Never
    
    
    public var element: Never{
        return fatalError()
    }
    
}


extension Element{
    public func background(color:CGColor)->Background<Self>{
        Background(element: self, color: color)
    }
    
    public func stroke(color: CGColor,width:CGFloat)->Stroke<Self>{
        Stroke(element: self, color: color, width: width)
    }
    
    public func shadow(color: CGColor,radius:CGFloat,offset:CGPoint)->Shadow<Self>{
        Shadow(element: self, color: color, radius: radius, offset: offset)
    }
}

public struct Background<Content:Element>:Element{
    public var isRoot: Bool{
        false
    }
    
    public typealias D = Content
    
    public var element: Content
    
    public var backgroundColor:CGColor
    
    public init(element: Content, color: CGColor) {
        self.element = element
        self.backgroundColor = color
    }
}

public struct Stroke<Content:Element>:Element{
    
    public var isRoot: Bool{
        false
    }
    
    public typealias D = Content
    
    public var element: Content
    
    public var strokeColor:CGColor
    
    public var width:CGFloat
    
    public init(element: Content, color: CGColor,width:CGFloat) {
        self.element = element
        self.strokeColor = color
        self.width = width
    }
}

public struct Shadow<Content:Element>:Element{
    
    public var isRoot: Bool{
        false
    }
    
    public typealias D = Content
    
    public var element: Content
    
    public var shadowColor    :CGColor
    public var shadowRadius   :CGFloat
    public var shadowOffset   :CGPoint
    
    public init(element: Content, color: CGColor,radius:CGFloat,offset:CGPoint) {
        self.element = element
        self.shadowColor = color
        self.shadowRadius = radius
        self.shadowOffset = offset
    }
}

public struct ContentResizeMode<Content:Element>:Element{
    
    public var isRoot: Bool{
        false
    }
    
    public var element: Content
    
    public typealias D = Content
    
    public var contentMode   :TRContentMode
    
    public init(element: Content,model:TRContentMode) {
        self.element = element
    
        self.contentMode = model
    }
}

public struct Frame<Content:Element>:Element{
    
    public var isRoot: Bool{
        false
    }
    
    public var element: Content
    
    public typealias D = Content
    
    public var frame   :CGRect
    
    public init(element: Content,frame:CGRect) {
        self.element = element
    
        self.frame = frame
    }
}

public struct pixelImage{
   
    public var image    :CGImage
    
    public init(image: CGImage) {
        self.image = image
    }
}

public struct VectorImage{

    public var image    :TRPDFImage
    public init(image: TRPDFImage) {
        self.image = image
    }
}

public struct TextFrame{
    public var text    :TRTextFrame
    public init(text: TRTextFrame) {
        self.text = text
    }
}

public struct TextElement{
    
    public var text:String
    
    public var font:UIFont
    
    public var textColor:CGColor
    
    public init(text: String, font: UIFont, textColor: CGColor) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }
}

extension TextFrame:Element{
    
    public var isRoot: Bool{
        true
    }
    
    public typealias D = Never
    
    public var element: Never {
        return fatalError()
    }
}


extension VectorImage:Element{
    
    public var isRoot: Bool{
        true
    }
    
    public typealias D = Never
    
    public var element: Never {
        return fatalError()
    }
}

extension pixelImage:Element{
    
    public var isRoot: Bool{
        true
    }
    
    public typealias D = Never
    
    public var element: Never {
        return fatalError()
    }
}

extension TextElement:Element{
    public var isRoot: Bool{
        true
    }
    
    public typealias D = Never
    
    public var element: Never {
        return fatalError()
    }
}

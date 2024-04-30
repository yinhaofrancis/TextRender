//
//  TRRendable.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/25.
//

import Foundation
import CoreGraphics
import UIKit


public protocol TRRenderFrame{

    var frame:CGRect { get }
}

public protocol TRContent{
    
    var contentMode:TROfflineRender.ContentMode { get }
    
    func render(frame:CGRect,render:TROfflineRender)
}

public protocol TRRenderable:TRRenderFrame{
    
    associatedtype T:TRContent
    
    var content:T { get }

}
extension TRRenderable{
    public func draw(render:TROfflineRender){
        self.draw(frame: self.frame, render: render)
    }
    public func draw(frame:CGRect, render:TROfflineRender){
        content.render(frame: frame, render: render)
    }
}

public struct TRView<T:TRContent>:TRRenderable{
    public var content: T
    
    public var frame: CGRect
    
    public init(content: T, frame: CGRect = .zero) {
        self.content = content
        self.frame = frame
    }
    
}

public class TRRunView<T:TRRenderable>:TRFontRunDelegate{
    
    public var char: Character {
        "\u{fffc}"
    }
    
    public var descent: CGFloat
    
    public var ascent: CGFloat
    
    public var width: CGFloat
    
    public var content: T
    
    
    public init(content: T,descent: CGFloat, ascent: CGFloat, width: CGFloat) {
        self.content = content
        self.descent = descent
        self.ascent = ascent
        self.width = width
    }
    public init(content: T,font:UIFont,width:CGFloat? = nil) {
        self.content = content
        self.descent = -font.descender
        self.ascent = font.ascender
        self.width =  width ?? font.pointSize
    }
}
public class TRSpacing:TRRunView<TRView<CGColor>>{
    
    public override var char: Character {
        " "
    }
    public init(font:UIFont,size:CGFloat) {
        super.init(content: TRView(content: UIColor.clear.cgColor), font: font,width: size)
    }
}
public class TRTextImage:TRRunView<TRView<TRVectorImage>>{
    public init(image:TRPDFImage,font:UIFont,contentMode:TROfflineRender.ContentMode) {
        super.init(content: TRView(content: TRVectorImage(contentMode: contentMode, image: image)), font: font)
    }
}

public class TRTextTag:TRRunView<TRView<TRTextFrame>>{
    public var textFrame:TRTextFrame
    public init(textframe:TRTextFrame,font:UIFont) {
        self.textFrame = textframe
        super.init(content: TRView(content: textframe), font: font,width: textframe.size.width)
        self.width = textframe.size.width
    }
    public convenience init(string:CFAttributedString,font:UIFont,width:CGFloat){
        self.init(textframe: TRTextFrame(width: width, string: string), font: font)
    }
}


extension TRRunView {
    public func createAttibuteString(attribute:[NSAttributedString.Key:Any])->NSAttributedString{
        let att = TRTextFrame.createRunDelegate(run: self, attribute: attribute)
        return att
    }
}

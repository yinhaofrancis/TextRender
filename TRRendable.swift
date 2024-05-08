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
    
    var contentMode:TRContentMode { get }
    
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

/// 行内元素
public class TRRunView<T:TRRenderable>:TRRunDelegate{
    
    public var char: Character {
        "\u{fffc}"
    }
    
    public var descent: CGFloat
    
    public var ascent: CGFloat
    
    public var width: CGFloat
    
    public var content: T
    
    
    /// 创建行内元素
    /// - Parameters:
    ///   - content: 元素内容 inherit from TRRenderable protocol
    ///   - descent: baseline 下的高度
    ///   - ascent: baseline 上的高度
    ///   - width: 宽度
    public init(content: T,descent: CGFloat, ascent: CGFloat, width: CGFloat) {
        self.content = content
        self.descent = descent
        self.ascent = ascent
        self.width = width
    }
    /// 创建行内元素
    /// - Parameters:
    ///   - content: 元素内容 inherit from TRRenderable protocol
    ///   - font: 字体用于获取 descent ascent
    ///   - width: 宽度
    public init(content: T,font:UIFont,width:CGFloat? = nil) {
        self.content = content
        self.descent = -font.descender
        self.ascent = font.ascender
        self.width =  width ?? font.pointSize
    }
}
/// 空白
public class TRSpacing:TRRunView<TRView<CGColor>>{
    
    public override var char: Character {
        " "
    }
    /// 创建空白
    /// - Parameters:
    ///   - font: 字体用于获取 descent ascent
    ///   - size: 宽度
    public init(font:UIFont,size:CGFloat) {
        super.init(content: TRView(content: UIColor.clear.cgColor), font: font,width: size)
    }
}
/// 行内图形
public class TRTextImage:TRRunView<TRView<TRVectorImage>>{
    /// 创建行内图形
    /// - Parameters:
    ///   - image: 矢量图 pdf
    ///   - font: 字体用于获取 descent ascent
    ///   - contentMode: 适应大小
    public init(image:TRPDFImage,font:UIFont,contentMode:TRContentMode) {
        super.init(content: TRView(content: TRVectorImage(contentMode: contentMode, image: image)), font: font)
    }
}
/// 行内点阵图
public class TRPixelImage:TRRunView<TRView<TRImage>>{
    /// 创建行内点阵图
    /// - Parameters:
    ///   - image: CGimage
    ///   - font: 字体用于获取 descent ascent
    ///   - contentMode: 适应大小
    public init(image:CGImage,font:UIFont,contentMode:TRContentMode) {
        
        super.init(content: TRView(content: TRImage(image: image, contentMode: contentMode)), font: font)
    }
}

/// 文本标签
public class TRTextTag:TRRunView<TRView<TRTextFrame>>{
    public var textFrame:TRTextFrame
    /// 创建文本标签
    /// - Parameters:
    ///   - textframe: 文本块
    ///   - font: 字体用于获取 descent ascent 非 文本块字体 文本块有自己的字体属性
    public init(textframe:TRTextFrame,font:UIFont) {
        self.textFrame = textframe
        super.init(content: TRView(content: textframe), font: font,width: textframe.size.width)
        self.width = textframe.size.width
    }
    /// 创建文本标签
    /// - Parameters:
    ///   - string: 富文本
    ///   - font: 字体用于获取 descent ascent 非 文本块字体 文本块有自己的字体属性
    ///   - width: 宽度，用于约束 创建的文本块的宽度约束
    public convenience init(string:CFAttributedString,font:UIFont,width:CGFloat){
        self.init(textframe: TRTextFrame(width: width, string: string), font: font)
    }
}


extension TRRunView {
    /// 创建富文本用于拼接
    /// - Parameter attribute: 富文本属性
    /// - Returns: 富文本
    public func createAttibuteString(attribute:[NSAttributedString.Key:Any])->NSAttributedString{
        let att = TRTextFrame.createRunDelegate(run: self, attribute: attribute)
        return att
    }
}

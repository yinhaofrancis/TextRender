//
//  CocoRunDelegate.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit

public protocol CocoRunDelegate {
    
    associatedtype R:CocoContent
    
    /// Character as placehold
    var char:Character { get }
    
    var descent:CGFloat { get }
    
    var ascent:CGFloat { get }
    
    var width:CGFloat { get }
    
    var content:R { get }
}


class WrapRunDelegate{
    var tRunDelegate:any CocoRunDelegate
    init(tRunDelegate: any CocoRunDelegate) {
        self.tRunDelegate = tRunDelegate
    }
}


extension CocoRunDelegate{
    var runDelegateCallback:CTRunDelegateCallbacks{
        CTRunDelegateCallbacks(version: 0) { i in
            Unmanaged<WrapRunDelegate>.fromOpaque(i).release()
        } getAscent: { i in
            Unmanaged<WrapRunDelegate>.fromOpaque(i).takeUnretainedValue().tRunDelegate.ascent
        } getDescent: { i in
            Unmanaged<WrapRunDelegate>.fromOpaque(i).takeUnretainedValue().tRunDelegate.descent
        } getWidth: { i in
            Unmanaged<WrapRunDelegate>.fromOpaque(i).takeUnretainedValue().tRunDelegate.width
        }
    }
    
    var runDelegate:CTRunDelegate?{
        var call = self.runDelegateCallback
        return CTRunDelegateCreate(&call, Unmanaged.passRetained(WrapRunDelegate(tRunDelegate: self)).toOpaque())
    }
}

extension NSAttributedString{
    public func appending(right:NSAttributedString)->NSAttributedString{
        let a = NSMutableAttributedString(attributedString: self)
        a.append(right)
        return a
    }
    public func appending<T:CocoRunDelegate>(right:T)->NSAttributedString{
        let a = NSMutableAttributedString(attributedString: self)
        let att = a.attributes(at: a.length - 1, effectiveRange: nil)
        a.append(CocoTextFrame.createRunDelegate(run: right, attribute: att))
        return a
    }
    
    static public func +(left:NSAttributedString, right:NSAttributedString)->NSAttributedString{
        let a = NSMutableAttributedString(attributedString: left)
        a.append(right)
        return a
    }
    static public func +<T:CocoRunDelegate>(left:NSAttributedString,right:T)->NSAttributedString{
        let a = NSMutableAttributedString(attributedString: left)
        let att = a.attributes(at: a.length - 1, effectiveRange: nil)
        a.append(CocoTextFrame.createRunDelegate(run: right, attribute: att))
        return a
    }
}


public struct CocoTextRunDelegate<R:CocoContent>:CocoRunDelegate{
    public var char: Character
    
    public var descent: CGFloat
    
    public var ascent: CGFloat
    
    public var width: CGFloat
    
    public var content: R
    
    public init(char: Character = "\u{fffc}", descent: CGFloat, ascent: CGFloat, width: CGFloat, content: R) {
        self.char = char
        self.descent = descent
        self.ascent = ascent
        self.width = width
        self.content = content
    }
    
    public init(font:UIFont,width:CGFloat? = nil,content: R){
        self.init(descent: -font.descender, ascent: font.ascender, width: width ?? font.pointSize, content: content)
    }
    public init(font:CTFont,width:CGFloat? = nil,content: R){
        self.init(descent: CTFontGetDescent(font), ascent: CTFontGetAscent(font), width: width ?? CTFontGetSize(font), content: content)
    }
}
extension CocoTextRunDelegate {
    public init(font:UIFont,width:CGFloat,color:CGColor) where R == Block{
        self.init(font: font, width: width, content: Block(color: color, size: CGSize(width: width, height: font.ascender - font.descender), contentMode: .center(1)))
    }
    
    public init(font:UIFont,image:CGImage,contentMode:CocoContentMode) where R == CocoPixelImage{
        self.init(font: font, content: CocoPixelImage(image: image, contentMode: contentMode))
    }
    
    public init(font:UIFont,image:CocoPDFImage,contentMode:CocoContentMode) where R == CocoVectorImage{
        self.init(font: font, content: CocoVectorImage(image: image, contentMode: contentMode))
    }
}

extension NSAttributedString{
    public static func block(font:UIFont,
                             width:CGFloat,
                             color:CGColor,
                             attribute:[NSAttributedString.Key:Any]? = nil)->NSAttributedString{
        var att = attribute
        att?[.font] = font
        return CocoTextFrame.createRunDelegate(run: CocoTextRunDelegate(font: font, width: width, color: color), attribute: att ?? [.font:font])
    }
    
    public static func image(font:UIFont,
                             image:CGImage,
                             contentMode:CocoContentMode,
                             attribute:[NSAttributedString.Key:Any]? = nil)->NSAttributedString{
        var att = attribute
        att?[.font] = font
        return CocoTextFrame.createRunDelegate(run: CocoTextRunDelegate(font: font, image: image, contentMode: contentMode), attribute: att ?? [.font:font])
    }
    
    public static func image(font:UIFont,
                             image:CocoPDFImage,
                             contentMode:CocoContentMode,
                             attribute:[NSAttributedString.Key:Any]? = nil)->NSAttributedString{
        var att = attribute
        att?[.font] = font
        return CocoTextFrame.createRunDelegate(run: CocoTextRunDelegate(font: font, image: image, contentMode: contentMode), attribute: att ?? [.font:font])
    }
    
    public static func linearGradient(font:UIFont,
                                      @CocoGradient image:()->CocoGradient,
                                      startPoint:CGPoint,
                                      endPoint:CGPoint,
                                      contentMode:CocoContentMode,
                                      attribute:[NSAttributedString.Key:Any]? = nil)->NSAttributedString{
        var att = attribute
        att?[.font] = font
        let ct = CocoTextRunDelegate(font: font, content: LinearGradient(gradient: image, contentMode: contentMode, startPoint: startPoint, endPoint: endPoint))
        return CocoTextFrame.createRunDelegate(run: ct, attribute: att ?? [.font:font])
    }
}

public typealias  CococTextSpacing = CocoTextRunDelegate<Block>

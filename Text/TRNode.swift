//
//  TRNode.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/10.
//

import UIKit

public protocol TRNode{
    var typingAttribute:[NSAttributedString.Key : Any] { get set }
    var attributeString:NSAttributedString  { get }
}

@resultBuilder
public struct SpanBuilder{
    public static func buildBlock(_ components: TRNode...) -> SpanList {
        SpanList(nodes: components)
    }
    public static func buildArray(_ components: [SpanList]) -> SpanList {
        SpanList(nodes: components.flatMap({ c in
            c.nodes
        }))
    }
    public static func buildEither(first component: SpanList) -> SpanList {
        return component
    }
    public static func buildEither(second component: SpanList) -> SpanList {
        return component
    }
    public static func buildOptional(_ component: SpanList?) -> SpanList {
        return SpanList(nodes: [])
    }
//    public static func buildPartialBlock(first: SpanList) -> SpanList {
//        return first
//    }
//    public static func buildPartialBlock(accumulated: SpanList, next: SpanList) -> SpanList {
//        return SpanList(nodes: accumulated.nodes + next.nodes)
//    }
}

public struct TextSpan:TRNode{
    public var string:String
    public var font:UIFont
    public var textColor:UIColor
    public var typingAttribute: [NSAttributedString.Key : Any] = [:]
    public var attributeString:NSAttributedString {
        var my:[NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor:textColor
        ]
        my.merge(typingAttribute) { a, b in
            return a
        }
        return NSAttributedString(string: string, attributes: my)
    }
}
public struct ImageSpan:TRNode{
    public var image:CGImage
    public var font:UIFont
    public var mode:TRContentMode
    public var typingAttribute:[NSAttributedString.Key : Any] = [:]
    public var attributeString:NSAttributedString{
        TRPixelImage(image: image, font: font, contentMode: mode).createAttibuteString(attribute: typingAttribute)
    }
}
public struct PDFSpan:TRNode{
    public var image:TRPDFImage
    public var font:UIFont
    public var mode:TRContentMode
    public var typingAttribute:[NSAttributedString.Key : Any] = [:]
    public var attributeString:NSAttributedString{
        TRTextImage(image: image, font: font, contentMode: mode).createAttibuteString(attribute: typingAttribute)
    }
}
public struct SpacingSpan:TRNode{
    public var size:CGFloat
    public var font:UIFont
    public var typingAttribute:[NSAttributedString.Key : Any] = [:]
    public var attributeString:NSAttributedString{
        TRSpacing(font: font, size: size).createAttibuteString(attribute: typingAttribute)
    }
}


public struct SpanList{
    public var nodes:[TRNode]
}


public struct ContainerSpan:TRNode{
    
    public var typingAttribute: [NSAttributedString.Key : Any] = [:]
    
    public var contentTypingAttribute:[NSAttributedString.Key : Any]
    
    public var attributeString:NSAttributedString {
        let s = self.content.reduce(into: NSMutableAttributedString()) { partialResult, r in
            var nr = r
            nr.typingAttribute = contentTypingAttribute
            partialResult.append(nr.attributeString)
        }
        return TRTextTag(string: s, font: self.font, width: self.maxWidth).createAttibuteString(attribute: typingAttribute)
    }
    public var maxWidth:CGFloat
    
    public var font:UIFont
    
    public var content:[TRNode]
    
    public init(maxWidth: CGFloat = .infinity,contentTypingAttribute:[NSAttributedString.Key : Any] = [:], font: UIFont,@SpanBuilder build:()->SpanList) {
        self.content = build().nodes
        self.maxWidth = maxWidth
        self.font = font
        self.contentTypingAttribute = contentTypingAttribute
    }
}

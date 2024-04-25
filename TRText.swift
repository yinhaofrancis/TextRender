//
//  TRText.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/12.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit
extension NSAttributedString.Key{
    public static let runDelegate:NSAttributedString.Key = NSAttributedString.Key("kTRRunDelegateAttributeName")
    public static let url:NSAttributedString.Key = NSAttributedString.Key("kTRAttributeURL")
}



public struct TRRun{
    public let run:CTRun
    
    public let lineOrigin:CGPoint
    
    public var rect:CGRect{
        if let runDelegate = self.runDelegate{
            var rect = self.getRect(range: .init(location: 0, length: 0))
            rect.origin.y -= runDelegate.descent
            rect.size.width = runDelegate.width
            rect.size.height = runDelegate.ascent + runDelegate.descent
            return rect
        }else{
            return self.getRect(range: .init(location: 0, length: 0))
        }
        
    }
    
    public subscript(range:Range<Int>)->CGRect{
        let range = CFRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
        return getRect(range: range)
    }
    public func getRect(range:CFRange)->CGRect{
        var rect = CTRunGetImageBounds(self.run, nil,range)
        
        var descent:CGFloat = 0
        
        var ascent:CGFloat = 0
        
        var leading:CGFloat = 0
        
        _ = CTRunGetTypographicBounds(self.run, range, &ascent, &descent, &leading)
        
        rect.origin.y += lineOrigin.y
        return rect
    }
    public var attribute:[NSAttributedString.Key:Any]{
        CTRunGetAttributes(self.run) as! [NSAttributedString.Key : Any]
    }
    public var runDelegate:TRRunDelegate?{
        self.attribute[.runDelegate] as? TRRunDelegate
    }
}

public struct TRLine{
    
    public let line:CTLine
    
    public let frameOrigin:CGPoint
    
    public let runs:[TRRun]
    
    public let descent:CGFloat
    
    public let ascent:CGFloat
    
    public let leading:CGFloat
    
    public let width:CGFloat
    
    public var rect:CGRect{
        var ib = CTLineGetImageBounds(self.line, nil)
        ib.origin.y += self.frameOrigin.y
        return ib
    }
    public func hit(point:CGPoint)->TRRun?{
        for i in self.runs{
            if(i.rect.contains(point)){
                return i
            }
        }
        return nil
    }
    public init(line: CTLine,origin:CGPoint) {
        self.line = line
        var ascent:CGFloat = 0,descent:CGFloat = 0,leading:CGFloat = 0;
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        self.runs = (CTLineGetGlyphRuns(line) as! [CTRun]).map {TRRun(run: $0, lineOrigin: origin)}
        self.descent = descent
        self.ascent = ascent
        self.leading = leading
        self.width = width
        self.frameOrigin = origin
    }
}

public struct TRText:Hashable{
    public static func == (lhs: TRText, rhs: TRText) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
    
    public let isTrancate:Bool
    
    public let frameSet:CTFramesetter
    
    public let frame:CTFrame
    
    public let string:CFAttributedString
    
    public let lines:[TRLine]
    
    public let size:CGSize
        
    public init(width:CGFloat,string:CFAttributedString){
        self.init(constaint: CGSize(width: width, height: .infinity), string: string)
        
    }

    public init(constaint:CGSize,string:CFAttributedString){
        self.string = string
        let len = CFAttributedStringGetLength(string)
        let frameset = CTFramesetterCreateWithAttributedString(string)
        let range = CFRange(location: 0, length: len)
        
        self.frameSet = frameset
        var fitRange = CFRangeMake(0, 0)
        var nc = constaint;
        nc.width = nc.width <= 0 ? .infinity : nc.width
        nc.height = nc.height <= 0 ? .infinity : nc.height
        let size = CTFramesetterSuggestFrameSizeWithConstraints(frameSet, range, nil, nc, &fitRange)
        self.size = size
        self.frame = CTFramesetterCreateFrame(frameset,range , CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil), nil)

        isTrancate = fitRange.length != range.length
        let ctline = (CTFrameGetLines(frame) as! [CTLine])
        var lines:[TRLine] = []
        
        
        let p = UnsafeMutablePointer<CGPoint>.allocate(capacity: ctline.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0,0), p)
        for i in 0 ..< ctline.count {
            lines.append(TRLine(line: ctline[i], origin: p.advanced(by: i).pointee))
        }
        p.deallocate()
        self.lines = lines
    }
    public var length:Int{
        CFAttributedStringGetLength(self.string)
    }
    public func hit(point:CGPoint)->TRLine?{
        for i in self.lines{
            if(i.rect.contains(point)){
                return i
            }
        }
        return nil
    }
    public func hitRun(point:CGPoint)->TRRun?{
        for i in self.lines{
            if(i.rect.contains(point)){
                return i.hit(point: point)
            }
        }
        return nil
    }
    public var runDelegateRun:[TRRun]{
        self.lines.flatMap {$0.runs}.filter {$0.runDelegate != nil }
    }
    public func draw(ctx:CGContext){
        CTFrameDraw(self.frame, ctx)
    }
}



public protocol TRRunDelegate {
    var descent:CGFloat { get }
    
    var ascent:CGFloat { get }
    
    var width:CGFloat { get }
    
    var content:TRRunContent? { get }
}


public protocol TRRunContent {
    func render(rect:CGRect,ctx:CGContext)
}


extension UIColor:TRRunContent{
    public func render(rect: CGRect, ctx: CGContext) {
        ctx.saveGState()
        ctx.setFillColor(self.cgColor)
        ctx.fill([rect])
        ctx.restoreGState()
    }
}


extension CGImage:TRRunContent{
    public func render(rect: CGRect, ctx: CGContext) {
        ctx.saveGState()
        let w = self.width
        let h = self.height
        let ratioW = rect.width / CGFloat(w)
        let ratioH = rect.height / CGFloat(h)
        let ratio = min(ratioW, ratioH)
        let rw = CGFloat(w) * ratio
        let rh = CGFloat(h) * ratio
        let x = (rect.width - rw) / 2 + rect.minX
        let y = (rect.height - rh) / 2 + rect.minY
        let rect = CGRect(x: x, y: y, width: rw, height: rh)
        ctx.draw(self, in: rect, byTiling: false)
        ctx.restoreGState()
    }
}



class WrapRunDelegate{
    var tRunDelegate:TRRunDelegate
    init(tRunDelegate: TRRunDelegate) {
        self.tRunDelegate = tRunDelegate
    }
}


extension TRRunDelegate{
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



public struct TRPlainRunDelegate:TRRunDelegate{
    
    public var content: TRRunContent?

    public var descent: CGFloat
    
    public var ascent: CGFloat
    
    public var width: CGFloat
    
    public var color: UIColor = UIColor.black
    
    public init(descent: CGFloat, ascent: CGFloat, width: CGFloat) {
        self.descent = descent
        self.ascent = ascent
        self.width = width
    }
    
}

public struct TRFontRunDelegate:TRRunDelegate{
    
    public var content: TRRunContent?
    
    public var descent: CGFloat
    
    public var ascent: CGFloat
    
    public var width: CGFloat

    
    public init(font: UIFont) {
        self.descent = -font.descender
        self.ascent = font.ascender
        self.width = font.pointSize
    }
    public init(font: CTFont) {
        self.descent = CTFontGetDescent(font)
        self.ascent = CTFontGetAscent(font)
        self.width = CTFontGetSize(font)
    }
    
}

extension TRText{    
    public static func createRunDelegate(run:TRRunDelegate)->NSAttributedString{
        
        return NSAttributedString(string: "\u{fffd}",attributes: [
            .runDelegate:run,
            NSAttributedString.Key(kCTRunDelegateAttributeName as String):run.runDelegate as Any
        ])
    }
    public func render(helper:TROfflineRender)->CGLayer?{
        helper.layer(size: self.size.applying(CGAffineTransform(scaleX: CGFloat(helper.scale), y: CGFloat(helper.scale)))) { ctx in
            CTFrameDraw(self.frame, ctx)
            for i in self.runDelegateRun{
                i.runDelegate?.content?.render(rect: i.rect,ctx: ctx)
            }
        }
    }
}

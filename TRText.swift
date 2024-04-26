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


public protocol TRDebug{
    func drawLineFrame(ctx:CGContext)
}


public struct TRRun:TRDebug{
    public func drawLineFrame(ctx: CGContext) {
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.blue.cgColor)
        ctx.stroke(rect, width: 1)
        ctx.restoreGState()
    }
    
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
    public var runDelegate:(any TRRunDelegate)?{
        self.attribute[.runDelegate] as? (any TRRunDelegate)
    }
}

public struct TRLine:TRDebug{
    
    public func drawLineFrame(ctx: CGContext) {
        for i in self.runs{
            i.drawLineFrame(ctx: ctx)
        }
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.green.cgColor)
        ctx.stroke(rect, width: 1)
        ctx.restoreGState()
    }
    
    
    public let line:CTLine
    
    public let frameOrigin:CGPoint
    
    public let runs:[TRRun]
    
    public let descent:CGFloat
    
    public let ascent:CGFloat
    
    public let leading:CGFloat
    
    public let width:CGFloat
    
    public func truncateLine(type:CTLineTruncationType,token:CTLine?)->TRLine{
        guard let token else {
            return self
        }
        if self.runs.last?.runDelegate != nil{
            
        }
        let w = TRLine(line: token, origin: .zero).width;
        guard let l = CTLineCreateTruncatedLine(self.line, self.width - w, type, token) else { return self }
        print(l)
        return TRLine(line: l, origin: self.frameOrigin)
    }
    
    public var glyphsRect:CGRect{
        var ib = CTLineGetImageBounds(self.line, nil)
        ib.origin.y += self.frameOrigin.y
        return ib
    }
    public var rect:CGRect{
        return CGRect(x: self.frameOrigin.x, y: self.frameOrigin.y - descent, width: self.width, height: self.ascent + self.descent)
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

public struct TRTextFrame:Hashable,TRDebug{
    
    public func drawLineFrame(ctx: CGContext) {
        for i in self.lines{
            i.drawLineFrame(ctx: ctx)
        }
    }
    
    public static func == (lhs: TRTextFrame, rhs: TRTextFrame) -> Bool {
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
        self.init(constaint: CGSize(width: width, height: .infinity), string: string, truncation:nil)
        
    }
    

    public init(constaint:CGSize,string:CFAttributedString,truncation:CFAttributedString?){
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
            if(isTrancate && i == ctline.count - 1){
                let tline = truncation != nil ? CTLineCreateWithAttributedString(truncation!) : nil
                lines.append(TRLine(line: ctline[i], origin: p.advanced(by: i).pointee).truncateLine(type: .end, token: tline))
            }else{
                lines.append(TRLine(line: ctline[i], origin: p.advanced(by: i).pointee))
            }
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
        if(isTrancate){
            for line in lines {
                ctx.saveGState()
                ctx.textPosition = line.frameOrigin
                CTLineDraw(line.line, ctx)
                ctx.restoreGState()
            }
        }else{
//            ctx.saveGState()
            CTFrameDraw(self.frame, ctx)
//            ctx.restoreGState()
        }
    }
}

extension TRTextFrame{    
    public static func createRunDelegate(run:any TRRunDelegate,attribute:[NSAttributedString.Key:Any])->NSAttributedString{
        
        var attr = attribute;
        attr[.runDelegate] = run
        attr[NSAttributedString.Key(kCTRunDelegateAttributeName as String)] = run.runDelegate as Any
        return NSAttributedString(string: String(run.char),attributes:attr)
    }
    public func render(helper:TROfflineRender)->CGLayer?{
        helper.layer(size: self.size) { ctx in
            self.draw(ctx: ctx)
            for i in self.runDelegateRun{
                i.runDelegate?.content.draw(frame: i.rect, ctx: ctx)
            }
        }
    }
}


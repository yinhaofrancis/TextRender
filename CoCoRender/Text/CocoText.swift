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

public struct CocoRun{
    
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
    public var runDelegate:(any CocoRunDelegate)?{
        self.attribute[.runDelegate] as? (any CocoRunDelegate)
    }
    public func inRange(index:CFIndex)->Bool{
        let range = CTRunGetStringRange(self.run)
        if range.location <=  index && range.location + range.length > index{
            return true
        }
        return false
    }
    public var range:CFRange{
        return CTRunGetStringRange(self.run)
    }
}

public struct CocoLine{
    
    subscript(index:CFIndex)->CocoRun?{
        return self.runs.first { r in
            r.inRange(index: index)
        }
    }
    
    public let line:CTLine
    
    public let frameOrigin:CGPoint
    
    public let runs:[CocoRun]
    
    public let descent:CGFloat
    
    public let ascent:CGFloat
    
    public let leading:CGFloat
    
    public let width:CGFloat
    
    public func truncateLine(type:CTLineTruncationType,token:CTLine?)->CocoLine{
        guard let token else {
            return self
        }
        if self.runs.last?.runDelegate != nil{
            
        }
        let w = CocoLine(line: token, origin: .zero).width;
        guard let l = CTLineCreateTruncatedLine(self.line, self.width - w, type, token) else { return self }
        return CocoLine(line: l, origin: self.frameOrigin)
    }
    
    public var glyphsRect:CGRect{
        var ib = CTLineGetImageBounds(self.line, nil)
        ib.origin.y += self.frameOrigin.y
        return ib
    }
    public var rect:CGRect{
        return CGRect(x: self.frameOrigin.x, y: self.frameOrigin.y - descent, width: self.width, height: self.ascent + self.descent)
    }
    public func hitIndex(point:CGPoint)->CFIndex{
        if(point.y > 0){
            return CTLineGetStringIndexForPosition(self.line, point)
        }
        return kCFNotFound
    }
    public func penOffset(index:CFIndex)->CGRect{
        let offet = CTLineGetOffsetForStringIndex(self.line, index, nil)
        return CGRect(x: self.frameOrigin.x + offet, y: glyphsRect.minY,width:1,height:self.glyphsRect.height)
    }
    public init(line: CTLine,origin:CGPoint) {
        self.line = line
        var ascent:CGFloat = 0,descent:CGFloat = 0,leading:CGFloat = 0;
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        self.runs = (CTLineGetGlyphRuns(line) as! [CTRun]).map {CocoRun(run: $0, lineOrigin: origin)}
        self.descent = descent
        self.ascent = ascent
        self.leading = leading
        self.width = width
        self.frameOrigin = origin
    }
    public func draw(ctx:CGContext){
        ctx.saveGState()
        ctx.textPosition = self.frameOrigin
        CTLineDraw(self.line, ctx)
        ctx.restoreGState()
    }
}

public struct CocoTextFrame:Hashable{
    public var contentMode: CocoContentMode = .center(1)
    
    public static func == (lhs: CocoTextFrame, rhs: CocoTextFrame) -> Bool {
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
    
    public let lines:[CocoLine]
    
    public let size:CGSize
    
    public init(width:CGFloat,string:CFAttributedString){
        self.init(constaint: CGSize(width: width, height: .infinity), string: string, truncation:nil)
        
    }
    
    public func resize(width:CGFloat)->CocoTextFrame{
        return CocoTextFrame(width: width, string: self.string)
    }
    
    public func resize(constaint:CGSize,truncation:CFAttributedString?)->CocoTextFrame{
        return CocoTextFrame(constaint: constaint, string: string, truncation: truncation)
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
        var lines:[CocoLine] = []
        
        
        let p = UnsafeMutablePointer<CGPoint>.allocate(capacity: ctline.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0,0), p)
        for i in 0 ..< ctline.count {
            if(isTrancate && i == ctline.count - 1){
                let tline = truncation != nil ? CTLineCreateWithAttributedString(truncation!) : nil
                lines.append(CocoLine(line: ctline[i], origin: p.advanced(by: i).pointee).truncateLine(type: .end, token: tline))
            }else{
                lines.append(CocoLine(line: ctline[i], origin: p.advanced(by: i).pointee))
            }
        }
        p.deallocate()
        self.lines = lines
    }
    public var length:Int{
        CFAttributedStringGetLength(self.string)
    }

    public func hitIndex(leftCoodiPoint:CGPoint,render:CocoOfflineRender)->(CFIndex,CocoLine?){
        let point = render.transformCoodination(leftTop: leftCoodiPoint)
        for i in self.lines{
            let relatePoint = point - i.frameOrigin
            let index = i.hitIndex(point: relatePoint)
            if(index != kCFNotFound){
                return (index,i)
            }
        }
        return (kCFNotFound,nil)
    }
    public func penOffset(leftCoodiPosition:CGPoint,render:CocoOfflineRender)->(CGRect,CFIndex)?{
        let offset = self.hitIndex(leftCoodiPoint: leftCoodiPosition, render: render)
        guard let line = offset.1 else { return nil}
        
        return (line.penOffset(index: offset.0),offset.0)
    }
    public var runDelegateRun:[CocoRun]{
        self.lines.flatMap {$0.runs}.filter {$0.runDelegate != nil }
    }
    public func draw(ctx:CGContext){
        if(isTrancate){
            for line in lines {
                line.draw(ctx: ctx)
            }
        }else{
            CTFrameDraw(self.frame, ctx)
        }
    }
}

extension CocoTextFrame{
    public static func createRunDelegate(run:any CocoRunDelegate,attribute:[NSAttributedString.Key:Any])->NSAttributedString{
        
        var attr = attribute;
        attr[.runDelegate] = run
        attr[NSAttributedString.Key(kCTRunDelegateAttributeName as String)] = run.runDelegate as Any
        return NSAttributedString(string: String(run.char),attributes:attr)
    }
    public func render(frame:CGRect,off: CocoOfflineRender) {
        let layer = off.draw(size: self.size,followCoodinate: off.context.width == 0 ? false : true) { r in
        
            self.draw(ctx: r.context)
            for i in self.runDelegateRun{
                i.runDelegate?.content.render(frame: i.rect, render: r)
            }
        }
        guard let layer else { return }
        let target = CocoOfflineRender.contentModeFrame(itemFrame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), containerFrame: frame, mode: self.contentMode)
        off.context.draw(layer, in: target)
    }
}

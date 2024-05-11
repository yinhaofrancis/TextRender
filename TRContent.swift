//
//  TRTextContent.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import Foundation
import CoreGraphics
import CoreText



extension CGColor:TRContent{
    public var contentMode: TRContentMode {
        .scaleToFill
    }
    
    public func render(frame: CGRect, render:TROfflineRender) {
        render.context.saveGState()
        render.context.setFillColor(self)
        render.context.fill([frame])
        render.context.restoreGState()
    }
    
    public static func mix(c1:CGColor,c2:CGColor,factor:CGFloat = 0.5)->CGColor?{
        guard let cc1 = c1.components , let cc2 = c2.components else { return nil }
        if(cc1.count == cc2.count){
            let c = (0 ..< cc1.count).map { i in
                let c = (cc1[i] * factor + (1 - factor) * cc2[i])
                return c
            }
            guard let colorSpace = c1.colorSpace else { return nil }
            return CGColor(colorSpace: colorSpace, components: c)
        }
        return nil
    }
}

public struct TRVectorImage:TRContent{
    
    
    public var contentMode: TRContentMode
    
    
    public var image:TRPDFImage
    
    public var tintColor:CGColor?
    
    public init(contentMode: TRContentMode, image: TRPDFImage) {
        self.contentMode = contentMode
        self.image = image
    }
    
    fileprivate func drawlayer(render: TROfflineRender,frame: CGRect) {
        if let color = self.tintColor {
            render.context.setFillColor(color)
            render.context.fill([frame])
            render.context.setBlendMode(.destinationIn)
            render.context.beginTransparencyLayer(in: frame, auxiliaryInfo: nil)
            image.draw(ctx: render.context, frame: frame)
            render.context.endTransparencyLayer()
        }else{
            image.draw(ctx: render.context, frame: frame)
        }
    }
    
    public func render(frame: CGRect, render:TROfflineRender) {
        let frame = TROfflineRender.contentModeFrame(itemFrame: image.frame, containerFrame: frame, mode: contentMode)
        render.context.saveGState()
        let layer = render.draw(size: frame.size) { l in
            drawlayer(render: l, frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        }
        guard let layer else { return }
        render.context.draw(layer, in: frame)
        render.context.restoreGState()
    }
}

public struct TRImage:TRContent{
    
    public var image:CGImage
    
    public var tintColor:CGColor?
    
    public var center:CGRect?
    
    public var contentMode: TRContentMode
    
    public init(image: CGImage, contentMode: TRContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
    func drawImageContent(frame:CGRect,render:TROfflineRender){
        render.context.draw(image, in: frame, byTiling: false)
    }
    
    func drawlayer(render: TROfflineRender,frame: CGRect) {
        if let color = self.tintColor {
            render.context.setFillColor(color)
            render.context.fill([frame])
            render.context.setBlendMode(.destinationIn)
            render.context.beginTransparencyLayer(in: frame, auxiliaryInfo: nil)
            render.context.draw(image, in: frame, byTiling: false)
            render.context.endTransparencyLayer()
        }else{
            self.drawImageContent(frame: frame, render: render)
        }
    }
    
    public func render(frame: CGRect,render:TROfflineRender) {
        let frame = TROfflineRender.contentModeFrame(itemFrame: CGRect(x: 0, y: 0, width: image.width, height: image.height), containerFrame: frame, mode: contentMode)
        render.context.saveGState()
        let layer = render.draw(size: frame.size) { l in
            drawlayer(render: l, frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        }
        guard let layer else { return }
        render.context.draw(layer, in: frame)
        render.context.restoreGState()
    }
}

public class TRPattern{
    var patternCallback:CGPatternCallbacks = CGPatternCallbacks(version: 1) { i, ctx in
        let tr = Unmanaged<TRPattern>.fromOpaque(i!).takeUnretainedValue()
        tr.draw(ctx: ctx)
    } releaseInfo: { release in
        Unmanaged<TRPattern>.fromOpaque(release!).release()
    }
    var bound:CGRect
    var matrix:CGAffineTransform = .identity
    var xStep:CGFloat = 44
    var yStep:CGFloat = 44
    var tiling:CGPatternTiling = .constantSpacingMinimalDistortion
    var isColored:Bool
    
    var callback:(TRPattern,CGContext)->Void
    public init(bound:CGRect,xStep:CGFloat? = nil,yStep:CGFloat? = nil,draw:@escaping (TRPattern,CGContext)->Void){
        self.bound = bound
        self.callback = draw
        self.xStep = xStep ?? bound.width
        self.yStep = yStep ?? bound.height
        self.isColored = false
    }
    public var pattern:CGPattern?{
        let p = Unmanaged<TRPattern>.passRetained(self)
        return CGPattern(info: p.toOpaque(), bounds: bound, matrix: matrix, xStep: xStep, yStep: yStep, tiling: tiling, isColored: isColored, callbacks: &self.patternCallback)
    }
    private func draw(ctx:CGContext){
        self.callback(self,ctx)
    }
    public func setFillColorPattern(render:TROfflineRender,alpha:CGFloat){
        guard let cs = CGColorSpace(patternBaseSpace: nil) else { return }
        render.context.setFillColorSpace(cs)
        guard let pattern  else { return  }
        render.context.setFillPattern(pattern, colorComponents: [alpha])
    }
    
    public func setStrokeColorPattern(render:TROfflineRender,alpha:CGFloat){
        guard let cs = CGColorSpace(patternBaseSpace: nil) else { return }
        render.context.setStrokeColorSpace(cs)
        guard let pattern  else { return  }
        render.context.setStrokePattern(pattern, colorComponents: [alpha])
    }
    
    public func setFillMaskPattern(render:TROfflineRender,color:CGColor){
        guard let cs = CGColorSpace(patternBaseSpace: color.colorSpace) else { return }
        render.context.setFillColorSpace(cs)
        guard let pattern  else { return  }
        render.context.setFillPattern(pattern, colorComponents: color.components ?? [1,1,1,1])
    }
    
    public func setStrokeMaskPattern(render:TROfflineRender,color:CGColor){
        guard let cs = CGColorSpace(patternBaseSpace: color.colorSpace) else { return }
        render.context.setStrokeColorSpace(cs)
        guard let pattern  else { return  }
        render.context.setStrokePattern(pattern, colorComponents:color.components ?? [1,1,1,1])
    }
}


public struct TRGradient{
    
    public var colorspace:CGColorSpace?
    
    public var components:[TRGradientComponent]
    
    public init(colorspace:CGColorSpace?,components: [TRGradientComponent]) {
        self.colorspace = colorspace
        self.components = components
    }
    
    public static func gradient(colorspace:CGColorSpace = CGColorSpaceCreateDeviceRGB() , @TRGradient.TRGradientBuider _  callback: ()->TRGradient)->TRGradient{
        return callback()
    }
}
extension TRGradient {
    
    
    public var gradient:CGGradient?{
        let location = self.components.map { $0.postion }
        return CGGradient(colorsSpace: self.colorspace, colors: self.components.map {$0.color} as CFArray, locations: location)
    }
    
    public struct TRGradientComponent{
        public var color:CGColor
        public var postion:CGFloat
        public init(color: CGColor, postion: CGFloat) {
            self.color = color
            self.postion = postion
        }
    }
    
    @resultBuilder
    public struct TRGradientBuider{
        public static func buildBlock(_ components: TRGradientComponent...) -> TRGradient {
            TRGradient(colorspace: nil,components: components)
        }
    }
}

//
//  CocoImage.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/25.
//

import QuartzCore
import UIKit

public struct CocoPDFImage{
    fileprivate var page:CGPDFPage
    public var box:CGRect{
        return page.getBoxRect(.mediaBox)
    }
    public func draw(ctx:CGContext,frame:CGRect){
        ctx.saveGState()
        ctx.translateBy(x: frame.minX, y: frame.minY)
        ctx.scaleBy(x: frame.width / self.box.width, y: frame.height / self.box.height)
        ctx.drawPDFPage(self.page)
        ctx.restoreGState()
    }
    public var frame:CGRect{
        return self.page.getBoxRect(.mediaBox)
    }
}
public struct CocoPDFImageSet{
    
    private var document:CGPDFDocument
    
    public init(url:URL) throws{
        guard let current = CGPDFDocument(url as CFURL) else {
            throw NSError(domain: "create pdf resource fail", code: 0)
        }
        self.document = current
    }
    public subscript(_ index:Int)->CocoPDFImage?{
        guard let page = self.document.page(at: index) else {
            return nil
        }
        return CocoPDFImage(page: page)
    }
    
    public var count:Int{
        self.document.numberOfPages
    }
}
public struct CocoVectorImage:CocoContent{
    
    public var image:CocoPDFImage
    
    public var contentMode: CocoContentMode
    
    
    
    public func render(frame: CGRect, render: CocoOfflineRender) {
        var itemFrame = self.image.frame
        itemFrame.origin = .zero
        let target = CocoOfflineRender.contentModeFrame(itemFrame: itemFrame, containerFrame: frame, mode: self.contentMode)
        self.image.draw(ctx: render.context, frame: target)
    }

    public init(image: CocoPDFImage, contentMode: CocoContentMode = .scaleAspectFit(0.5)) {
        self.image = image
        
        self.contentMode = contentMode
    }
}

public struct CocoPixelImage:CocoContent{
    
    public var image:CGImage
    
    public var contentMode: CocoContentMode
    
    public func render(frame: CGRect, render: CocoOfflineRender) {
        var itemFrame = CGRect(x: 0, y: 0, width: self.image.width, height: self.image.height)
        itemFrame.origin = .zero
        let target = CocoOfflineRender.contentModeFrame(itemFrame: itemFrame, containerFrame: frame, mode: self.contentMode)
        render.context.draw(self.image, in: target, byTiling: false)
    }

    public init(image: CGImage, contentMode: CocoContentMode = .scaleAspectFit(0.5)) {
        self.image = image
        
        self.contentMode = contentMode
    }
}

public struct Block:CocoContent{
    public func render(frame: CGRect, render: CocoOfflineRender) {
        let itemFrame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let target = CocoOfflineRender.contentModeFrame(itemFrame: itemFrame, containerFrame: frame, mode: self.contentMode)
        render.context.saveGState()
        render.context.setFillColor(self.color)
        render.context.fill([target])
        render.context.restoreGState()
    }
    
    public var color:CGColor
    
    public var size:CGSize
    
    public var contentMode: CocoContentMode
}



@resultBuilder
public struct CocoGradient{
    public static func buildBlock(_ components: GradientItem...) -> CocoGradient {
        CocoGradient(items: components)
    }
    public static func buildArray(_ components: [CocoGradient]) -> CocoGradient {
        CocoGradient(items: components.flatMap({ i in
            i.items
        }))
    }
    public struct GradientItem{
        public var color:CGColor
        public var location:CGFloat
        public init(color: CGColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
    }
    
    public var items:[GradientItem]
    
    
    public init(items: [GradientItem]) {
        self.items = items
    }
    
    public var gradient:CGGradient?{
        let cls = self.items.map({ g in
            g.color
        })
        let posi = self.items.map { g in
            g.location
        }
        return CGGradient(colorsSpace: self.items.first?.color.colorSpace, colors: cls as CFArray, locations: posi)
    }
}


public struct LinearGradient:CocoContent{
    
    
    public var gradient:CocoGradient
    
    public var contentMode: CocoContentMode
    
    public var startPoint:CGPoint
    
    public var endPoint:CGPoint
    
    public func render(frame: CGRect, render: CocoOfflineRender) {
        let start = frame.origin + CGPoint(x: frame.width * startPoint.x, y: frame.height * startPoint.y)
        let end = frame.origin + CGPoint(x: frame.width * endPoint.x, y: frame.height * endPoint.y)
        guard let gradient = gradient.gradient else { return }
        render.context.saveGState()
        render.context.clip(to: [frame])
        render.context.drawLinearGradient(gradient, start: start, end: end, options: .init(rawValue: 0))
        render.context.restoreGState()
    }
    
    public init(@CocoGradient gradient: ()->CocoGradient, 
                contentMode: CocoContentMode,
                startPoint: CGPoint,
                endPoint: CGPoint) {
        self.gradient = gradient()
        self.contentMode = contentMode
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}

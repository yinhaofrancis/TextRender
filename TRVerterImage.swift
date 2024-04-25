//
//  TRVerterImage.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/25.
//

import QuartzCore
import UIKit

public struct TRVerterImage{
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
public struct TRVerterImageSet{
    
    private var document:CGPDFDocument
    
    public init(url:URL) throws{
        guard let current = CGPDFDocument(url as CFURL) else {
            throw NSError(domain: "create pdf resource fail", code: 0)
        }
        self.document = current
    }
    public subscript(_ index:Int)->TRVerterImage?{
        guard let page = self.document.page(at: index) else {
            return nil
        }
        return TRVerterImage(page: page)
    }
    
    public var count:Int{
        self.document.numberOfPages
    }
}
//



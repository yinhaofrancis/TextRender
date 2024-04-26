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
    
    func render(frame:CGRect,ctx:CGContext)
}

public protocol TRRenderable:TRRenderFrame{
    
    associatedtype T:TRContent
    
    var content:T { get }

}
extension TRRenderable{
    public func draw(ctx:CGContext){
        self.draw(frame: self.frame, ctx: ctx)
    }
    public func draw(frame:CGRect, ctx:CGContext){
        content.render(frame: frame, ctx: ctx)
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
    
    public var descent: CGFloat = 0
    
    public var ascent: CGFloat = 0
    
    public var width: CGFloat = 0
    
    public func load(descent: CGFloat, ascent: CGFloat, width: CGFloat) {
        self.descent = descent
        self.ascent = ascent
        self.width = width
    }
    
    public var content: T
    
    
    public init(content: T) {
        self.content = content
    }
}
public class TRSpacing:TRRunView<TRView<CGColor>>{
    
    public override var char: Character {
        " "
    }
    
    public var spacing:CGFloat
    
    public override var width: CGFloat{
        get{
            return spacing
        }
        set{
//            spacing = newValue
        }
    }
    public init(spacing: CGFloat) {
        self.spacing = spacing
        super.init(content: TRView(content: UIColor.clear.cgColor))
    }
    
}

extension TRRunView {
    public func createAttibuteString(font:UIFont,attribute:[NSAttributedString.Key:Any])->NSAttributedString{
        self.loadFont(font: font)
        let att = TRTextFrame.createRunDelegate(run: self, attribute: attribute)
        return att
    }
}

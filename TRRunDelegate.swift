//
//  TRRunDelegate.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit

public protocol TRRunDelegate {
    
    associatedtype R:TRRenderable
    
    var char:Character { get }
    
    var descent:CGFloat { get }
    
    var ascent:CGFloat { get }
    
    var width:CGFloat { get }
    
    var content:R { get }
}





class WrapRunDelegate{
    var tRunDelegate:any TRRunDelegate
    init(tRunDelegate: any TRRunDelegate) {
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



public protocol TRFrameRunDelegate:TRRunDelegate{
    
    var frame:CGRect { get }
    
    var percent:CGFloat { get }
    
    func loadFrame(frame:CGRect,percent:CGFloat)
}

public protocol TRFontRunDelegate:TRRunDelegate{
    
}



func + (left:NSAttributedString,right:NSAttributedString)->NSAttributedString{
    let a = NSMutableAttributedString(attributedString: left)
    a.append(right)
    return a
}

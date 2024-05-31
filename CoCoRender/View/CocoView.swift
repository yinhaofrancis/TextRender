//
//  CocoView.swift
//  CoCoRender
//
//  Created by FN-540 on 2024/5/21.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit

public protocol CocoView{
    var size:CGSize { get }
    func draw(frame:CGRect,render:CocoOfflineRender)
}



public struct Stack:CocoView{
    
    public enum Axis{
        case vertical
        case horizental
    }
    
    public enum Align{
        case start
        case center
        case end
        case fill
    }
    
    public var size: CGSize{
        switch(axis){
            
        case .vertical:
            let w = self.contents.max { a, b in
                a.size.width < b.size.width
            }?.size.width
            
            let h = self.contents.reduce(0) { partialResult, c in
                partialResult + c.size.height
            }
            return CGSize(width: w ?? 0, height: h)
        case .horizental:
            let h = self.contents.max { a, b in
                a.size.height < b.size.height
            }?.size.height
            
            let w = self.contents.reduce(0) { partialResult, c in
                partialResult + c.size.width
            }
            return CGSize(width: w, height: h ?? 0)
        }
    }
    
    public var axis: Axis
    
    public var align:Align
    
    public var contents:[CocoView] = []
    
    public func draw(frame: CGRect, render: CocoOfflineRender) {
        
    }
    
    
    public init(axis: Axis, align: Align, contents: [CocoView]) {
        self.axis = axis
        self.align = align
        self.contents = contents
    }
}


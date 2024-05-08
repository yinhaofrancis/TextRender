//
//  TRRuby.swift
//  TextRender
//
//  Created by FN-540 on 2024/5/8.
//

import Foundation
import CoreText
import CoreGraphics
import UIKit


public struct TRRuby{
    public let ruby:CTRubyAnnotation
    
    public init(ruby: CTRubyAnnotation) {
        self.ruby = CTRubyAnnotationCreateCopy(ruby)
    }
    
    public init(string:String,
                alignment: CTRubyAlignment,
                overhang: CTRubyOverhang,
                position: CTRubyPosition,
                attribute:[NSAttributedString.Key:Any]){
        self.ruby = CTRubyAnnotationCreateWithAttributes(alignment, overhang, position, string as CFString, attribute as CFDictionary)
    }
    public init(string:String,
                alignment: CTRubyAlignment,
                verhang: CTRubyOverhang,
                factor:CGFloat){
        var text: [Unmanaged<CFString>?] = [Unmanaged<CFString>.passRetained(string as CFString) as Unmanaged<CFString>, .none, .none, .none]
        self.ruby = CTRubyAnnotationCreate(alignment, verhang, factor, &text[0])
    }
}
extension NSAttributedString.Key {
    public static let rubyAnnotation = NSAttributedString.Key(kCTRubyAnnotationAttributeName as String)
}

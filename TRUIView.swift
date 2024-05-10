//
//  TRLabel.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import UIKit

public struct TRUIViewProperty:Hashable{
    public var content:NSAttributedString?
}

public class TRUIView:UIView{
    public var property:TRUIViewProperty = TRUIViewProperty(){
        didSet{
            self.setNeedsLayout()
        }
    }
    private var displayContent:NSAttributedString?{
        return self.property.content
    }
    private var cache:TRTextFrame?
    
    public var renderMode:TRContentMode = .center(1)
    
    private var render:TROfflineRender?
    
    public var scale:CGFloat?
    
    private var innerScale:CGFloat {
        return self.scale ?? self.layer.contentsScale
    }
    
    var contentMaxWidth:CGFloat{
        self.self.bounds.width
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        if(Int(size.width) != Int(self.contentMaxWidth)){
            self.invalidateIntrinsicContentSize()
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
        }else if let text = self.displayContent{
            
            self.layer.contentsScale = 3
            let tral = NSAttributedString(string: "……")
            let content = TRTextFrame(constaint: size, string: text, truncation: tral)
            self.cache = content
            let scale = self.innerScale
            let container = self.bounds
            let mode = self.renderMode
            self.render = try? TROfflineRender(width: Int(size.width), height: Int(size.height), scale: Int(scale))
            DispatchQueue.global().async {
                let image = self.render?.draw { helper in
                    guard let l = content.render(scale: Int(scale)) else { return }
                    let itemframe = CGRect(origin: .zero, size: content.size)
                    let target =  TROfflineRender.contentModeFrame(itemFrame: itemframe, containerFrame: container, mode: mode)
                    helper.context.draw(l, in: target, byTiling: false)
                }
                DispatchQueue.main.async {
                    if self.cache == content{
                        self.layer.contents = image
                    }
                }
            }
        }
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.cache = nil
    }

    public override var intrinsicContentSize: CGSize{
        guard let text = self.displayContent else { return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric) }
        let content = TRTextFrame(width: self.contentMaxWidth, string: text)
        return content.size
    }
}


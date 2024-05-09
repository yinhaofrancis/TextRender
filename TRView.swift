//
//  TRLabel.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import UIKit



public class TRUIView:UIControl{
    public var content:NSAttributedString?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public var selectedContent:NSAttributedString?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public var hightlightContent:NSAttributedString?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public var disableContent:NSAttributedString?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public override var isSelected: Bool{
        set{
            super.isSelected = newValue
            self.setNeedsLayout()
        }
        get{
            return super.isSelected
        }
    }
    public override var isEnabled: Bool{
        set{
            super.isEnabled = newValue
            self.setNeedsLayout()
        }
        get{
            super.isEnabled
        }
    }
    public override var isHighlighted: Bool{
        get{
            super.isHighlighted
        }
        set{
            super.isHighlighted = newValue
            self.setNeedsLayout()
        }
    }
    
    private var displayContent:NSAttributedString?{
        if(!self.isEnabled){
            return self.disableContent ?? self.content
        }
        if(self.isHighlighted){
            return self.hightlightContent ?? self.selectedContent ?? self.content
        }
        if(self.isSelected){
            return self.selectedContent ?? self.content
        }
        return self.content
    }
    private var cache:TRTextFrame?
    
    public var renderMode:TRContentMode = .center(1)
    
    private var render:TROfflineRender?
    
    public var scale:CGFloat?
    
    private var innerScale:CGFloat {
        return self.scale ?? self.layer.contentsScale
    }
    
    lazy var contentMaxWidth:CGFloat = self.bounds.width
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.addTarget(self, action: #selector(hit(sender:event:)), for: .touchUpInside)
        let size = self.bounds.size
        if(Int(size.width) != Int(self.contentMaxWidth)){
            self.contentMaxWidth = size.width
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
    @objc func hit(sender:Any,event:UIEvent){
        guard let point = event.allTouches?.first?.location(in: self) else { return }
        guard let render = self.render else { return }
        guard let r = self.cache?.hitIndex(leftCoodiPoint: point, render: render) else { return }
        guard let range = r.1?[r.0]?.range else { return }
    }
}

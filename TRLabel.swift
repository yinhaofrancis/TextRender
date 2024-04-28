//
//  TRLabel.swift
//  TextRender
//
//  Created by FN-540 on 2024/4/26.
//

import UIKit

public class TRLabel:UIView{
    public var text:NSAttributedString?{
        didSet{
            self.setNeedsDisplay()
            self.contentSize = nil
        }
    }
    public var renderMode:TROfflineRender.ContentMode = .center(1)
    public var contentSize:CGSize?
    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        if contentSize == nil,let text = self.text{
            self.contentSize = TRTextFrame(width: self.bounds.size.width, string: text).size
            self.setNeedsLayout()
            self.invalidateIntrinsicContentSize()
        }else if let text = self.text{
            self.layer.contentsScale = 3
            let tral = NSAttributedString(string: "……")
            let content = TRTextFrame(constaint: size, string: text, truncation: tral)
            let image = try? TROfflineRender(width: Int(size.width), height: Int(size.height), scale: Int(self.layer.contentsScale)).draw { helper in
                guard let l = content.render(helper: helper) else { return }
                let itemframe = CGRect(origin: .zero, size: content.size)
                let container = self.bounds
                let target =  TROfflineRender.contentMode(itemFrame: itemframe, containerFrame: container, mode: self.renderMode)
                helper.context.draw(l, in: target)
            }
            self.layer.contents = image
        }
    }
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.contentSize = nil
    }
    public override func updateConstraints() {
        super.updateConstraints()
    }
    public override var intrinsicContentSize: CGSize{
        return contentSize ?? CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}

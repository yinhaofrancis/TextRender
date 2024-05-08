//
//  TViewController.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/18.
//

import Accelerate

import UIKit

let scale :CGFloat = 2
class TViewController: UIViewController {

    @IBOutlet var imageV:TRButton!
    @IBOutlet var imagevv:TestPatternView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageV.tintColor = .clear
        self.imageV.imageURL = image
        self.imageV.title = text
        self.imageV.font = UIFont.systemFont(ofSize: 16)
        self.imageV.imageSize = 36
        self.imageV.titleColor = UIColor.green
        let t = TRPattern(bound: CGRect(x: 0, y: 0, width: 44, height: 44),xStep: 34,yStep: 34, draw: { pattern,ctx  in
            ctx.addEllipse(in: CGRect(x: 0, y: 0, width: 44, height: 44))
            ctx.drawPath(using: .stroke)
        })
        t.isColored = false
        self.imagevv.pattern = t
        
    }
    
    var text:String = "更多"
    var image:URL = Bundle.main.url(forResource: "more", withExtension: "pdf")!
    

}


public class TRButton:TRLabel{
    public var imageURL:URL?{
        didSet{
            self.content = self.style
        }
    }
    public var title:String?{
        didSet{
            self.content = self.style
        }
    }
    public var titleColor:UIColor?{
        didSet{
            self.content = self.style
        }
    }
    public var font:UIFont = UIFont.systemFont(ofSize: 12){
        didSet{
            self.content = self.style
        }
    }
    public var imageSize:CGFloat = 36{
        didSet{
            self.content = self.style
        }
    }
    
    private var style:NSAttributedString{
        let a = NSMutableAttributedString()
        let param:NSMutableParagraphStyle = NSMutableParagraphStyle()
        param.alignment = .center
        if let imageURL{
            let tx = try! TRPDFImageSet(url: imageURL)
            let image = TRTextImage(image: tx[1]!, font: UIFont.systemFont(ofSize: self.imageSize), contentMode: .scaleAspectFit(0.5))
            image.content.content.tintColor = self.tintColor == .clear ? nil : self.tintColor.cgColor
            let aimag = image.createAttibuteString(attribute: [.paragraphStyle:param])
            a.append(aimag)
        }
        
        if let title {
            let text = NSAttributedString(string: "\n" + title, attributes: [
                .paragraphStyle:param,
                .font:self.font,
                .foregroundColor:self.titleColor ?? self.tintColor as Any
            ])
            a.append(text)
        }
        return a
    }
}

public class TestPatternView:UIImageView{
    public var pattern:TRPattern?{
        didSet{
            self.draw()
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.draw()
    }
    public func draw(){
        guard let pattern = pattern?.pattern else { self.image = nil; return }
        guard let render = try? TROfflineRender(width: Int(self.bounds.width), height: Int(self.bounds.height), scale: 3) else {
            self.image = nil;
            return
        }
        let image = render.draw { t in
            
            t.context.addRect(self.bounds)
            t.context.setFillColor(UIColor.orange.cgColor)
            t.context.fillPath()
            self.pattern?.setFillMaskPattern(render: t, color: UIColor.blue.cgColor)
            t.context.addRect(self.bounds)
//            t.context.setFillColor(UIColor.green.cgColor)
            t.context.fillPath()
        }
        guard let image else { self.image = nil; return }
        self.image = UIImage(cgImage: image, scale: 3, orientation: .up)
    }
}

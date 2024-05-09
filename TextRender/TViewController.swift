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
        self.imageV.selectTitleColor = UIColor.yellow
        let t = TRPattern(bound: CGRect(x: 0, y: 0, width: 44, height: 44),xStep: 34,yStep: 34, draw: { pattern,ctx  in
            ctx.addEllipse(in: CGRect(x: 0, y: 0, width: 44, height: 44))
            ctx.drawPath(using: .stroke)
        })
        t.isColored = false
        self.imagevv.pattern = t
        let gradient = TRGradient.gradient {
            TRGradient.TRGradientComponent(color: UIColor.red.cgColor, postion: 0)
            TRGradient.TRGradientComponent(color: UIColor.yellow.cgColor, postion: 1)
        }
    }
    
    var text:String = "更多"
    var image:URL = Bundle.main.url(forResource: "more", withExtension: "pdf")!
    

}


public class TRButton:TRUIView{
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        self.addTarget(self, action: #selector(onHit), for: .touchDown)


        self.addTarget(self, action: #selector(onHitOff), for: [.touchUpOutside,.touchUpInside])
    }
    @objc func onHit(){
        self.isHighlighted = true
    }
    @objc func onHitOff(){
        self.isHighlighted = false
    }
    public var imageURL:URL?{
        didSet{
            self.property.content = self.style
        }
    }
    public var title:String?{
        didSet{
            self.property.content = self.style
        }
    }
    public var titleColor:UIColor?{
        didSet{
            self.property.content = self.style
        }
    }
    public var selectTitleColor:UIColor?{
        didSet{
            self.property.selectedContent = self.selectStyle
        }
    }
    public var font:UIFont = UIFont.systemFont(ofSize: 12){
        didSet{
            self.property.content = self.style
        }
    }
    public var imageSize:CGFloat = 36{
        didSet{
            self.property.content = self.style
        }
    }
    private var selectStyle:NSAttributedString{
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
                .foregroundColor:self.selectTitleColor ?? self.titleColor ?? self.tintColor as Any
            ])
            a.append(text)
        }
        return a
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
        guard let pattern = pattern else { self.image = nil; return }
        guard let render = try? TROfflineRender(width: Int(self.bounds.width), height: Int(self.bounds.height), scale: 3) else {
            self.image = nil;
            return
        }
        let gradient = TRGradient.gradient {
            TRGradient.TRGradientComponent(color: UIColor.red.cgColor, postion: 0)
            TRGradient.TRGradientComponent(color: CGColor.percent(c1: UIColor.red.cgColor, c2: UIColor.yellow.cgColor)!, postion: 0.5)
            TRGradient.TRGradientComponent(color: UIColor.yellow.cgColor, postion: 1)
        }
        let image = render.draw { t in
            
            t.context.addRect(self.bounds)
            t.context.clip()
            t.context.drawLinearGradient(gradient.gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: t.width, y: 0), options: .init(rawValue: 0))
            pattern.setFillMaskPattern(render: t, color: UIColor.blue.cgColor)
            t.context.addRect(self.bounds)
//            t.context.setFillColor(UIColor.green.cgColor)
            t.context.fillPath()
        }
        guard let image else { self.image = nil; return }
        self.image = UIImage(cgImage: image, scale: 3, orientation: .up)
    }
}

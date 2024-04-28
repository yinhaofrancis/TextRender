//
//  TViewController.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/18.
//

import UIKit

let scale :CGFloat = 5
class TViewController: UIViewController {

    @IBOutlet var imageV:UIImageView!
    
    var label:TRLabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        let font = TROfflineRender.registerFont(url: Bundle.main.url(forResource: "DINPRO-BOLD", withExtension: "OTF")!)
        print(font)
        
        let label = TRLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.view.addSubview(label)
        let a = [
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ]
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(a)
        self.view.addConstraint(label.heightAnchor.constraint(equalToConstant: 65))
        self.label = label
        self.label?.text = self.attribute
        self.loadImage()
    }
    
    
    func drawImage() {
        let offset:CGFloat = CGFloat.random(in: 0 ... 1)
        
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "avd", withExtension:"pdf")!)[1]
        
        let v = TRView(content: TRVectorImage(contentMode: .scaleAspectFit(offset), image: image!), frame: CGRect(x:10, y: 10, width: 350, height: 480))
        let render = try! TROfflineRender(width: Int(self.view.frame.width), height: Int(self.view.frame.height), scale: 3)
        let cgimg = render.draw { tool in
            tool.context.fill([CGRect(x: 10, y: 10, width: 350, height: 480)])
            v.draw(ctx: tool.context)
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
    
    func renderText() {
        let t = TRTextFrame(width: 320, string: NSAttributedString(string: "dadasda", attributes: [
            .font:UIFont(name: "DINPro-Bold", size: 15),.foregroundColor:UIColor.red
        ]))
        
        let frame = t.size
        let render = try! TROfflineRender(width: Int(frame.width), height: Int(frame.height), scale: 3)
        
        let cgimg = render.draw { helper in
            guard let l = t.render(helper: helper) else { return }
            helper.context.draw(l, in: CGRect(origin: .zero, size: frame))
            
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
    var spacing:CGFloat = 0
    var render:TROfflineRender?
    var indicate:UIView = {
       let v = UIView()
        v.backgroundColor = UIColor.red
        
        return v
    }()
    func loadAnimation(l:CALayer){
 
        let a = CABasicAnimation(keyPath: "opacity")
        a.fromValue = 1;
        a.toValue = 0;
        a.duration = 0.5
        a.repeatCount = .infinity
        a.autoreverses = true
        l.add(a, forKey: nil)
    }
    
    lazy var attribute:NSAttributedString = {
        let param = NSMutableParagraphStyle()
        param.minimumLineHeight = 8
        let p:[NSAttributedString.Key:Any] = [
            .font:UIFont(name: "DINPro-Bold", size: 28)!,
            .foregroundColor:UIColor.black,
            .paragraphStyle : param
        ]
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "avd", withExtension:"pdf")!)[1]
        let offset:CGFloat = 0.5
        let v = TRRunView(content: TRView(content: TRVectorImage(contentMode: .scaleAspectFit(offset), image: image!)))
        let spacing:CGFloat = 10
        var att = v.createAttibuteString(font: UIFont.systemFont(ofSize: 28), attribute: p) +
        TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) +
        NSAttributedString(string: "this is my life please", attributes: p)
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + att
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + att
        return att
    }()
    
    func loadImage(){
        let r = TRTextFrame(width:320, string: self.attribute)
        
        let frame = r.size
        
        render = try! TROfflineRender(width: Int(frame.width), height: Int(frame.height), scale: 3)
        let cgimg = render?.draw { helper in
            guard let l = r.render(helper: helper) else { return }
            helper.context.draw(l, in: CGRect(origin: .zero, size: frame))
            r.drawLineFrame(ctx: helper.context)
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let r = TRTextFrame(width:320, string: self.attribute)
        
        guard let p = touches.first?.location(in: self.imageV) else { return }
        let index = r.penOffset(leftCoodiPosition: p, render: render!)
        let transform = render?.transformCoodinationToLeftTopTransform()
        indicate.frame = index?.0.applying(transform ?? .identity) ?? .zero
        self.imageV.addSubview(indicate)
        self.loadAnimation(l: indicate.layer)
        
    }
    
}

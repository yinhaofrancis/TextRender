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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func drawImage() {
        let offset:CGFloat = CGFloat.random(in: 0 ... 1)
        
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "iphone_portrait", withExtension:"pdf")!)[1]
        
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
            .font:UIFont.systemFont(ofSize: 15),.foregroundColor:UIColor.red
        ]))
        
        let frame = t.size
        let render = try! TROfflineRender(width: Int(frame.width), height: Int(frame.height), scale: 3)
        
        let cgimg = render.draw { helper in
            guard let l = t.render(helper: helper) else { return }
            helper.context.draw(l, in: CGRect(origin: .zero, size: frame))
            
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let offset:CGFloat = 0.5
        let spacing = CGFloat.random(in: 0 ..< 40)
        
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "iphone_portrait", withExtension:"pdf")!)[1]
        
        let v = TRRunView(content: TRView(content: TRVectorImage(contentMode: .scaleAspectFit(offset), image: image!)))
        
        let param = NSMutableParagraphStyle()
        param.minimumLineHeight = 64
        let p:[NSAttributedString.Key:Any] = [
            .font:UIFont.systemFont(ofSize: 28),
            .foregroundColor:UIColor.black,
            .paragraphStyle : param
        ]
        var att = v.createAttibuteString(font: UIFont.systemFont(ofSize: 28), attribute: p) +
        TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) +
        NSAttributedString(string: "😊😊😊😊😊", attributes: p)
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + att
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + att
        var r = TRTextFrame(constaint: CGSize(width: 200, height: 128), string: att, truncation: NSAttributedString(string: "……", attributes: [
            .font:UIFont.systemFont(ofSize: 28)
        ]))
        
        let frame = r.size
        let render = try! TROfflineRender(width: Int(frame.width), height: Int(frame.height), scale: 3)
        let cgimg = render.draw { helper in
            guard let l = r.render(helper: helper) else { return }
            helper.context.draw(l, in: CGRect(origin: .zero, size: frame))
            r.drawLineFrame(ctx: helper.context)
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
    
}

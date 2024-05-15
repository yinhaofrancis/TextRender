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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let r = try! TROfflineRender(width: self.view.bounds.width, height: self.view.bounds.height, scale: 3)

        r.screenCoodinate = true
        
        

        let img = TRView(content: TRImage(image: UIImage.k.cgImage!, contentMode: .scaleAspectFit(0.5)), frame: CGRect(x: 50, y: 50, width: 100, height: 200))
    
        let pv = try! TRPDFImageSet(url: Bundle.main.url(forResource: "msg", withExtension: "pdf")!)[1]!
        let v = TRView(content: TRVectorImage(contentMode: .scaleAspectFit(0.5), image:pv), frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        
        var block = Padding(content: Shadow(content: TransparencyLayer(content: Corner(content: Pixel(image: UIImage.k.cgImage!), corner: 8)), shadowRadius: 20, shadowOffset: CGSize(width: -1, height: -1)), padding: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        
        var block2 = Background(content: Resize(content: block, frame: CGSize(width: 100, height: 250), contentMode: .scaleAspectFit(0.5)), color: UIColor.yellow.cgColor)
        var block3 = Background(content: Resize(content: Text(text: "abc", font: UIFont.systemFont(ofSize: 22), textColor: UIColor.green), frame: CGSize(width: 100, height: 200), contentMode: .scaleAspectFit(0.5)), color: UIColor.red.cgColor)
        let a = NSMutableAttributedString()
        a.append(TRTextImage(image: pv, font: UIFont.systemFont(ofSize: 20), contentMode: .scaleAspectFit(0.5)).createAttibuteString(attribute: [:]))
        a.append(TRSpacing(font: UIFont.systemFont(ofSize: 20), size: 2).createAttibuteString(attribute: [:]))
        a.append(NSAttributedString(string: "Francis", attributes: [
            .font:UIFont.systemFont(ofSize: 20),
            .foregroundColor:UIColor.red
        ]))
        let tag = TRTextTag(textframe: TRTextFrame(width: 64, string: a), font: UIFont.systemFont(ofSize: 64))
        var block4 = Background(content: Resize(content: RichText(text: a), frame: CGSize(width: 100, height: 150), contentMode: .scaleAspectFit(0.5)), color: UIColor.gray.cgColor)
        
        
        
        var stack = Stack {
            block2
            Spacing(contentSize: CGSize(width: 20, height: 20))
            block3
            Spacing(contentSize: CGSize(width: 20, height: 20))
            block4
        }
        var stack2 = Stack{
            stack
            Spacing(contentSize: CGSize(width: 20, height: 20))
            stack
        }
        stack.align = .end
        stack2.axis = .col
        print(stack.contentSize)
        let dimg = r.draw { t in
//            let layer = t.draw(size: self.view.frame.size) { r in
                stack2.draw(container: CGRect(x: 10, y: 80, width: stack.contentSize.width, height: stack2.contentSize.height), render: t)
//            }
//            t.context.draw(layer!, at: .zero)

////////
//            Text(text: "abc", font: UIFont.systemFont(ofSize: 8), textColor: UIColor.green).draw(container: CGRect(x: 0, y: 0, width: 100, height: 100), render: t)
//            

        }
        self.view.layer.contents = dimg
        
        
    }
    

}

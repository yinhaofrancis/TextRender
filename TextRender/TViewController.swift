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
//        r.toScreenCoodinate()
        r.screenCoodinate = true
//        r.screenCoodinate = false
        let img = TRView(content: TRImage(image: UIImage.k.cgImage!, contentMode: .scaleAspectFit(0.5)), frame: CGRect(x: 50, y: 50, width: 100, height: 200))
    
        let pv = try! TRPDFImageSet(url: Bundle.main.url(forResource: "msg", withExtension: "pdf")!)[1]!
        let v = TRView(content: TRVectorImage(contentMode: .scaleAspectFit(0.5), image:pv), frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        

        let node = ContainerSpan(font: UIFont.systemFont(ofSize: 44, weight: .bold)) {
            ImageSpan(image: UIImage.k.cgImage!, font: UIFont.systemFont(ofSize: 44), mode: .scaleAspectFit(0.5))
            SpacingSpan(size: 10, font: UIFont.systemFont(ofSize: 10))
            TextSpan(string: "tetst", font: UIFont.systemFont(ofSize: 44), textColor: UIColor.red)
        }
        
        let ttt = TRView(content: TRTextFrame(width: .zero, string: node.attributeString), frame: CGRect(x: 180, y: 90, width: 96, height: 80))
        
        var block = Shadow(content: TransparencyLayer(content: Corner(content: Pixel(frame: CGRect(x: 30, y: 300, width: 100, height: 100), image: UIImage.k.cgImage!), corner: 8)), shadowRadius: 20, shadowOffset: CGSize(width: -1, height: -1))
        
        let a = r.draw { t in
            img.draw(render: t)
            v.draw(render: t)
            ttt.draw(render: t)
            block.draw(render: t)
            
            block.frame = CGRect(x: 30, y: 400, width: 66, height: 66)
            block.draw(render: t)
        }
        self.view.layer.contents = a
        
        
    }
    

}

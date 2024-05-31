//
//  TViewController.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/18.
//

import Accelerate
import UIKit
import CoCoRender
import TorRender
let scale :CGFloat = 2
class TViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        var atstring = NSAttributedString(string: "abc", attributes: [
            .font:UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor:UIColor.red
        ])
        let block = CocoTextBlock(textFrame: CocoTextFrame(width: 1000, string: atstring), contentMode: .center(1))
        
        atstring = atstring + NSAttributedString.block(font: .systemFont(ofSize: 18), width: 50, color: UIColor.yellow.cgColor) + NSAttributedString.image(font: UIFont.systemFont(ofSize: 18), image: UIImage.k.cgImage!, contentMode: .scaleAspectFit(0.5)) + NSAttributedString.linearGradient(font: .systemFont(ofSize: 18), image: {
            CocoGradient.GradientItem(color: UIColor.red.cgColor, location: 0)
            CocoGradient.GradientItem(color: UIColor.blue.cgColor, location: 1)
        }, startPoint: CGPoint.zero, endPoint: CGPoint(x: 1, y: 0), contentMode: .center(1))
        
        
        
        var atstring2 = NSAttributedString(string: "Ndk", attributes: [
            .font:UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor:UIColor.red
        ])
        atstring2 = atstring2 + NSAttributedString.image(font: .systemFont(ofSize: 20), image: UIImage.p.cgImage!, contentMode: .scaleAspectFit(0.5))
        atstring = atstring + NSAttributedString.textBlock(text: atstring2, width: 200, font: .systemFont(ofSize: 20), contentMode: .scaleAspectFit(0.5))
        
        let frame = CocoTextFrame(width: 300, string: atstring)
        
        self.view.layer.contentsScale = 3
        let render = try! CocoOfflineRender(width: self.view.frame.width, height: self.view.frame.height, scale: self.view.layer.contentsScale)
        render.screenCoodinate = true
        let image = render.draw { r in
            let rf = frame.size
            frame.render(frame: CGRect(origin: .init(x: 50, y: 50), size: rf), render: r)
        }
        self.view.layer.contents = image
    }
}

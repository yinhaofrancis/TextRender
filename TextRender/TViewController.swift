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
    
    @IBOutlet var vv:TRUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let p = NSMutableParagraphStyle()
        p.paragraphSpacing = 5
        
        let v = ContainerSpan(font: UIFont.systemFont(ofSize: 44)) {
            ImageSpan(image: UIImage.k.cgImage!, font: UIFont.systemFont(ofSize: 44), mode: .scaleAspectFit(0.5))
            SpacingSpan(size: 10, font: UIFont.systemFont(ofSize: 44))
            ContainerSpan(maxWidth: 260,contentTypingAttribute: [.paragraphStyle:p],font:UIFont.systemFont(ofSize: 44)) {
                TextSpan(string: "用户昵称用户昵称10字", font: UIFont.systemFont(ofSize: 12, weight: .medium), textColor: UIColor.black)
                SpacingSpan(size: 5, font: UIFont.systemFont(ofSize: 12))
                ImageSpan(image: UIImage.k.cgImage!, font: UIFont.systemFont(ofSize: 12, weight: .medium), mode: .scaleAspectFit(0.5))
                TextSpan(string: "\n申请4号麦位", font: UIFont.systemFont(ofSize: 12), textColor: UIColor.gray)
            }
        }.attributeString
        self.vv.property.content = v
    }

    

}

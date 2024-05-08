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

    @IBOutlet var imageV:TRLabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageV.text = attribute
        imageV.scale = 4
        self.imageV.text = attribute
    }
    
    var text:String = "更多"
    var image:URL = Bundle.main.url(forResource: "more", withExtension: "pdf")!
    lazy var attribute:NSAttributedString = {
        let tx = try! TRPDFImageSet(url: image)
        var param:NSMutableParagraphStyle = NSMutableParagraphStyle()
        param.alignment = .center
        
        let rb = TRRuby(string: "he", alignment: .center, verhang: .auto, factor: 0.5)
        
        let image = TRTextImage(image: tx[1]!, font: UIFont.systemFont(ofSize: 36), contentMode: .scaleAspectFit(0.5))
        image.content.content.tintColor = UIColor.red.cgColor
        let aimag = image.createAttibuteString(attribute: [.paragraphStyle:param])
        let text = NSAttributedString(string: "\n" + text, attributes: [
            .paragraphStyle:param,
            .font:UIFont.systemFont(ofSize: 16, weight: .semibold),
            .rubyAnnotation:rb.ruby
        ])
        let a = NSMutableAttributedString()
        a.append(aimag)
        a.append(text)
        return a
    }()
}



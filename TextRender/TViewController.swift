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
    }
    lazy var attribute:NSAttributedString = {
        let param = NSMutableParagraphStyle()
        param.minimumLineHeight = 8
        let p:[NSAttributedString.Key:Any] = [
            .font:UIFont.systemFont(ofSize: 28),
            .foregroundColor:UIColor.black,
            .paragraphStyle : param,
        ]
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "avv", withExtension:"pdf")!)[1]
        let timg = TRTextImage(image: image!, font: UIFont.systemFont(ofSize: 28), contentMode: .scaleAspectFit(0.5))
        let offset:CGFloat = 0.5
        let v = TRTextTag(string: NSAttributedString(string: "abc吧擦擦爸爸的吧", attributes: [.font:UIFont.systemFont(ofSize: 12),.foregroundColor:UIColor.orange]), font: UIFont.systemFont(ofSize: 28), width: 129)
        var att = v.createAttibuteString(attribute: p) +
        TRSpacing(font: UIFont.systemFont(ofSize: 28), size: 70).createAttibuteString(attribute: p) +
        timg.createAttibuteString(attribute: p) +
        NSAttributedString(string: "this is my life please", attributes: p)
        return att
    }()
}



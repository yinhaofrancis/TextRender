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
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let offset:CGFloat = CGFloat.random(in: 0 ... 1)
        
        let image = try! TRVerterImageSet(url: Bundle.main.url(forResource: "iphone_portrait", withExtension:"pdf")!)[1]
        
        let v = TRView(content: TRVectorImage(contentMode: .scaleAspectFit(offset), image: image!), frame: CGRect(x:10, y: 10, width: 350, height: 480))
        let render = try! TROfflineRender(width: Int(self.view.frame.width), height: Int(self.view.frame.height), scale: 3)
        let cgimg = render.draw { tool in
            tool.context.fill([CGRect(x: 10, y: 10, width: 350, height: 480)])
            v.draw(ctx: tool.context)
        }
        self.imageV.image = UIImage(cgImage: cgimg!,scale: 3,orientation: .up)
    }
}

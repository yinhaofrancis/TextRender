//
//  ViewController.swift
//  TextRender
//
//  Created by FN-540 on 2024/3/12.
//

import UIKit
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        cell.imageV.text = attribute
        return cell
    }
    
    
    @IBOutlet var table:UITableView!
    
    lazy var attribute:NSAttributedString = {
        let param = NSMutableParagraphStyle()
        param.minimumLineHeight = 8
        let p:[NSAttributedString.Key:Any] = [
            .font:UIFont.systemFont(ofSize: 28),
            .foregroundColor:UIColor.black,
            .paragraphStyle : param,
            .decoration:testDecoration(borderColor: UIColor.red.cgColor,borderLineWidth: 2)
        ]
        let image = try! TRPDFImageSet(url: Bundle.main.url(forResource: "avd", withExtension:"pdf")!)[1]
        let offset:CGFloat = 0.5
        let v = TRRunView(content: TRView(content: TRVectorImage(contentMode: .scaleAspectFit(offset), image: image!)))
        let spacing:CGFloat = 10
        
        let aa = NSAttributedString(string: "start", attributes: p)
        var att = v.createAttibuteString(font: UIFont.systemFont(ofSize: 28), attribute: p) +
        TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + aa
        
        let a = NSAttributedString(string: "this is my life please 鸟🌾", attributes: p)
        var atta = v.createAttibuteString(font: UIFont.systemFont(ofSize: 28), attribute: p) +
        TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + a
        
        let b = NSAttributedString(string: "this is my 鸟🌾", attributes: p)
        var attb = v.createAttibuteString(font: UIFont.systemFont(ofSize: 28), attribute: p) +
        TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + b
        
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + atta
        att = att + TRSpacing(spacing: spacing).createAttibuteString(font: UIFont.systemFont(ofSize: 28),attribute: p) + attb
        return att
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return TRTextFrame(width: self.view.frame.width, string: self.attribute).size.height
//    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.table.reloadData()
    }
}

class Cell:UITableViewCell{
    @IBOutlet var imageV:TRLabel!
}

public struct testDecoration:TRDecoration{
    public var backgroundColor: CGColor?
    public var borderColor: CGColor?
    public var borderLineWidth: CGFloat?
}

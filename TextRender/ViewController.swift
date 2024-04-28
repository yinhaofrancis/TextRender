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
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
}

class Cell:UITableViewCell{
    @IBOutlet var imageV:TRLabel!
}

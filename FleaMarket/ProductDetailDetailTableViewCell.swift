//
//  ProductDetailDetailTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 06/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class ProductDetailDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label3height: NSLayoutConstraint!
    @IBOutlet weak var label4height: NSLayoutConstraint!
    @IBOutlet weak var label5height: NSLayoutConstraint!
    
    @IBOutlet weak var ans1: UILabel!
    @IBOutlet weak var ans2: UILabel!
    @IBOutlet weak var ans3: UILabel!
    @IBOutlet weak var ans4: UILabel!
    @IBOutlet weak var ans5: UILabel!
    
    @IBOutlet weak var ans3height: NSLayoutConstraint!
    @IBOutlet weak var ans4height: NSLayoutConstraint!
    @IBOutlet weak var ans5height: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        label1.text = "库存剩余"
        label2.text = "发布时间"
        label3.text = "新旧"
        label4.text = "侃价"
        label5.text = "置换"
    }
    let LABELHEIGHT:CGFloat = 21
    func setupCell(amt:Int,date:NSDate,brandNew:Bool?,bargain:Bool?,exchange:Bool?){
        ans1.text = "\(amt)"
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        ans2.text = formatter.stringFromDate(date)
        
        if brandNew != nil{
            label3height.constant = LABELHEIGHT
            ans3height.constant = LABELHEIGHT
            ans3.text = (brandNew!) ? "全新" : "二手"
        }else{
            label3height.constant = 0
            ans3height.constant = 0
        }
        
        if bargain != nil {
            label4height.constant = LABELHEIGHT
            ans4height.constant = LABELHEIGHT
            ans4.text = (bargain!) ? "同意侃价" :"拒绝侃价"
        }else{
            label4height.constant = 0
            ans4height.constant = 0
        }
        
        if exchange != nil {
            label5height.constant = LABELHEIGHT
            ans5height.constant = LABELHEIGHT
            ans5.text = (exchange!) ? "同意置换" : "拒绝置换"
        }else{
            label5height.constant = 0
            ans5height.constant = 0
        }
        
    }
    
}

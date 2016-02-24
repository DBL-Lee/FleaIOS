//
//  FirstScreenSearchTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 21/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class FirstScreenSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var callback:()->Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundImageView.image = UIImage(named: "section0back.jpg")
        
    }
    
    func setSearchCallBack(callback:()->Void){
        self.callback = callback
    }
    
    @IBAction func search(sender: AnyObject) {
        callback()
    }
    override func setSelected(selected: Bool, animated: Bool) {
    }
    override func setHighlighted(highlighted: Bool, animated: Bool) {
    }
    
}

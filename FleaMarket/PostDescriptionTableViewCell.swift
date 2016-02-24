//
//  PostDescriptionTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 01/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class PostDescriptionTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var wordLimitLabel: UILabel!
    var limit = 0
    var callback:String->Void = {_ in }
    
    
    override func awakeFromNib() {
        textView.delegate = self
        wordLimitLabel.textColor = UIColor.lightGrayColor()
    }
    
    func setupCell(placeholder:String,limit:Int,callback:String->Void){
        self.textView.placeholder = placeholder
        self.limit = limit
        self.wordLimitLabel.text = "\(textView.text.characters.count)/\(limit)"
        self.callback = callback
    }
    
    func textViewDidChange(textView: UITextView) {
        self.wordLimitLabel.text = "\(textView.text.characters.count)/\(limit)"
        if textView.text.characters.count>limit{
            wordLimitLabel.textColor = UIColor.redColor()
        }else{
            wordLimitLabel.textColor = UIColor.lightGrayColor()
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }

    func textViewDidEndEditing(textView: UITextView) {
        callback(textView.text!)
    }
    
}

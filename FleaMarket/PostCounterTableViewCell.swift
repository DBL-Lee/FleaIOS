//
//  PostCounterTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 26/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostCounterTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var decreBtn: UIButton!
    @IBOutlet weak var increBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    var callback:Int->Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.decreBtn.layer.borderColor = UIColor.blackColor().CGColor
        self.decreBtn.layer.borderWidth = 1
        self.increBtn.layer.borderColor = UIColor.blackColor().CGColor
        self.increBtn.layer.borderWidth = 1
        self.textField.text = "1"
        self.textField.delegate = self
        self.textField.keyboardType = UIKeyboardType.NumberPad
    }
    
    func setupCell(string:String,callback:Int->Void){
        self.label.text = string
        self.callback = callback
    }

    @IBAction func incre(sender: AnyObject) {
        self.textField.resignFirstResponder()
        let res = Int(self.textField.text!)!+1
        if res<1000{
            self.textField.text = "\(res)"
            callback(res)
        }
        
    }
    
    @IBAction func decre(sender: AnyObject) {
        self.textField.resignFirstResponder()
        let res = Int(self.textField.text!)!-1
        if res>0{
            self.textField.text = "\(res)"
            callback(res)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType==UIKeyboardType.NumberPad{
            let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let expression = "^[0-9]*"
            let regex = try! NSRegularExpression(pattern: expression, options: .CaseInsensitive)
            let numberOfMatches = regex.numberOfMatchesInString(text, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, text.characters.count))
            if numberOfMatches==0 {return false}
        }
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
    
}

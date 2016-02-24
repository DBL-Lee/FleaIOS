//
//  EnterTextTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class EnterTextTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    var limit = 0
    var callback:String->Void = {_ in }
    var locale:NSLocale? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textField.delegate = self
        self.textField.clearsOnBeginEditing = true
    }
    
    func setupCell(title:String,text:String?,placeholder:String,keyboard:UIKeyboardType,limit:Int,callback:String->Void,rightAlign:Bool = false,locale:NSLocale? = nil){
        self.titleLabel.text = title
        self.textField.placeholder = placeholder
        self.textField.keyboardType = keyboard
        self.locale = locale
        self.textField.text = text
        addCurrency()
        self.limit = limit
        if rightAlign{
            self.textField.textAlignment = .Right
        }
        self.callback = callback
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType==UIKeyboardType.DecimalPad{
            let text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if text != ""{
                let expression = "^\\d*+(\\.\\d{0,2})?$"
                let regex = try! NSRegularExpression(pattern: expression, options: .CaseInsensitive)
                let numberOfMatches = regex.numberOfMatchesInString(text, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, text.characters.count))
                if numberOfMatches==0 {return false}
            }
        }
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= limit
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.keyboardType == .DecimalPad{
            if textField.text!.containsString("."){
                let last = textField.text!.characters.endIndex
                let dot = textField.text!.characters.indexOf(".")!
                if dot == last.predecessor(){
                    textField.text! += "00"
                }else if dot == last.predecessor().predecessor(){
                    textField.text! += "0"
                }
            }else{
                textField.text = textField.text!+".00"
            }
            callback(textField.text!)
            addCurrency()
        }else{
            callback(textField.text!)
        }
    }
    
    func addCurrency(){
        if locale != nil && textField.text! != ""{
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            formatter.locale = locale
            textField.text = formatter.stringFromNumber(NSNumber(double: Double(textField.text!)!))
        }
    }

}

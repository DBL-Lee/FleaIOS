//
//  DistanceDragCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 15/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class DistanceDragCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.text = "10"
        textField.keyboardType = .NumberPad
        textField.delegate = self
    }
    var maxDistance = 1000
    var distance = 10
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if (range.length == 1 && string.isEmpty){//handle delete
            return true
        }
        let int = Int(newString)!
        if int>=maxDistance{
            textField.text = "\(maxDistance)"
            return false
        }else{
            distance = int
            return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.text == ""{
            textField.text = "0"
        }
        distance = Int(textField.text!)!
        if textField.text == "\(maxDistance)"{
            textField.text = "\(maxDistance)+"
        }
        return true
    }
    
}

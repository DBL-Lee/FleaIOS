//
//  DoubleDragPriceTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 25/02/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class DoubleDragPriceTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var upperText: UITextField!
    @IBOutlet weak var lowerText: UITextField!
    @IBOutlet weak var rangeSlider: RangeSlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        upperText.delegate = self
        lowerText.delegate = self
        lowerText.text = "0"
        upperText.text = "10000+"
        upperText.keyboardType = .NumberPad
        lowerText.keyboardType = .NumberPad
    }
    
    let maximum = 10000.0
    var upperInt:Int = 10000
    var lowerInt:Int = 0

    @IBAction func slided(sender: RangeSlider) {
        let low = sender.lowerValue
        let high = sender.upperValue
        let lowerActual = scaleFunction(low)/scaleFunction(sender.maximumValue)*maximum
        let upperActual = scaleFunction(high)/scaleFunction(sender.maximumValue)*maximum
        self.lowerText.text = "\(Int(lowerActual))"
        lowerInt = Int(lowerActual)
        self.upperText.text = "\(Int(upperActual))"
        upperInt = Int(upperActual)
        if upperActual == maximum{
            self.upperText.text = self.upperText.text!+"+"
        }
    }
    
    func scaleFunction(x:Double)->Double{
        return x*x*x
    }
    
    func reverseFunction(x:Int)->Double{
        let d = Double(x)
        return pow(d/maximum,1/3)*rangeSlider.maximumValue
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if newString.characters.count>6{
            return false
        }
        
        if (range.length == 1 && string.isEmpty){//handle delete
            if newString.characters.count == 0{
                textField.text = "0"
                if textField==lowerText{
                    lowerInt = 0
                    rangeSlider.lowerValue = reverseFunction(0)
                }else{
                    upperInt = 0
                    rangeSlider.upperValue = reverseFunction(0)
                }
                return false
            }
            return true
        }
        var int = Int(newString)!
        if textField == lowerText{
            if int>=upperInt{
                int = upperInt-1
                textField.text = "\(int)"
                lowerInt = int
                textField.text = "\(int)"
                return false
            }else{
                lowerInt = int
                textField.text = "\(int)"
                return false
            }
        }else{
            if int<=lowerInt{
                int = lowerInt+1
                textField.text = "\(int)"
                if int==Int(maximum){
                    textField.text = textField.text!+"+"
                }
                upperInt = int
                textField.text = "\(int)"
                return false
            }else{
                upperInt = int
                textField.text = "\(int)"
                return false
            }
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField==lowerText{
            if textField.text == ""{
                lowerInt = 0
                textField.text = "\(lowerInt)"
            }
        }else{
            if textField.text == ""{
                upperInt = Int(maximum)
                textField.text = "\(upperInt)+"
            }
        }
    }
}

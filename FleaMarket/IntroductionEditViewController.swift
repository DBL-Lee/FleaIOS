//
//  IntroductionEditViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 03/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD

class IntroductionEditViewController: UIViewController,UITextViewDelegate {

    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var wordLimitLabel: UILabel!
    var limit = 140
    var placeholder = ""
    var text:String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        wordLimitLabel.textColor = UIColor.lightGrayColor()
        
        self.textView.placeholder = placeholder
        self.textView.text = text
        self.wordLimitLabel.text = "\(textView.text.characters.count)/\(limit)"
        self.confirmBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
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

    @IBAction func finishBtnPressed(sender: AnyObject) {
        if textView.text.characters.count>limit{
            let alert = UIAlertController(title: "", message: "超过字数限制!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            UserLoginHandler.instance.editDetailOfCurrentUser(introduction: textView.text){
                success in
                MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
                if success{
                    self.navigationController?.popViewControllerAnimated(true)
                }else{
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
        }
    }
}

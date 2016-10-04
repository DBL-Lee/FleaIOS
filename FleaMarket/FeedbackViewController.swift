//
//  FeedbackViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 22/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire

class FeedbackViewController: UIViewController,UITextViewDelegate,TopTabBarViewDelegate {
    
    @IBOutlet weak var topPanel: TopTabBarView!

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    var order:Order!
    
    var rating = 0
    var limit = 140
    var placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        textView.delegate = self
        wordCountLabel.textColor = UIColor.lightGrayColor()
        
        topPanel.addButtons(["好评","中评","差评"], colors: [UIColor.redColor(),UIColor.orangeColor(),UIColor.darkGrayColor()])
        topPanel.delegate = self
        
        self.textView.placeholder = placeholder
        self.textView.text = ""
        
        self.wordCountLabel.text = "\(textView.text.characters.count)/\(limit)"
        self.confirmBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        self.confirmBtn.setTitle("提交评价", forState: .Normal)
        
        self.edgesForExtendedLayout = .None
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    func didChangeToButtonNumber(number: Int) {
        self.rating = number
    }

    func textViewDidChange(textView: UITextView) {
        self.wordCountLabel.text = "\(textView.text.characters.count)/\(limit)"
        if textView.text.characters.count>limit{
            wordCountLabel.textColor = UIColor.redColor()
        }else{
            wordCountLabel.textColor = UIColor.lightGrayColor()
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    @IBAction func confirm(sender: AnyObject) {
        if textView.text.characters.count>limit{
            let alert = UIAlertController(title: "", message: "超过字数限制!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "好", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
            
            var parameter:[String:AnyObject] = [:]
            parameter["order"] = order.id
            if order.isbuyer(){
                parameter["receiver"] = order.product.userid
            }else{
                parameter["receiver"] = order.buyerid
            }
            parameter["content"] = self.textView.text
            parameter["rating"] = rating
            
            Alamofire.request(.POST, postFeedbackURL, parameters: parameter, encoding: .JSON, headers: UserLoginHandler.instance.authorizationHeader()).responseJSON{
                response in
                hud.hideAnimated(false)
                switch response.result{
                case .Success:
                    if response.response?.statusCode < 400{
                        self.navigationController?.popViewControllerAnimated(true)
                        OverlaySingleton.addToView(self.navigationController!.view, text: "评价提交成功")
                    }else{
                        OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                    }
                case .Failure(let e):
                    print(e)
                    OverlaySingleton.addToView(self.navigationController!.view, text: NetworkProblemString)
                }
            }
            
        }
    }

}

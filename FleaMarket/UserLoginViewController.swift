//
//  UserLoginViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class UserLoginViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginTable: UITableView!
    var usernameTextField:UITextField!
    var passwordTextField:UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        loginTable.delegate = self
        loginTable.dataSource = self
        loginTable.tableFooterView = UIView()
        loginTable.tableHeaderView = UIView()
        loginTable.alwaysBounceVertical = false
        
        loginTable.registerNib(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "LoginTableViewCell")
        
        loginBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        loginBtn.setBackgroundImage(UIColor.lightGrayColor().toImage(), forState: .Disabled)
        
        loginBtn.enabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: "tapped:")
        self.view.addGestureRecognizer(tap)
    }
    
    func tapped(tap:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "登录"
        let image = UIImage(named: "backButton.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func dismiss(){
        if self.navigationController?.viewControllers[0] == self{
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        usernameTextField.becomeFirstResponder()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LoginTableViewCell", forIndexPath: indexPath) as! LoginTableViewCell
        if indexPath.row == 0{
            cell.setupCell("账户", placeholder: "邮箱地址", showBtn: false)
            usernameTextField = cell.textField
            cell.textField.delegate = self
        }else{
            cell.setupCell("密码", placeholder: "请输入密码", showBtn:
                true)
            passwordTextField = cell.textField
            cell.textField.delegate = self
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let length = newString.characters.count
        var otherlength = 0
        if textField == usernameTextField{
            otherlength = passwordTextField.text!.characters.count
        }else{
            otherlength += usernameTextField.text!.characters.count
        }
        if length==0 || otherlength==0{
            loginBtn.enabled = false
        }else{
            loginBtn.enabled = true
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if loginBtn.enabled {
            loginTapped(1)
        }
        return true
    }

    @IBAction func loginTapped(sender: AnyObject) {
        self.view.endEditing(true)
        UserLoginHandler.instance.login(usernameTextField.text!, password: passwordTextField.text!, completion: loginResponse)
        LoadingOverlay.shared.showOverlay(self.navigationController!.view)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        let signup = UserSignUpViewController()
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    @IBAction func forgetPassword(sender: AnyObject) {
    }
    
    func loginResponse(response:Bool){
        LoadingOverlay.shared.hideOverlayView()
        if response{
            self.dismiss()
        }else{
            let alert = UIAlertController(title: nil, message: "用户名或密码不正确", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "找回密码", style: .Default){
                action in
                self.forgetPassword(1)
                alert.removeFromParentViewController()
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

}

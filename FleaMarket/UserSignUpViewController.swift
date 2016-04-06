//
//  UsersignupViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 17/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
import MBProgressHUD

class UserSignUpViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var signupTable: UITableView!
    @IBOutlet weak var signupBtn: UIButton!
    
    var verifycodeID:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        signupTable.delegate = self
        signupTable.dataSource = self
        signupTable.tableFooterView = UIView()
        signupTable.tableHeaderView = UIView()
        signupTable.alwaysBounceVertical = false
        
        signupTable.registerNib(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "LoginTableViewCell")
        signupTable.registerNib(UINib(nibName: "VerifyCodeTableViewCell", bundle: nil), forCellReuseIdentifier: "VerifyCodeTableViewCell")
        signupBtn.setBackgroundImage(UIColor.orangeColor().toImage(), forState: .Normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserSignUpViewController.tapped(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func tapped(tap:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.translucent = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "注册"
        let image = UIImage(named: "backButton.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(UserSignUpViewController.dismiss), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func dismiss(){
        if self.navigationController?.viewControllers[0] == self{
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    var emailTextField:UITextField!
    var passwordTextField:UITextField!
    var confirmPasswordTextField:UITextField!
    var nicknameTextField:UITextField!
    var verifycodeTextField:UITextField!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0,1,2,3:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoginTableViewCell", forIndexPath: indexPath) as! LoginTableViewCell
            switch indexPath.row{
            case 0:
                cell.setupCell("邮箱", placeholder: "邮箱就是以后的账户名称", showBtn: false)
                emailTextField = cell.textField
            case 1:
                cell.setupCell("密码", placeholder: "请输入密码", showBtn: true)
                passwordTextField = cell.textField
            case 2:
                cell.setupCell("确认密码", placeholder: "请再次确认密码", showBtn: true)
                confirmPasswordTextField = cell.textField
            case 3:
                cell.setupCell("昵称", placeholder: "中文英文和数字组合", showBtn: false)
                nicknameTextField = cell.textField
            default: break
            }
            cell.selectionStyle = .None
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("VerifyCodeTableViewCell", forIndexPath: indexPath) as! VerifyCodeTableViewCell
            verifycodeTextField = cell.textField
            sendBtn = cell.auxiBtn
            cell.setupCell("验证码", placeholder: "输入邮箱中的验证码")
            cell.auxiBtn.addTarget(self, action: #selector(UserSignUpViewController.sendVerificationEmail), forControlEvents: .TouchUpInside)
            return cell
        default:break
        }
        return UITableViewCell()
    }
    var sendBtn:UIButton!
    var timer:NSTimer!
    var time = 60
    func sendVerificationEmail(){
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.labelText = "正在发送邮件"
        UserLoginHandler.instance.sendVerificationEmail(emailTextField.text!){
            id in
            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
            self.verifycodeID = Int(id)
        }
        sendBtn.setTitle("请等待\(time)秒", forState: .Normal)
        sendBtn.enabled = false
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(UserSignUpViewController.update), userInfo: nil, repeats: false)
    }

    func update(){
        time -= 1
        sendBtn.setTitle("请等待\(time)秒", forState: .Normal)
        if time==0{
            sendBtn.setTitle("获取验证码", forState: .Normal)
            sendBtn.enabled = true
            time = 60
        }else{
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(UserSignUpViewController.update), userInfo: nil, repeats: false)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        _ = newString.characters.count
        _ = 0
//        if textField == usernameTextField{
//            otherlength = passwordTextField.text!.characters.count
//        }else{
//            otherlength += usernameTextField.text!.characters.count
//        }
        //        if length==0 || otherlength==0{
        //            signupBtn.enabled = false
        //        }else{
        //            signupBtn.enabled = true
        //        }
        if textField==emailTextField{
            verifycodeID = nil
            verifycodeTextField.text = ""
        }
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func signup(sender: AnyObject) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: {
            _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        if emailTextField.text?.characters.count==0 {
            alert.message = "请输入邮件地址!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if !isValidEmail(emailTextField.text!) {
            alert.message = "请输入正确的邮箱地址!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if passwordTextField.text?.characters.count==0{
            alert.message = "请输入密码!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if confirmPasswordTextField.text?.characters.count==0{
            alert.message = "请再次输入密码!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if passwordTextField.text! != confirmPasswordTextField.text!{
            alert.message = "两次输入的密码不一致!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if nicknameTextField.text?.characters.count == 0{
            alert.message = "请输入你的昵称!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if verifycodeID == nil{
            alert.message = "请先获取一个验证码!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if verifycodeTextField.text?.characters.count == 0{
            alert.message = "请输入验证码!"
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        hud.labelText = "正在注册"
        
        UserLoginHandler.instance.registerNewAccount(emailTextField.text!, password: passwordTextField.text!, nickname: nicknameTextField.text!,verifycode: verifycodeTextField.text!,verifyID: verifycodeID!){
            result, errorStr in
            MBProgressHUD.hideHUDForView(self.navigationController!.view, animated: true)
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
            if result{
                self.dismiss()
            }else{
                alert.message = errorStr!
            }
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
}

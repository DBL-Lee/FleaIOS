//
//  SecondTableViewController.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 27/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit
//import AGEmojiKeyboard

class SecondTableViewController: UITableViewController,AGEmojiKeyboardViewDataSource,AGEmojiKeyboardViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidLayoutSubviews() {
        let emojiView = AGEmojiKeyboardView(frame: CGRect(x: 50, y: 100, width: 300, height: 300), dataSource: self)
        emojiView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        emojiView.delegate = self
        //abutton.associatedView = emojiView
        //self.view.addSubview(emojiView)
        //_inputToolbar.addButtonToRightBar(abutton)
        //        emojiView.emojiPagesScrollView.canCancelContentTouches = true
        //        emojiView.emojiPagesScrollView.delaysContentTouches = false
        self.navigationController!.view.addSubview(emojiView)
    }
    
    //MARK: EMOJI DELEGATE
    func emojiKeyBoardView(emojiKeyBoardView: AGEmojiKeyboardView!, didUseEmoji emoji: String!) {
        //self._inputToolbar.contentView.textView.text = self._inputToolbar.contentView.textView.text + emoji
    }
    
    func emojiKeyBoardViewDidPressBackSpace(emojiKeyBoardView: AGEmojiKeyboardView!) {
        // self._inputToolbar.contentView.textView.deleteBackward()
    }
    
    //MARK: EMOJI DATASOURCE
    func emojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!, imageForSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage! {
        return UIColor.greenColor().toImage()
    }
    
    func emojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!, imageForNonSelectedCategory category: AGEmojiKeyboardViewCategoryImage) -> UIImage! {
        return UIColor.redColor().toImage()
    }
    
    func backSpaceButtonImageForEmojiKeyboardView(emojiKeyboardView: AGEmojiKeyboardView!) -> UIImage! {
        return UIColor.blackColor().toImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  PostFollowTableViewCell.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 05/05/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

import UIKit

class PostFollowTableViewCell: UITableViewCell {

    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    var callback:Int->Void = {_ in}
    var tap:UIGestureRecognizer!
    var tap2:UIGestureRecognizer!
    var tap3:UIGestureRecognizer!
    override func awakeFromNib() {
        super.awakeFromNib()
        tap = UITapGestureRecognizer(target: self, action: #selector(post))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        tap2 = UITapGestureRecognizer(target: self, action: #selector(following))
        tap2.cancelsTouchesInView = false
        self.addGestureRecognizer(tap2)
        tap3 = UITapGestureRecognizer(target: self, action: #selector(follower))
        tap3.cancelsTouchesInView = false
        self.addGestureRecognizer(tap3)
        
        tap.delegate = self
        tap2.delegate = self
        tap3.delegate = self
    }
    
    func setupCell(post:Int,following:Int,follower:Int,callback:Int->Void){
        postLabel.text = "\(post)"
        followingLabel.text = "\(following)"
        followerLabel.text = "\(follower)"
        
        self.callback = callback
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let location = touch.locationInView(self)
        if location.y<self.frame.height{
            if location.x < self.frame.width/3{
                if gestureRecognizer == tap{
                    return true
                }
            }else if location.x < self.frame.width*2/3{
                if gestureRecognizer == tap2{
                    return true
                }
            }else{
                if gestureRecognizer == tap3{
                    return true
                }
            }
        }
        return false
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer{
            return true
        }
        return super.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer: otherGestureRecognizer)
    }
    
    func post(){
        callback(0)
    }
    func following(){
        callback(1)
    }
    func follower(){
        callback(2)
    }
    
}

//
//  Util.swift
//  FleaMarket
//
//  Created by Zichuan Huang on 31/01/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//
import UIKit

extension UIColor{
    func toImage()->UIImage{
        let rect = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPoint(x: 0, y: 0), size: rect))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView{
    func addBorder(edges edges: UIRectEdge, colour: UIColor = UIColor.whiteColor(), thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRectZero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.Top) || edges.contains(.All) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[top(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[top]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.Left) || edges.contains(.All) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[left(==thickness)]",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[left]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.Right) || edges.contains(.All) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:[right(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:|-(0)-[right]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.Bottom) || edges.contains(.All) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("V:[bottom(==thickness)]-(0)-|",
                    options: [],
                    metrics: ["thickness": thickness],
                    views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat("H:|-(0)-[bottom]-(0)-|",
                    options: [],
                    metrics: nil,
                    views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}

extension String{
    func toCurrencyInLocale(locale:NSLocale?)->String{
        if locale != nil && self != ""{
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            formatter.locale = locale
            return formatter.stringFromNumber(NSNumber(double: Double(self)!))!
        }
        return self
    }
}

extension UIImage{
    func thumbnailOfSize(size:CGSize)->UIImage{
        let scale = max(size.width/self.size.width, size.height/self.size.height)
        let width = self.size.width * scale
        let height = self.size.height * scale
        let imageRect = CGRectMake((size.width - width)/2.0,
            (size.height - height)/2.0,
            width,
            height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.drawInRect(imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

//class CustomSearchBar: UISearchBar {
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setShowsCancelButton(false, animated: false)
//    }
//}
//
//class CustomSearchController: UISearchController, UISearchBarDelegate {
//    
//    lazy var _searchBar: CustomSearchBar = {
//        [unowned self] in
//        let result = CustomSearchBar(frame: CGRectZero)
//        result.delegate = self
//        
//        return result
//        }()
//    
//    override var searchBar: UISearchBar {
//        get {
//            return _searchBar
//        }
//    }
//}
class CustomSearchBar: UISearchBar {
    
    init(){
        super.init(frame: CGRectZero)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func setShowsCancelButton(showsCancelButton: Bool, animated: Bool) {
        // Void
    }
    
}

class CustomSearchController: UISearchController, UISearchBarDelegate {
    
    lazy var customSearchBar: CustomSearchBar = {
        [unowned self] in
        let result = CustomSearchBar()
        result.delegate = self
        return result
        }()
    
    override var searchBar: UISearchBar {
        get {
            return customSearchBar
        }
    }
    
    init(searchViewController:UIViewController!) {
        super.init(searchResultsController: searchViewController)
        
        searchBar.delegate = self
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text != nil)
        {
            self.active=true
        }
        else
        {
            self.active=false
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
   
    private override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
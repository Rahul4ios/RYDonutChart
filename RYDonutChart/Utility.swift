//
//  Utility.swift
//  TestSwift
//
//  Created by Rahul Yadav on 01/10/18.
//  Copyright © 2018 Rahul Yadav. All rights reserved.
//

import Foundation
import UIKit

let kStoryboard_name_main   =   "Main"

class Utility{
    
    static func apply(overlay: UIView, on superView: UIView){
        
        if overlay.superview != superView{
            
            if overlay.superview != nil{
                // Overlay is already in some other view hierarchy. Lets remove it from there first.
                
                overlay.removeFromSuperview()
            }
            
            superView.addSubview(overlay)
        }
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
                
        let leading = NSLayoutConstraint.init(item: overlay, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        superView.addConstraint(leading)
        let bottom = NSLayoutConstraint.init(item: overlay, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        superView.addConstraint(bottom)
        let trailing = NSLayoutConstraint.init(item: overlay, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        superView.addConstraint(trailing)
        let top = NSLayoutConstraint.init(item: overlay, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1.0, constant: 0.0)
        superView.addConstraint(top)
    }
    
    /**
     I return the size with respect to the current screen size.
     @param storyboardSize -    original size in interface builder. Right now it uses iPhone 6E size.
     */
    static func dynamicSizePerScreen(for storyboardSize:CGFloat) -> CGFloat{
        
        return (UIScreen.main.bounds.size.width / CGFloat(320.0)) * storyboardSize;
    }
}

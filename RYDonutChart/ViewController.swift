//
//  ViewController.swift
//  RYDonutChart
//
//  Created by Rahul Yadav on 14/04/19.
//  Copyright © 2019 RYTheDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ourImageView: UIImageView!
    let imageBorderWidth:CGFloat = 2.0
    @IBOutlet weak var piechartOverlayView: Piechart!
    var firstTimeFlagViewDidLayout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if firstTimeFlagViewDidLayout {
            
            firstTimeFlagViewDidLayout = false

            
            ourImageView.layoutIfNeeded()
            ourImageView.layer.cornerRadius = ourImageView.bounds.width/2
            ourImageView.layer.borderWidth = imageBorderWidth
            ourImageView.layer.borderColor = UIColor.white.cgColor
            
            piechartOverlayView.addLayers()
        }
    }
}


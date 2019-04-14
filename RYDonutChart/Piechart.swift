//
//  Piechart.swift
//  TestSwift
//
//  Created by Rahul Yadav on 23/10/18.
//  Copyright © 2018 Rahul Yadav. All rights reserved.
//

import Foundation
import UIKit

fileprivate let kImageSizePiechart:CGFloat  =   18.0
fileprivate let kInnerTxtFontSize:CGFloat   =   9.0
fileprivate let kOuterTxtFontSize:CGFloat   =   9.0
fileprivate let kCurvedPathRadiusFraction:CGFloat = 0.65    // w.r.t superview's radius
fileprivate let kInnerTextualRadiusFraction:CGFloat = 0.74 * kCurvedPathRadiusFraction   // w.r.t superview's radius
fileprivate let kOuterTextualRadiusFraction:CGFloat = 1.24 * kCurvedPathRadiusFraction // w.r.t superview's radius

struct PiechartData {
    
    let fractionalValue:CGFloat
    let startAngle:CGFloat
    let endAngle:CGFloat
    let imageName:String?
    let abbr:String
    let isFaded:Bool
    let widthFractionWRTMax:CGFloat
    var radialTextualRefPointInside:CGPoint?    // we set it while drawing as by then view layout would have been set
    var radialTextualRefPointOutside:CGPoint?
}

@IBDesignable
class Piechart: UIView {
    
    let arrData:[PiechartData] = {
        
        let dataAngleFractionReduction:CGFloat = (2 * CGFloat.pi) * Piechart.curvedPathGapFraction  // we need gap between curved paths
        let dataAngleReductionHalf:CGFloat = (dataAngleFractionReduction/2)
        let widthFractionWRTMaxDelta:CGFloat = 0.6  
        
        let data1FractionalValue:CGFloat = 0.4
        let startAngle1:CGFloat = dataAngleReductionHalf
        let endAngle1:CGFloat = startAngle1 + ((2 * CGFloat.pi)*data1FractionalValue) - dataAngleReductionHalf
        let data1 = PiechartData(fractionalValue: data1FractionalValue, startAngle: startAngle1, endAngle: endAngle1, imageName: "btc", abbr: "BTC", isFaded: false, widthFractionWRTMax: 1, radialTextualRefPointInside: nil, radialTextualRefPointOutside: nil)
      
        let data2FractionalValue:CGFloat = 0.2
        let startAngle2:CGFloat = endAngle1 + dataAngleReductionHalf
        let endAngle2:CGFloat = startAngle2 + (((2 * CGFloat.pi)*data2FractionalValue) - dataAngleReductionHalf)
        let data2 = PiechartData(fractionalValue: data2FractionalValue, startAngle: startAngle2, endAngle: endAngle2, imageName: "eth", abbr: "ETH", isFaded: false, widthFractionWRTMax: widthFractionWRTMaxDelta, radialTextualRefPointInside: nil, radialTextualRefPointOutside: nil)//(data2FractionalValue/data1FractionalValue) * widthFractionWRTMaxDelta)

        let data3FractionalValue:CGFloat = 0.17
        let startAngle3:CGFloat = endAngle2 + dataAngleReductionHalf
        let endAngle3:CGFloat = startAngle3 + (((2 * CGFloat.pi)*data3FractionalValue) - dataAngleReductionHalf)
        let data3 = PiechartData(fractionalValue: data3FractionalValue, startAngle: startAngle3, endAngle: endAngle3, imageName: "xrp", abbr: "XRP", isFaded: false, widthFractionWRTMax: widthFractionWRTMaxDelta, radialTextualRefPointInside: nil, radialTextualRefPointOutside: nil)//(data3FractionalValue/data1FractionalValue) * widthFractionWRTMaxDelta)

        let data4FractionalValue:CGFloat = 0.14
        let startAngle4:CGFloat = endAngle3 + dataAngleReductionHalf
        let endAngle4:CGFloat = startAngle4 + (((2 * CGFloat.pi)*data4FractionalValue) - dataAngleReductionHalf)
        let data4 = PiechartData(fractionalValue: data4FractionalValue, startAngle: startAngle4, endAngle: endAngle4, imageName: "ltc", abbr: "LTC", isFaded: false, widthFractionWRTMax: widthFractionWRTMaxDelta, radialTextualRefPointInside: nil, radialTextualRefPointOutside: nil)//(data4FractionalValue/data1FractionalValue) * widthFractionWRTMaxDelta)

        let data5FractionalValue:CGFloat = 0.09
        let startAngle5:CGFloat = endAngle4 + dataAngleReductionHalf
        let endAngle5:CGFloat = startAngle5 + (((2 * CGFloat.pi)*data5FractionalValue) - dataAngleReductionHalf)
        let data5 = PiechartData(fractionalValue: data5FractionalValue, startAngle: startAngle5, endAngle: endAngle5, imageName: nil, abbr: "other\ncoins", isFaded: true, widthFractionWRTMax: widthFractionWRTMaxDelta, radialTextualRefPointInside: nil, radialTextualRefPointOutside: nil)//(data5FractionalValue/data1FractionalValue) * widthFractionWRTMaxDelta)

        return [data1, data2, data3, data4, data5]
//        return [data1]
    }()
    static let curvedPathGapFraction:CGFloat = 0.07   // w.r.t 2 * pi
    let curvedPathMaxWidthFraction:CGFloat = 0.15   // w.r.t curvedPathRadius
    let kColorFadedCurve:UIColor = UIColor(red: 43.0/255, green: 186.0/255, blue: 239.0/255, alpha: 1)
    var curveNumAnimation:Int!
    let innerTxtFont:UIFont = {
       
        return UIFont.systemFont(ofSize: Utility.dynamicSizePerScreen(for: kInnerTxtFontSize))
    }()
    let outerTxtFont:UIFont = {
        
        return UIFont.systemFont(ofSize: Utility.dynamicSizePerScreen(for: kOuterTxtFontSize))
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
        addLayers()
    }
    
    /**
     I add layers
    */
    func addLayers(){
        
        // Curved bars
        self.curveNumAnimation = 0
        applyCurvedLayers()
    }
    
    /**
     Apply layers for curved path
    */
    func applyCurvedLayers(){
        
        let viewRadius:CGFloat = (frame.width/2)
        let radius:CGFloat = viewRadius * kCurvedPathRadiusFraction
        let widthMax:CGFloat = radius * curvedPathMaxWidthFraction
        let center:CGPoint = CGPoint(x: viewRadius, y: viewRadius)
        
        // Arc has 0 degree at rightmost edge whereas our piechart has at topmost edge
        func returnAngle4Arc(input:CGFloat) -> CGFloat{
            
            let output:CGFloat!
            
            if (input - (CGFloat.pi/2)) < 0.0 {
                // Case: lies in arc's quadrant 1
                output = input + (CGFloat.pi * (3/2))
            }
            else{
                // Case: lies in arc's quadrant 2,3 or 4
                output = input - (CGFloat.pi/2)
            }
            return output
        }
        
        let data = arrData[curveNumAnimation]
        let startAngle4Arc:CGFloat = returnAngle4Arc(input: data.startAngle)
        let endAngle4Arc:CGFloat = returnAngle4Arc(input: data.endAngle)
        let width:CGFloat = widthMax * data.widthFractionWRTMax
        let arcPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle4Arc, endAngle: endAngle4Arc, clockwise: true)
        
        let arcLayer = CAShapeLayer()
        arcLayer.path = arcPath.cgPath
        arcLayer.lineWidth = width
        arcLayer.lineCap = CAShapeLayerLineCap.round//"round"
        arcLayer.strokeColor = data.isFaded ? kColorFadedCurve.cgColor : UIColor.white.cgColor
        arcLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(arcLayer)
    
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = 0.0
        animation.toValue = 1.0
        CATransaction.setCompletionBlock {
            
            [unowned self] in
            
            if self.curveNumAnimation < (self.arrData.count - 1){
                // Case: Curve animation in progress, lets draw next curve
                
                self.curveNumAnimation = self.curveNumAnimation + 1
                
                self.applyCurvedLayers()
            }
            else{
                // Case: curve animation is completed, lets draw texts
                
                self.addTextualLayers()
            }
        }
        arcLayer.add(animation, forKey: nil)
        CATransaction.commit()
        
//        // Lets set textual positions
//        let textualPositions = returnTextualPositionsFrom(data: data)
//        data.radialTextualRefPointInside = textualPositions.0
//        data.radialTextualRefPointOutside = textualPositions.1
        
    }
    
//    // I calculate inside and outside textual positions from data's start and end angle
//    func returnTextualPositionsFrom(data:PiechartData) -> (CGPoint, CGPoint){
//
//        let viewRadius:CGFloat = (frame.width/2)
//        let curveMiddleAngle:CGFloat = (data.startAngle + data.endAngle)/2
//        let innerTextualRadius:CGFloat = viewRadius * kInnerTextualRadiusFraction
//        let outerTextualRadius:CGFloat = viewRadius * kOuterTextualRadiusFraction
//        let innerTextualPositionX:CGFloat = viewRadius + (innerTextualRadius * sin(curveMiddleAngle))
//        let innerTextualPositionY:CGFloat = viewRadius - (innerTextualRadius * cos(curveMiddleAngle))
//        let outerTextualPositionX:CGFloat = viewRadius + (outerTextualRadius * sin(curveMiddleAngle))
//        let outerTextualPositionY:CGFloat = viewRadius - (outerTextualRadius * cos(curveMiddleAngle))
//
//        let innerTextualPosition:CGPoint = CGPoint(x: innerTextualPositionX, y: innerTextualPositionY)
//        let outerTextualPosition:CGPoint = CGPoint(x: outerTextualPositionX, y: outerTextualPositionY)
//
//        return (innerTextualPosition, outerTextualPosition)
//    }
    
    /**
     Add textual layers
     */
    func addTextualLayers(){
        
        let viewRadius:CGFloat = (frame.width/2)
        let innerTextualRadius:CGFloat = viewRadius * kInnerTextualRadiusFraction
        let outerTextualRadius:CGFloat = viewRadius * kOuterTextualRadiusFraction
        
        for data in arrData {
            
            let curveMiddleAngle:CGFloat = (data.startAngle + data.endAngle)/2
            let innerTextualPositionX:CGFloat = viewRadius + (innerTextualRadius * sin(curveMiddleAngle))
            let innerTextualPositionY:CGFloat = viewRadius - (innerTextualRadius * cos(curveMiddleAngle))
            let outerTextualPositionX:CGFloat = viewRadius + (outerTextualRadius * sin(curveMiddleAngle))
            let outerTextualPositionY:CGFloat = viewRadius - (outerTextualRadius * cos(curveMiddleAngle))

//            print("viewRadius=\(viewRadius), curveMiddleAngle=\(curveMiddleAngle), innerTextualPositionX=\(innerTextualPositionX), innerTextualPositionY=\(innerTextualPositionY)")
            
            // Image
            if data.imageName != nil{
                // Case: except last curve
                
                let imageWidth:CGFloat = Utility.dynamicSizePerScreen(for: kImageSizePiechart)
                let imageLayerCenterX:CGFloat = innerTextualPositionX
                let imageLayerCenterY:CGFloat = innerTextualPositionY - (imageWidth/2)
                
                let imageLayer = CALayer()
                let image = UIImage(named: data.imageName!, in: Bundle(for: Piechart.self), compatibleWith: nil)!.cgImage!
                imageLayer.contents = image
                imageLayer.contentsGravity = CALayerContentsGravity.resizeAspect
                
                let imageLayerParent = CALayer()
                imageLayerParent.bounds.origin = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
                imageLayerParent.bounds.size = CGSize(width: imageWidth, height: imageWidth)
                imageLayerParent.position = CGPoint(x: imageLayerCenterX, y: imageLayerCenterY)
                imageLayerParent.backgroundColor = UIColor.white.cgColor
                imageLayerParent.mask = imageLayer
                
                imageLayer.frame = imageLayerParent.bounds  // Important. Bounds will not work.
                
                layer.addSublayer(imageLayerParent)
            }
            
            // Inner text
            let innerTxtSize:CGSize = data.abbr.size(withAttributes: [NSAttributedString.Key.font : innerTxtFont])
            let innerTxtOriginY:CGFloat = (data.imageName == nil) ? innerTextualPositionY - (innerTxtSize.height/2) : innerTextualPositionY
            let innerTxtRect:CGRect = CGRect(x: innerTextualPositionX - (innerTxtSize.width/2), y: innerTxtOriginY, width: innerTxtSize.width, height: innerTxtSize.height)
            let innerTxtLayer = CATextLayer()
            innerTxtLayer.frame = innerTxtRect
            innerTxtLayer.string = data.abbr
            innerTxtLayer.font = innerTxtFont
            innerTxtLayer.fontSize = innerTxtFont.pointSize
            innerTxtLayer.foregroundColor = UIColor.white.cgColor
            innerTxtLayer.alignmentMode = CATextLayerAlignmentMode.center
            innerTxtLayer.contentsScale = UIScreen.main.scale
            
            layer.addSublayer(innerTxtLayer)
            
            // Outer text
            let outerTxt = "\(Int(data.fractionalValue * 100))%"
            let outerTxtSize:CGSize = outerTxt.size(withAttributes: [NSAttributedString.Key.font : outerTxtFont])
            let outerTxtRect:CGRect = CGRect(x: outerTextualPositionX - (outerTxtSize.width/2), y: outerTextualPositionY - (outerTxtSize.height/2), width: outerTxtSize.width, height: outerTxtSize.height)
            let outerTxtLayer = CATextLayer()
            outerTxtLayer.frame = outerTxtRect
            outerTxtLayer.string = "\(Int(data.fractionalValue * 100))%"
            outerTxtLayer.font = outerTxtFont
            outerTxtLayer.fontSize = outerTxtFont.pointSize
            outerTxtLayer.foregroundColor = UIColor.white.cgColor
            outerTxtLayer.alignmentMode = CATextLayerAlignmentMode.center
            outerTxtLayer.contentsScale = UIScreen.main.scale
            
            layer.addSublayer(outerTxtLayer)
        }
    }
    
    @IBAction func tappedOnMe(_ sender: UITapGestureRecognizer) {
        
        for subLayer in layer.sublayers!{
            
            subLayer.removeFromSuperlayer()
        }
        
        addLayers()
    }
    
}

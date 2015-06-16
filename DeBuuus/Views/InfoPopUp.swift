//
//  InfoPopUp.swift
//  DeBuuus
//
//  Created by Sam Buydens on 31/05/15.
//  Copyright (c) 2015 Devine. All rights reserved.
//

import UIKit

class InfoPopUp: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var infoView: UIView?
    var infoText: String?
    
    init(infoText:String){ println("[InfoPopUp]")
        super.init(frame: UIScreen.mainScreen().bounds)
        self.infoText = infoText
        createBlurOverlay()
        createInfoView()

        //Kleine delay omdat het anders teveel opvalt dat de tekst tijd vraagt om te laden.
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("placeText"), userInfo: nil, repeats: false)
    }
    
    func createBlurOverlay(){
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurField = UIVisualEffectView(effect: blur)
        blurField.frame = UIScreen.mainScreen().bounds
        self.addSubview(blurField)
    }
    
    func createInfoView(){
        self.infoView = UIView(frame: CGRectMake(0, 0, 256, 300))
        self.infoView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.infoView!.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: { finished in
                //println("vlak geplaatst")
        })
        
        infoView!.frame.origin.x = FindCenter().centerWidth(infoView!.frame.width)
        infoView!.frame.origin.y = FindCenter().centerHeight(infoView!.frame.height)
        infoView!.layer.cornerRadius = 20
        infoView!.backgroundColor = BusColors().blauw
        self.addSubview(infoView!)
    }
    
    func placeText(){ //println("[placeText]")
        var textField = UITextView(frame: CGRectMake(0, 0, 220, 260))
        textField.frame.origin.x = 18
        textField.frame.origin.y = 28
        textField.backgroundColor = UIColor.clearColor()
        
        textField.text = self.infoText
        
        textField.font = UIFont(name: "story", size: 28)
        textField.textColor = BusColors().wit
        textField.textAlignment = NSTextAlignment.Center
        
        textField.transform = CGAffineTransformMakeScale(0.1, 0.1)
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            textField.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: { finished in
                //println("tekst geplaatst")
        })
        
        self.infoView?.addSubview(textField)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PulsingHaloLayer.swift
//  Friend
//
//  Created by Luigi Donadel on 20/01/16.
//  Copyright © 2016 Luigi Donadel. All rights reserved.
//

import Foundation

class PulsingHaloLayer : CAReplicatorLayer {
    
    var radius : CGFloat! {
        didSet {
            let diameter = self.radius * 2
            self.effect.bounds = CGRectMake(0, 0, diameter, diameter)
            self.effect.cornerRadius = radius
        }
    }
    var fromValueForRadius : CGFloat!
    var fromValueForAlpha : CGFloat!
    var keyTimeForHalfOpacity : CGFloat!
    var animationDuration : NSTimeInterval = 1 {
        didSet {
            self.animationGroup.duration = animationDuration + self.pulseInterval;
            for animation : CAAnimation in self.animationGroup.animations! {
                animation.duration = animationDuration
            }
            self.effect.removeAllAnimations()
            self.effect.addAnimation(self.animationGroup, forKey: "pulse")
            self.instanceDelay = (self.animationDuration + self.pulseInterval) / Double(self.haloLayerNumber);
        }
    }
    var pulseInterval : NSTimeInterval = 0 {
        didSet {
            if pulseInterval.isInfinite {
                self.effect.removeAnimationForKey("pulse")
            }
        }
    }
    var useTimingFunction : Bool = true
    var haloLayerNumber : NSInteger! {
        didSet {
            self.instanceCount = haloLayerNumber
            self.instanceDelay = (self.animationDuration + self.pulseInterval) / Double(haloLayerNumber)
        }
    }
    var startInterval : NSTimeInterval!  {
        didSet {
            self.instanceDelay = self.startInterval
        }
    }
    private var effect : CALayer!
    private var animationGroup : CAAnimationGroup!
    
    convenience init(layerNumber : NSInteger) {
        self.init(repeatCount: Float.infinity)
        self.haloLayerNumber = layerNumber
    }
    
    var color : CGColor? {
        didSet {
            self.backgroundColor = color
            self.effect.backgroundColor = color
        }
    }
    
    init(repeatCount : Float) {
        super.init()
        self.repeatCount = repeatCount
        self.effect = CALayer()
        self.effect.contentsScale = UIScreen.mainScreen().scale
        self.addSublayer(self.effect)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.setupParameters()
            self.setupAnimationGroup()
            if self.pulseInterval.isFinite {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.effect.addAnimation(self.animationGroup, forKey: "pulse")
                })
            }
        }
    }
    func setupParameters() {
        self.color = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: 1).CGColor
        self.radius = 60
        self.fromValueForRadius = 0.0
        self.fromValueForAlpha = 0.45
        self.keyTimeForHalfOpacity = 0.2
        self.useTimingFunction = true
        self.haloLayerNumber = 1
        self.startInterval = 1
    }
    func setupAnimationGroup() {
        animationGroup = CAAnimationGroup()
        animationGroup.duration = self.animationDuration + self.pulseInterval;
        animationGroup.repeatCount = self.repeatCount;
        animationGroup.removedOnCompletion = false;
        if (self.useTimingFunction) {
            let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            animationGroup.timingFunction = defaultCurve;
        }
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = self.fromValueForRadius;
        scaleAnimation.toValue = 1.0;
        scaleAnimation.duration = self.animationDuration;
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = self.animationDuration;
        opacityAnimation.values = [self.fromValueForAlpha, 0.45, 0];
        opacityAnimation.keyTimes = [0, self.keyTimeForHalfOpacity, 1];
        opacityAnimation.removedOnCompletion = false;
        
        let animations = [scaleAnimation, opacityAnimation];
        
        animationGroup.animations = animations;
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
}
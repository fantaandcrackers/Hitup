//
//  CircularImage.swift
//  Hittup
//
//  Created by Arthur Shir on 11/2/15.
//  Copyright © 2015 Hittup. All rights reserved.
//

import UIKit

class CircularImage: UIImageView {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context);
        self.addRoundedRectToPath(context!, rect: self.frame, ovalWidth: self.frame.height/2, ovalHeight: self.frame.height/2)
        CGContextClip(context)
        self.drawRect(self.frame)
        CGContextRestoreGState(context);
    }
    
    // Repurposed from http://stackoverflow.com/questions/996292/how-to-mask-a-square-image-into-an-image-with-round-corners-in-the-iphone-sdk
    func addRoundedRectToPath(context: CGContextRef, rect: CGRect, ovalWidth: CGFloat, ovalHeight: CGFloat)
    {
        var fw = CGFloat()
        var fh = CGFloat()
        if (ovalWidth == 0 || ovalHeight == 0) {
            CGContextAddRect(context, rect);
            return;
        }
        CGContextSaveGState(context);
        CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM (context, ovalWidth, ovalHeight);
        fw = CGRectGetWidth (rect) / ovalWidth;
        fh = CGRectGetHeight (rect) / ovalHeight;
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
        CGContextClosePath(context);
        CGContextRestoreGState(context);
    }

}

//
//  LRChatBootStringAnimation+UILabel.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/25.
//

import UIKit

class CharLabel : UILabel{
    var old_center : CGPoint?
}

extension UILabel{
    func animation_startAnimation(_ ffanimation : LRChatBootStringAnimation){
        ffanimation.startAnimation(for : self)
    }
    
    func animation_textBounds() -> CGRect?{
        guard let text = self.text as NSString? else {return nil}
        return text.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:self.font ?? UIFont.systemFont(ofSize: 15)], context: nil)
    }
    
    func animation_textFrame() -> CGRect?{
        guard let textBounds = self.animation_textBounds() else {return nil}
        var stringX:CGFloat = 0;
        let stringH:CGFloat = textBounds.size.height;
        let stringY:CGFloat = (self.frame.size.height - stringH)*0.5;
        let stringW:CGFloat = textBounds.size.width;
        
        switch (self.textAlignment) {
        case .natural,.left,.justified:
            stringX = 0;
            break;
        case .center:
            stringX = (self.frame.size.width - stringW)*0.5;
            break;
        case .right:
            stringX = self.frame.size.width - stringW;
            break;
        @unknown default:
            break
        }
        return CGRect(x: stringX + self.frame.origin.x, y: stringY + self.frame.origin.y, width: stringW, height: stringH)
    }
    
    func animation_streamTextFrame() -> CGRect?{
        guard let textBounds = self.animation_textBounds() else {return nil}
        var stringX:CGFloat = 0;
        let stringH:CGFloat = textBounds.size.height;
        let stringY:CGFloat = (self.frame.size.height - stringH)*0.5;
        let stringW:CGFloat = textBounds.size.width;
        
        switch (self.textAlignment) {
        case .natural,.left,.justified:
            stringX = 0;
            break;
        case .center:
            stringX = (self.frame.size.width - stringW)*0.5;
            break;
        case .right:
            stringX = self.frame.size.width - stringW;
            break;
        @unknown default:
            break
        }
        return CGRect(x: stringX, y: stringY, width: stringW, height: stringH)
    }
    
    func animation_lines() -> [String]{
        guard let text = self.text else {return []}
        //guard let textBounds = self.animation_textBounds() else {return []}
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(NSAttributedString.Key.font, value: self.font ?? UIFont.systemFont(ofSize: 15), range: NSMakeRange(0, attStr.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        let lines = CTFrameGetLines(frame) as NSArray
        var linesArray : [String] = []
        for line in lines{
            let lineRange = CTLineGetStringRange(line as! CTLine)
            let range = NSMakeRange(lineRange.location, lineRange.length)
            linesArray.append((text as NSString).substring(with: range))
        }
        return linesArray
    }
    
    func animation_charLabels() -> [CharLabel]{
        guard let textFrame = self.animation_textFrame() else {return []}
        var xOffset = textFrame.origin.x
        var yOffset = textFrame.origin.y
        var labels :[CharLabel] = []
        for str in self.animation_lines(){
            let nsstr = str as NSString
            switch (self.textAlignment) {
            case .natural,.left,.justified:
                xOffset = textFrame.origin.x
                break;
            case .center:
                xOffset = textFrame.origin.x + (textFrame.size.width - nsstr.string_sizeWithFont(self.font).width)*0.5
                break;
            case .right:
                xOffset = textFrame.origin.x + textFrame.size.width - nsstr.string_sizeWithFont(self.font).width
                break;
            @unknown default:
                break
            }
            for  i in 0..<nsstr.length{
                let char = nsstr.substring(with: NSMakeRange(i, 1)) as NSString
                let charSize = char.string_sizeWithFont(self.font)
                let charLabel = CharLabel(frame: CGRect(x: xOffset, y: yOffset, width: charSize.width, height: charSize.height))
                charLabel.font = self.font
                charLabel.textColor = self.textColor
                if(self.backgroundColor != nil){
                    charLabel.backgroundColor = self.backgroundColor
                }
                charLabel.text = char as String
                xOffset += charSize.width
                labels.append(charLabel)
            }
            yOffset += self.font.lineHeight
        }
        return labels
    }
}

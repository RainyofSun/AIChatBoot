//
//  LRTextView.swift
//  expandTableView
//
//  Created by 苍蓝猛兽 on 2023/6/2.
//

import UIKit

class LRTextView: UITextView {

    /**
     *  The text to be displayed when the text view is empty. The default value is `nil`.
     */
    open var placeHolder: String? {
        set {
            guard let _p = newValue else {
                return
            }
            self._p_h = _p as NSString
            self.setNeedsDisplay()
        }
        get {
            return _p_h as String?
        }
    }
    
    /**
     *  The color of the place holder text. The default value is `lightGrayColor`.
     */
    open var placeHolderTextColor: UIColor? {
        set {
            guard let _t_color = newValue, _t_color != _p_t_color else {
                return
            }
            _p_t_color = _t_color
            self.setNeedsDisplay()
        }
        get {
            return _p_t_color
        }
    }
    
    /**
     *  The insets to be used when the placeholder is drawn. The default value is `UIEdgeInsets(5.0, 7.0, 5.0, 7.0)`.
     */
    open var placeHolderInsets: UIEdgeInsets? {
        set {
            guard var _inset = newValue, _inset != .zero && _inset != _p_h_inset else {
                return
            }
            _inset.left += 3
            _p_h_inset = _inset
            self.setNeedsDisplay()
        }
        get {
            return _p_h_inset
        }
    }
    
    /**
     When TextView height changed will call this block. You can set height changed animation
     in this block call - (void)layoutIfNeeded.
     */
    open var heightChangeBlock: (() -> Void)?
    
    override var bounds: CGRect {
        didSet {
            if self.contentSize.height <= self.bounds.height + 1 {
                // Fix wrong contentOfset
                self.contentOffset = .zero
            }
            else if !self.isTracking {
                var offset = self.contentOffset
                if offset.y > self.contentSize.height - bounds.height {
                    offset.y = self.contentSize.height - bounds.height
                    if !self.isDecelerating && !self.isTracking && !self.isDragging {
                        self.contentOffset = offset
                    }
                    // Fix wrong contentOfset when past huge text
                }
            }
        }
    }
    
    override var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var font: UIFont? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.menuItems = nil
        return super.canPerformAction(action, withSender: sender)
    }
    
    private weak var heightConstraint: NSLayoutConstraint?
    private weak var minHeightConstraint: NSLayoutConstraint?
    private weak var maxHeightConstraint: NSLayoutConstraint?
    private var _p_h: NSString? = nil
    private var _p_t_color: UIColor = .lightGray
    private var _p_h_inset: UIEdgeInsets = UIEdgeInsets(top: 5.0, left: 7.0, bottom: 5.0, right: 7.0)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configureTextView()
        addTextViewNotificationObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if self.text.isEmpty && self._p_h != nil {
            _p_t_color.set()
            var _inset = self._p_h_inset
            _inset.top += self._p_h_inset.top * 2
            self._p_h?.draw(with: rect.inset(by: _inset), attributes: self.placeholderTextAttributes(), context: nil)
        }
    }
    
    deinit {
        removeTextViewNotificationObservers()
        print("DEALLOC ----------\(self)")
    }
    
    // MARK: Public Methods
    public func associateConstraints() {
        self.constraints.forEach { (constraint: NSLayoutConstraint) in
            if constraint.relation == .equal {
                self.heightConstraint = constraint
            }
            else if constraint.relation == .lessThanOrEqual {
                self.maxHeightConstraint = constraint
            }
            else if constraint.relation == .greaterThanOrEqual {
                self.minHeightConstraint = constraint
            }
        }
    }
}

// MARK: Private Methods
private extension LRTextView {
    func configureTextView() {
        self.scrollsToTop = false
        self.isUserInteractionEnabled = true
        
        self.contentMode = .redraw
        self.dataDetectorTypes = UIDataDetectorTypes.all
        self.keyboardAppearance = UIKeyboardAppearance.default
        self.keyboardType = UIKeyboardType.default
        self.returnKeyType = UIReturnKeyType.default
        self.alwaysBounceVertical = true
        
        self.text = nil
    }
    
    func addTextViewNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextViewNotification(notification: )), name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextViewNotification(notification: )), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTextViewNotification(notification: )), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    func removeTextViewNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    func autoAdjustContentHeight() {
        // calculate size needed for the text to be visible without scrolling
        let sizeThatFits: CGSize = self.sizeThatFits(self.frame.size)
        var newHeight: CGFloat = sizeThatFits.height
        
        // if there is any minimal height constraint set, make sure we consider that
        if let _max_height_constraint = self.maxHeightConstraint {
            newHeight = min(newHeight, _max_height_constraint.constant)
        }
        
        // if there is any maximal height constraint set, make sure we consider that
        if let _min_height_constraint = self.minHeightConstraint {
            newHeight = max(newHeight, _min_height_constraint.constant)
        }
        
        // update the height constraint
        if Int(newHeight * 1000) != Int((self.heightConstraint?.constant ?? .zero) * 1000) {
            self.heightConstraint?.constant = newHeight
            UIView.animate(withDuration: 0.2, delay: .zero, usingSpringWithDamping: 1, initialSpringVelocity: .zero, options: UIView.AnimationOptions.curveLinear) {
                self.heightChangeBlock?()
            }
        }
    }
    
    func placeholderTextAttributes() -> [NSAttributedString.Key: Any] {
        let parastyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        parastyle.lineBreakMode = .byTruncatingTail
        parastyle.alignment = self.textAlignment
        return [.font: self.font ?? UIFont.systemFont(ofSize: 13), .foregroundColor: self._p_t_color, .paragraphStyle: parastyle]
    }
}

// MARK: Notification
@objc private extension LRTextView {
    func didReceiveTextViewNotification(notification: Notification) {
        self.setNeedsDisplay()
        self.autoAdjustContentHeight()
    }
}

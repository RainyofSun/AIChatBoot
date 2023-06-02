//
//  LRChatBootChatRecordCell.swift
//  AIChatBoot
//
//  Created by 苍蓝猛兽 on 2023/5/30.
//

import UIKit

class LRChatBootChatRecordCell: UITableViewCell {

    private lazy var bgView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexString: "#1A1A1A")
        view.cornerRadius = 20
        return view
    }()
    
    private lazy var contentLab: UILabel = {
        let lab = UILabel(frame: CGRectZero)
        lab.numberOfLines = .zero
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit {
        deallocPrint()
    }
    
    // MARK: Public Methods
    public func reloadChatRecordCellSource(title: String, time: String) {
        let paraStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 8
        let attribute = NSMutableAttributedString(string: (title + "\n" + time), attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor(hexString: "#CCCCCC"), .paragraphStyle: paraStyle])
        attribute.addAttributes([.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor(hexString: "#777777"), .paragraphStyle: paraStyle], range: NSRange(location: title.count, length: (time.count + 1)))
        self.contentLab.attributedText = attribute
    }
}

// MARK: Private Methods
private extension LRChatBootChatRecordCell {
    func loadCellViews() {
        
        self.selectedBackgroundView = UIView()
        self.tintColor = APPThemeColor
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.contentLab)
        
        self.bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        self.contentLab.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
}

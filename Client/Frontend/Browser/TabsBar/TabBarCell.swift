/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import BraveShared

class TabBarCell: UICollectionViewCell, Themeable {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeTab), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "close_tab_bar").template, for: .normal)
        button.tintColor = PrivateBrowsingManager.shared.isPrivateBrowsing ? UIColor.white : UIColor.black
        // Close button is a bit wider to increase tap area, this aligns the 'X' image closer to the right.
        button.imageEdgeInsets.left = 6
        return button
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var separatorLineRight: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var currentIndex: Int = -1 {
        didSet {
            isSelected = currentIndex == tabManager?.currentDisplayedIndex
        }
    }
    weak var tab: Tab?
    weak var tabManager: TabManager?
    
    var closeTabCallback: ((Tab) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        [closeButton, titleLabel, separatorLine, separatorLineRight].forEach { contentView.addSubview($0) }
        initConstraints()
        
        isSelected = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selectedBackgroundColor: UIColor?
    private var normalBackgroundColor: UIColor?
    
    func applyTheme(_ theme: Theme) {
        separatorLine.backgroundColor = theme.colors.border.withAlphaComponent(theme.colors.transparencies.borderAlpha)
        separatorLineRight.backgroundColor = theme.colors.border.withAlphaComponent(theme.colors.transparencies.borderAlpha)
        closeButton.tintColor = theme.colors.tints.header
        titleLabel.textColor = theme.colors.tints.header
        
        selectedBackgroundColor = theme.colors.header
        normalBackgroundColor = theme.colors.home
        
        if isSelected {
            backgroundColor = selectedBackgroundColor
        } else if currentIndex != tabManager?.currentDisplayedIndex {
            backgroundColor = normalBackgroundColor
        }
    }
    
    private func initConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self).inset(16)
            make.right.equalTo(closeButton.snp.left)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.right.equalTo(self).inset(2)
            make.width.equalTo(30)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.width.equalTo(0.5)
            make.height.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        separatorLineRight.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.width.equalTo(0.5)
            make.height.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
                closeButton.isHidden = false
                titleLabel.alpha = 1.0
                backgroundColor = selectedBackgroundColor
            }
                // Prevent swipe and release outside- deselects cell.
            else if currentIndex != tabManager?.currentDisplayedIndex {
                titleLabel.font = UIFont.systemFont(ofSize: 12)
                titleLabel.alpha = 0.6
                closeButton.isHidden = true
                backgroundColor = normalBackgroundColor
            }
        }
    }
    
    @objc func closeTab() {
        guard let tab = tab else { return }
        closeTabCallback?(tab)
    }
    
    fileprivate var titleUpdateScheduled = false
    func updateTitleThrottled(for tab: Tab) {
        if titleUpdateScheduled {
            return
        }
        titleUpdateScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.titleUpdateScheduled = false
            strongSelf.titleLabel.text = tab.displayTitle
        }
    }
}

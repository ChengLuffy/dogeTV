//
//  CategoryViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/1.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import PromiseKit
import SegementSlide


class CategoryViewController: SegementSlideViewController {

    enum CategoryViewSourceType {
        case rank
        case normal
        var title: String {
            switch self {
            case .rank: return "热度榜"
            case .normal: return "影视库"
            }
        }
    }

    var sourceType: CategoryViewSourceType = .normal
    var isDouban = false
    var selected: Category = .film {
        didSet {
            if isLoaded {
                let index = selected.rawValue
                self.scrollToSlide(at: index, animated: false)
            }
        }
    }
    var isLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = sourceType.title
        view.theme_backgroundColor = AppColor.backgroundColor
        slideContentView.theme_backgroundColor =  AppColor.backgroundColor
        if sourceType == .normal {
            let rankBtn = UIBarButtonItem(image: UIImage(named: "ranking"), style: .plain, target: self, action: #selector(rank))
            let doubanBtn = UIBarButtonItem(image: UIImage(named: "douban"), style: .plain, target: self, action: #selector(toggleSourceType(_:)))
            navigationItem.rightBarButtonItems = [rankBtn, doubanBtn]
        }
        slideSwitcherView.theme_backgroundColor = AppColor.slideSwitcherColor
        refresh()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidUpdated),
            name: NSNotification.Name(rawValue: "ThemeUpdateNotification"),
            object: nil
        )
        isLoaded = true
    }

    @objc func themeDidUpdated() {
        reloadSwitcher()
    }

    
    @objc func toggleSourceType(_ sender: UIBarButtonItem) {
        isDouban.toggle()
        sender.tintColor =  isDouban ? UIColor(hexString: "#2ECC71") : nil
        refresh()
        let source = isDouban ? "豆瓣优片" : "默认片库"
        showSuccess("切换至 \(source)")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var bouncesType: BouncesType {
        return .child
    }
    
    override var switcherConfig: SegementSlideSwitcherConfig {
        var config = SegementSlideSwitcherConfig.shared
        config.indicatorColor = AppTheme.isDark ? .groupTableViewBackground : .darkGray
        config.normalTitleColor = .lightGray
        config.selectedTitleColor = AppTheme.isDark ? .groupTableViewBackground : .darkGray
        config.type = .tab
        return config
    }
    override var titlesInSwitcher: [String] {
        return Category.allCases.map { $0.title }
    }

    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        selected = Category(rawValue: index)  ?? .film
        switch sourceType {
        case .normal:
            let target = VideoListViewController()
            target.category = Category.allCases[index]
            target.isDouban = isDouban
            return target
        case .rank:
            let target = RankListViewController()
            target.category = Category.allCases[index]
            return target
        }
    }

    @objc func rank() {
        let target = CategoryViewController()
        target.sourceType = .rank
        push(viewController: target, animated: true)
    }
}


extension CategoryViewController {
    func refresh() {
        self.reloadData()
        let index = selected.rawValue
        self.scrollToSlide(at: index, animated: false)
    }
}

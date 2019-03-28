//
//  EpisodeItemComponent.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon

struct EpisodeItemComponent: IdentifiableComponent {
    typealias Content = EpisodeItemContentView

    var id: String {
        return data.url
    }

    var data: Episode

    func renderContent() -> Content {
        let content = Content()
        return content
    }

    func render(in content: Content) {
        content.episodeBtn.setTitle("\(data.title)", for: .normal)
        content.episodeBtn.isSelected = false
        content.backgroundColor = UIColor(hexString: "#ECF0F1")
    }

    func referenceSize(in bounds: CGRect) -> CGSize? {
        return CGSize(width: (bounds.size.width - 15) / 4.0, height: 30)
    }

    func shouldContentUpdate(with next: EpisodeItemComponent) -> Bool {
        return data != next.data
    }
}

struct SourceItemComponent: IdentifiableComponent {
    typealias Content = EpisodeItemContentView
    
    var id: VideoSource {
        return data
    }
    
    var data: VideoSource


    func renderContent() -> Content {
        let content = Content()
        return content
    }
    
    func render(in content: Content) {
        let title = data.source == 0 ? "默认线路" : "线路-\(data.source)"
        content.episodeBtn.setTitle(title, for: .normal)
        content.episodeBtn.isSelected = data.isSelected
        content.backgroundColor = data.isSelected ? UIColor(hexString: "#434343") : UIColor(hexString: "#ECF0F1")
    }
    
    func referenceSize(in bounds: CGRect) -> CGSize? {
        let column: CGFloat = 6.0
        let gap = (column - 1) * 5.0
        return CGSize(width: (bounds.size.width - gap) / column, height: 30)
    }
    
    func shouldContentUpdate(with next: SourceItemComponent) -> Bool {
        return data != next.data
    }
}

class EpisodeItemContentView: UIView {

    lazy var episodeBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hexString: "#434343"), for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.isUserInteractionEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 11)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        layer.masksToBounds = true

        backgroundColor = UIColor(hexString: "#ECF0F1")
        addSubview(episodeBtn)

        episodeBtn.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


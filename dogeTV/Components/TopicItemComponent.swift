//
//  TopicItemComponent.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon

struct TopicItemComponent: IdentifiableComponent {
    typealias Content = TopicItemContentView

    var id: String {
        return data.id
    }

    var data: Topic

    func renderContent() -> Content {
        let content = Content()
        return content
    }

    func render(in content: Content) {
        content.coverImageView.setResourceImage(with: data.cover, placeholder: UIImage(named: "logo"))
        content.backgroundImageView.setResourceImage(with: data.cover, placeholder: UIImage(named: "blur"))
        content.titleLabel.text = data.title
        content.introLabel.text = data.desc
    }

    func referenceSize(in bounds: CGRect) -> CGSize? {
        return CGSize(width: bounds.width - 16, height: 200)
    }

    func shouldContentUpdate(with next: TopicItemComponent) -> Bool {
        return data.id != next.data.id
    }

}


class TopicItemContentView: UIView {

    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        return imageView
    }()

    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    lazy var introLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .groupTableViewBackground
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addSubview(backgroundImageView)
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(introLabel)
        
        let padding = 8.0

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(padding)
            $0.size.equalTo(90)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(coverImageView)
            $0.left.equalTo(coverImageView.snp.right).offset(padding)
            $0.right.equalToSuperview().offset((-padding))
        }
        
        introLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(padding)
            $0.right.equalTo(titleLabel)
            $0.left.equalTo(coverImageView)
            $0.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-8)
        }

        let blur = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blur)
        backgroundImageView.addSubview(effectView)
        effectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

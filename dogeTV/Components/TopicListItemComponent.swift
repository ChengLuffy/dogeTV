//
//  TopicListItemComponent.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon

struct TopicListItemComponent: IdentifiableComponent {
    typealias Content = TopicListItemContentView

    let data: Topic

    var id: String {
        return data.id
    }

    func renderContent() -> Content {
        let content = Content()
        return content
    }

    func render(in content: Content) {
        content.coverImageView.setResourceImage(with: data.cover, placeholder: UIImage(named: "logo"))
        content.titleLabel.text = data.title
    }

    func referenceSize(in bounds: CGRect) -> CGSize? {
        return CGSize(width: 80, height: 120)
    }

    func shouldContentUpdate(with next: TopicListItemComponent) -> Bool {
        return data.id != next.data.id
    }
}


class TopicListItemContentView: UIView {
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .groupTableViewBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello World"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        addSubview(coverImageView)
        addSubview(titleLabel)
        coverImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 80, height: 80))
            $0.top.centerX.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom)
            $0.height.equalTo(40)
            $0.left.right.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

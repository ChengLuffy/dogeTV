//
//  SearchViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import UIKit
import SnapKit
import Carbon
import PromiseKit
import Kingfisher
import PKHUD

class SearchViewController: BaseViewController {

    enum Segment: Int, CaseIterable {
        case search
        case parse

        var title: String {
            switch self {
            case .search: return "搜索"
            case .parse: return "云解析"
            }
        }

        var placeholder: String {
            switch self {
            case .search: return "搜索电影/演员/导演"
            case .parse: return "爱奇艺/优酷/腾讯/芒果/B站 链接"
            }
        }
    }

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Segment.search.placeholder
        searchBar.delegate = self
        searchBar.theme_tintColor = AppColor.tintColor
        searchBar.removeBackgroundImageView()
        searchBar.theme_keyboardAppearance = AppColor.keyboardAppearance
        return searchBar
    }()

    lazy var segmentTitleView: UISegmentedControl = {
        let segment = UISegmentedControl(items: Segment.allCases.map { $0.title })
        segment.selectedSegmentIndex = 0
        Segment.allCases.forEach{ segment.setWidth(80, forSegmentAt: $0.rawValue) }
        segment.addTarget(self, action: #selector(segmentIndexChanged(_:)), for: .valueChanged)
        return segment
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.theme_backgroundColor = AppColor.backgroundColor
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()


    var index: Int = 1
    var results: [Video] = []
    var parseResult: CloudParse?
    var input: String?

    lazy var renderer = Renderer(
        target: collectionView,
        adapter: UICollectionViewFlowLayoutAdapter(),
        updater: UICollectionViewUpdater()
    )
    
    lazy var emptySection: Section = {
        return Section(id: "empty", header: ViewNode(EmptyComponent(text: "💌 How to use?\n\n 1. [搜索] 电影/演员/导演 \n\n2. [云解析] 爱奇艺/优酷/腾讯/芒果/B站...会员视频")))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = segmentTitleView
        setupViews()

        if searchBar.canBecomeFirstResponder {
            searchBar.becomeFirstResponder()
        }
        render()
    }

    @objc func segmentIndexChanged(_ sender: UISegmentedControl) {
        view.endEditing(true)
        searchBar.text = nil
        switch sender.selectedSegmentIndex {
        case Segment.search.rawValue:
            searchBar.placeholder = Segment.search.placeholder
            collectionView.bindFootRefreshHandler({ [weak self] in
                self?.loadMore()
                }, themeColor: .darkGray, refreshStyle: .replicatorWoody)
            collectionView.footRefreshControl.autoRefreshOnFoot = true
        case Segment.parse.rawValue:
            searchBar.placeholder = Segment.parse.placeholder
            collectionView.footRefreshControl = nil
        default:
            break
        }
        render()
    }

    func setupViews() {
        view.addSubview(searchBar)
        view.theme_backgroundColor = AppColor.secondaryBackgroundColor
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            $0.left.equalToSuperview().offset(8)
            $0.right.equalToSuperview().offset(-8)
            $0.height.equalTo(44)
        }
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }

        renderer.adapter.didSelect = {[weak self] ctx in
            if let item = ctx.node.component.as(SearchItemComponent.self) {
                self?.showVideo(with: item.id)
            } else if let item = ctx.node.component.as(EpisodeItemComponent.self) {
                self?.play(url: item.data.url)
            }
        }
    }


    func render() {
        switch segmentTitleView.selectedSegmentIndex {
        case Segment.search.rawValue: renderSearchResult()
        case Segment.parse.rawValue: renderParseResult()
        default: break
        }
    }

    func renderParseResult() {
        guard let result = parseResult else {
            renderer.render(emptySection)
            return
        }

        let header = ViewNode(VideoEpisodeHeaderComponent(title: result.title))
        let cells = result.episodes.map { (item) -> CellNode in
            CellNode(EpisodeItemComponent(data: item))
        }
        let section = Section(id: "episodes", header: header , cells: cells)
        renderer.render(section)
    }

    func renderSearchResult() {
        guard !results.isEmpty else {
            renderer.render(emptySection)
            return
        }
        let cells = results.map { (item) -> CellNode in
            CellNode(SearchItemComponent(data: item))
        }
        renderer.render(Section(id: 0, cells: cells))
    }
    
    func play(url: String) {
        guard !url.isEmpty, let streamURL = URL(string: url) else {
            showInfo("无效的链接")
            return
        }
        
        let target = PlayerViewController()
        self.present(target, animated: true) {
                target.play(url: streamURL.absoluteString, title: nil)
        }
        self.searchBar.text = nil
    }

    func execute(text: String) {
        // Search
        if segmentTitleView.selectedSegmentIndex == Segment.search.rawValue {
            search(keywords: text)
            return
        }

        // Parse
        guard let url = URL(string: text) else {
            showInfo("链接地址有误")
            return
        }

        parse(url: url)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard self.input != searchBar.text else {
            return
        }
        self.input = searchBar.text
        guard let input = searchBar.text, input.count > 0 else { return }
        execute(text: input)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

}

extension SearchViewController {

    func parse(url: URL) {
        HUD.show(.progress)
        _ = APIClient.cloudParse(url: url.absoluteString)
            .done { (result) in
                self.parseResult = result
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.render()
                HUD.hide()
        }
    }

    func search(keywords: String) {
        HUD.show(.progress)
        _ = APIClient.search(keywords: keywords)
            .done { (items) in
                self.results = items
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.index = 1
                self.collectionView.footRefreshControl?.resumeRefreshAvailable()
                HUD.hide()
                self.render()
        }
    }

    func loadMore() {
        guard let keywords = input else {
            return
        }
        index += 1
        APIClient.search(keywords: keywords, page: index).done { (videos) in
            if videos.isEmpty {
                self.collectionView.footRefreshControl?.endRefreshingAndNoLongerRefreshing(withAlertText: "已经全部加载完毕")
                return
            }
            self.results.append(contentsOf: videos)
            }.catch{ (error) in
                self.index = max(1, self.index-1)
                self.showError(error)
            }.finally {
                self.render()
                self.collectionView.footRefreshControl?.endRefreshing()
        }
    }
}




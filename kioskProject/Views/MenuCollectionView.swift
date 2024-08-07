//
//  MenuCollectionView.swift
//  kioskProject
//
//  Created by 김승희 on 7/2/24.
//

// 승환님

import UIKit
import SnapKit

// MainViewController 에서 사용하기 위한 Delegate 생성
protocol CustomCollectionViewDelegate: AnyObject {
    func didSelectMenuItem(_ item: MenuItem)
}

class MenuCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 컬렉션 뷰 생성
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1 // 0으로 하면 셀 넘길때 셀이 가끔 사라져서 1로 수정
//        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()
    // 페이징 처리를 위한 컨트롤 객체 생성
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    // 메뉴 데이터를 저장할 배열 생성
    var menuData: [MenuItem] = []
    // 데이터 사용을 위한 delegate 생성
    weak var delegate: CustomCollectionViewDelegate?
    
    // 메뉴 리스트에 메뉴 추가
    func menuSetting(_ category: String) {
        if let menuDatas = menuItems {
            for i in menuDatas {
                if i.category == category {
                    menuData.append(i)
                }
            }
        }
    }
    
    init(frame: CGRect = .zero, _ category: String) {
        super.init(frame: frame)
        setupView()
        menuSetting(category)
        updatePageControl()
    }
    
    private func updatePageControl() {
        let totalItems = menuData.count
        let remainder = totalItems % 4
        let numberOfItems = remainder == 0 ? totalItems : totalItems + (4 - remainder)
        pageControl.numberOfPages = numberOfItems / 4
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: "MenuCollectionViewCell")
        collectionView.backgroundColor = .white
        
        addSubview(collectionView)
        addSubview(pageControl)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let totalItems = menuData.count
        let remainder = totalItems % 4
        return remainder == 0 ? totalItems : totalItems + (4 - remainder)
    }
    
    // menuCell 을 만듦
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
        if indexPath.item < menuData.count {
            let menuData = menuData[indexPath.item]
            // configure 메소드 만들어서 name 과 price, Image 저장할 수 있는 Label 만들어 주세요
            cell.configure(menuName: menuData.name, price: menuData.price, image: menuData.image)
        } else {
            // 빈 셀 설정
            cell.configure(menuName: "", price: "", image: "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height / 2 - 10
        let width = (collectionView.frame.width - 1) / 2
        return CGSize(width: width, height: height)
    }
    
    // 페이징 처리
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    // 셀 클릭시 작동할 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            print("delegate is not set")
            return
        }
        
        // 셀 클릭 시 작동할 함수 만들어야 함
        if menuData.count > indexPath.item {
            let menu = menuData[indexPath.item]
            delegate.didSelectMenuItem(menu)
        } else {
            print("없는 상품")
        }
    }
    
    // 페이지 컨트롤 클릭시 이동
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let page = sender.currentPage
        let xOffset = CGFloat(page) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
}

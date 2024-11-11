//
//  SliderVC.swift
//  firstSlider
//
//  Created by Chmil Oleksandr on 07.11.2024.
//

import UIKit

class SliderVC: UIViewController {
    
    // MARK: variables begin here ->
    private let sliderData: [SliderItem] = [
        SliderItem(color: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : UIColor.black.withAlphaComponent(0.55)
        }, title: "Slide 1", text: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod", animationName: "sy"),
        
        SliderItem(color: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : UIColor.black.withAlphaComponent(0.65)
        }, title: "Slide 2", text: "Duis aute irure dolor in reprehenderit in", animationName: "a2"),
        
        SliderItem(color: UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : UIColor.black.withAlphaComponent(0.55)
        }, title: "Slide 3", text: "proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", animationName: "a3")
    ]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(SliderCell.self, forCellWithReuseIdentifier: "cell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .systemTeal
            }
        
        return collection
    }()
    
    lazy var skipBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return btn
    }()
    
    lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 5
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let shape = CAShapeLayer()
    private var currentPageIndex: CGFloat = 0
    private var fromValue: CGFloat = 0
    
    lazy var nextBtn: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextSlide) )
        let nextImg = UIImageView()
        nextImg.image = UIImage(systemName: "chevron.right.circle.fill")
        nextImg.tintColor = .white
        nextImg.contentMode = .scaleAspectFit
        nextImg.translatesAutoresizingMaskIntoConstraints = false
        nextImg.widthAnchor.constraint(equalToConstant: 45).isActive = true
        nextImg.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(tapGesture)
        btn.addSubview(nextImg)
        nextImg.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
        nextImg.centerXAnchor.constraint(equalTo: btn.centerXAnchor).isActive = true
        
        return btn
    }()
    
    private var pagers: [UIView] = []
    private var currentSlide = 0
    private var pageWidthAnchor: NSLayoutConstraint?
    
    // MARK: variables end here <-
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        setControll()
        setShape()
    }
    
    
    // MARK: func
    private func setShape() {
        currentPageIndex = CGFloat(1) / CGFloat(sliderData.count)
        
        let nextStroke = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 23, startAngle: -(.pi/2), endAngle: 5, clockwise: true)
        
        let trackShape = CAShapeLayer()
        trackShape.path = nextStroke.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 3
        trackShape.strokeColor = UIColor.white.cgColor
        trackShape.opacity = 0.1
        nextBtn.layer.addSublayer(trackShape)
        
        
        shape.path = nextStroke.cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        shape.strokeStart = 0
        shape.strokeEnd = 0
        
        nextBtn.layer.addSublayer(shape)
    }
    private func setControll() {
        view.addSubview(hStack)
        
        let pagerStack = UIStackView()
        pagerStack.axis = .horizontal
        pagerStack.distribution = .fill
        pagerStack.spacing = 5
        pagerStack.alignment = .center
        pagerStack.translatesAutoresizingMaskIntoConstraints = false
        
        
        for tag in 1...sliderData.count {
            let pager = UIView()
            pager.tag = tag
            pager.translatesAutoresizingMaskIntoConstraints = false
            pager.backgroundColor = .white
//            pager.widthAnchor.constraint(equalToConstant: 10).isActive = true
//            pager.heightAnchor.constraint(equalToConstant: 10).isActive = true
            pager.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollToSlide(sender: ) )))
            pager.layer.cornerRadius = 5
            self.pagers.append(pager)
            pagerStack.addArrangedSubview(pager)
        }
        vStack.addArrangedSubview(pagerStack)
        vStack.addArrangedSubview(skipBtn)
        hStack.addArrangedSubview(vStack)
        hStack.addArrangedSubview(nextBtn)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])

    }
    private func setupCollection() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func scrollToSlide(sender: UIGestureRecognizer) {
        if let index = sender.view?.tag {
            collectionView.scrollToItem(at: IndexPath(item: index-1, section: 0), at: .centeredHorizontally, animated: true)
            currentSlide = index - 1
        }
        
    }
    @objc func nextSlide() {
        let maxSlide = sliderData.count
        if currentSlide < maxSlide-1 {
            currentSlide += 1
            collectionView.scrollToItem(at: IndexPath(item: currentSlide, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    

}
// MARK: extension

extension SliderVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sliderData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SliderCell {
            cell.contentView.backgroundColor = sliderData[indexPath.item].color
            cell.titleLabel.text = sliderData[indexPath.item].title
            cell.textLabel.text = sliderData[indexPath.item].text
            
            cell.animationSetup(animationName: sliderData[indexPath.item].animationName)
            return cell
        }
       return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentSlide = indexPath.item
        
        pagers.forEach { page in
            let tag = page.tag
            
            // Тут удаляем констрейнты
            page.constraints.forEach { constrs in
                page.removeConstraint(constrs)
            }
            
            
            let viewTag = indexPath.row + 1
            
            // Тут меняем
            if viewTag == tag {
                UIView.animate(withDuration: 0.3) {page.layer.opacity = 1}
                pageWidthAnchor = page.widthAnchor.constraint(equalToConstant: 20)
            } else {
                UIView.animate(withDuration: 0.3) {page.layer.opacity = 0.3}
                pageWidthAnchor = page.widthAnchor.constraint(equalToConstant: 10)
            }
            pageWidthAnchor?.isActive = true
           page.heightAnchor.constraint(equalToConstant: 10).isActive = true
        }
        let currentIndex = currentPageIndex * CGFloat(indexPath.item+1)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = currentIndex
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.duration = 0.5
        shape.add(animation, forKey: "animation")
        fromValue = currentIndex
    }

    
}



// MARK: struct
    struct SliderItem {
        var color: UIColor
        var title: String
        var text: String
        var animationName: String
    }
    

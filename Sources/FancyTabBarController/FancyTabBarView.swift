//
//  File.swift
//  
//
//  Created by Nikita Semenov on 31.03.2021.
//

import UIKit

final class FancyTabBarView: UIView {
	
	internal struct Constants {
		static let height: CGFloat = 70
		static let width: CGFloat = UIScreen.main.bounds.width
		static let padding: CGFloat = 10
		static let itemSize: CGFloat = 45
	}
	
	private var tabBarColor: UIColor = .clear
	
	private var paddingBetweenItems: CGFloat {
		(Constants.width - CGFloat(count) * (Constants.itemSize - 5)) / CGFloat(count + 1)
	}

	private var tabBarItems: [TabBarItem]! {
		willSet(items) {
			// This method calls only once, when class is initializing
			setupInitialActivation(in: items)
		}
	}
	private var count: Int {
		tabBarItems.count
	}
	
	private var highlighter: UIView!
	
	private var defaultItem = 0
	var selectedIndex: Int = 0 {
		willSet(index) {
			beginTransitionOfHighlighter(to: index)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	required override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	// MARK:- Initializer
	convenience init(
		items: [TabBarItem],
		defaultItem index: Int = 0,
		highlighter: UIView? = nil,
		tabBarColor: UIColor,
		hlColor: UIColor? = nil
	) {
		self.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false
		
		self.tabBarItems = items
		self.tabBarColor = tabBarColor
		
		self.makeHighlighter(highlighter, color: hlColor)
		addSubview(self.highlighter)
		
		self.setupTabBarItems()
		
		self.setConstraints()
		
		self.defaultItem = index
		self.beginTransitionOfHighlighter(to: self.defaultItem)
	}
	
	private func makeHighlighter(_ hl: UIView?, color: UIColor?) {
		if let hl = hl {
			highlighter = hl
		} else {
			makeDefaultHighlighter(withColor: color)
		}
	}
	
	private func makeDefaultHighlighter(withColor color: UIColor?) {
		let size: CGFloat = 60
		let circle = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
		circle.layer.cornerRadius = 30
		circle.translatesAutoresizingMaskIntoConstraints = false
		circle.backgroundColor = color != nil ? color : .clear
		
		highlighter = circle
	}
	
	private func setupInitialActivation(in items: [TabBarItem]) {
		for (index, item) in items.enumerated() {
			if index == 0 {
				item.isActivated = true
			} else {
				item.isActivated = false
			}
		}
	}
	
	private func setupTabBarItems() {
		addTargets()
		addToTabBarAsSubview()
	}
	
	private func addTargets() {
		for item in tabBarItems {
			item.addTarget(self, action: #selector(selectTabBarItem), for: .touchUpInside)
		}
	}
	
	@objc private func selectTabBarItem(_ sender: UIButton) {
		if let senderIndex = tabBarItems.firstIndex(where: { $0 === sender }) {
			let item = tabBarItems[senderIndex]
			item.isActivated = true
			item.setNeedsDisplay()
			
			deSelectItems(despite: item)
		}
		resignSelectedItem()
	}
	
	private func deSelectItems(despite item: TabBarItem) {
		for i in tabBarItems {
			if i !== item {
				i.transform = CGAffineTransform.identity
				i.isActivated = false
				i.setNeedsDisplay()
			}
		}
	}
	
	private func resignSelectedItem() {
		for (index, item) in tabBarItems.enumerated() {
			if item.isActivated {
				selectedIndex = index
			}
		}
	}
	
	private func addToTabBarAsSubview() {
		for item in tabBarItems {
			if item.translatesAutoresizingMaskIntoConstraints {
				item.translatesAutoresizingMaskIntoConstraints = false
			}
			addSubview(item)
		}
	}
	
	private func setConstraints() {
		for (number, item) in tabBarItems.enumerated() {
			if number == 0 {
				// Constraints for the first (activated by default) tabBarItem
				setConstraintsForTabBarItem(item, activated: true, previousItem: nil)
			} else {
				setConstraintsForTabBarItem(item, activated: false, previousItem: tabBarItems[number - 1])
			}
		}
		setConstraintsForHighlighter()
		sendSubviewToBack(highlighter)
	}
	
	private func setConstraintsForTabBarItem(_ item: TabBarItem, activated: Bool, previousItem prevItem: TabBarItem?) {
		let padding = Constants.padding
		let itemSize = Constants.itemSize
		
		NSLayoutConstraint.activate([
			item.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
			
			item.leadingAnchor.constraint(
				equalTo: activated ? leadingAnchor : prevItem!.trailingAnchor,
				constant: paddingBetweenItems),
			
			item.heightAnchor.constraint(equalToConstant: itemSize),
			item.widthAnchor.constraint(equalToConstant: itemSize),
			
		])
	}
	
	private func setConstraintsForHighlighter() {
		let item = tabBarItems[defaultItem]
		
		NSLayoutConstraint.activate([
			highlighter.centerXAnchor.constraint(equalTo: item.centerXAnchor),
			highlighter.centerYAnchor.constraint(equalTo: bottomAnchor),
			highlighter.heightAnchor.constraint(equalToConstant: Constants.itemSize),
			highlighter.widthAnchor.constraint(equalToConstant: Constants.itemSize),
		])
	}
	
	private func beginTransitionOfHighlighter(to index: Int) {
		UIView.animate(
			withDuration: 0.5,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 5,
			options: [.curveEaseInOut, .preferredFramesPerSecond60]
		) {
			let item = self.tabBarItems[index]
			
			item.transform = CGAffineTransform(translationX: 0, y: -Constants.height / 2)
			item.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			self.deSelectItems(despite: item)
			
			self.highlighter.center = CGPoint(x: item.center.x, y: Constants.height)
		}
	}
}

// MARK:- TabBar view setup
extension FancyTabBarView {
	
	override func draw(_ rect: CGRect) {
		let width = Constants.width
		let height = Constants.height

		let rectangle = UIBezierPath()
		rectangle.move(to: CGPoint(x: 0, y: height / 2.5))
		rectangle.addLine(to: CGPoint(x: width, y: height / 2.5))
		rectangle.addLine(to: CGPoint(x: width, y: height))
		rectangle.addLine(to: CGPoint(x: 0, y: height))
		rectangle.close()
		
		tabBarColor.setFill()
		rectangle.fill()
	}
}

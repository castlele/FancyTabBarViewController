import UIKit

@available(iOS 11.0, *)
open class FancyTabBarViewController: UIViewController {
	
	/// Array of view controllers, that are represented by `FancyTabBarViewController`
	/// Always should be equal to amount of 'tabBarItems'
	open var childViewController: [UIViewController]!

	/// Vertical offset of each child view controller
	open var vcHeightOffset: CGFloat = 0
	
	/// Array of Buttons, that presents corresponding view controller from 'childViewController'
	/// Always should be equal to amount of 'childViewController'
	open var tabBarItems: [TabBarItem]!

	/// Index of default item and view controller
	open var tabBarDefaultItem: Int = 0

	open var tabBarColor: UIColor!
	
	/// View, which represents special element of Tab bar
	/// It "highlights" tab bar item
	open var highlighter: UIView!

	open var highlighterColor: UIColor!
	
	/// View of Tab bar
	public var tabBarView: FancyTabBarView!

	private var selectedViewController: Int {
		tabBarView.selectedIndex
	}
	
	/// Initialize `FancyTabBarViewController`
	/// 'tabBarItems', 'childViewController' and 'highlighterColor' should be initialized first before calling this method
	open func initialization() {
		errorCheck()
		
		setupTabBarView()
		setupViewControllers()
		setupInitialViewController()
		
		setConstraints()
	}

	private func errorCheck() {
		guard childViewController.count == tabBarItems.count else {
			fatalError("Error: Amount of ViewController should be equal to items of tab bar")
		}

		guard tabBarItems != nil else {
			fatalError("Error: 'tabBarItems' was't initialized")
		}

		guard childViewController != nil else {
			fatalError("Error: 'childViewController' was't initialized")
		}

		guard highlighterColor != nil else {
			fatalError("Error: 'highlighterColor' was't initialized")
		}
	}
	
	private func setupTabBarView() {
		addTransitionTargetBetweenVC()
		
		tabBarView = FancyTabBarView(
			items: tabBarItems,
			defaultItem: tabBarDefaultItem,
			highlighter: highlighter,
			tabBarColor: tabBarColor,
			hlColor: highlighterColor
		)
		tabBarView.isOpaque = false
		view.addSubview(tabBarView)
	}
	
	private func addTransitionTargetBetweenVC() {
		for item in tabBarItems {
			item.addTarget(self, action: #selector(changeViewController), for: .touchUpInside)
		}
	}
	
	@objc private func changeViewController(_ sender: UIButton) {
		let currentVC = childViewController[selectedViewController]
		let newVC = childViewController[tabBarView.selectedIndex]
		
		remove(viewController: currentVC)
		add(viewController: newVC)
	}
	
	private func remove(viewController vc: UIViewController) {
		vc.willMove(toParent: nil)
		vc.view.removeFromSuperview()
		vc.removeFromParent()
	}
	
	private func add(viewController vc: UIViewController) {
		addChild(vc)
		view.addSubview(vc.view)
		view.sendSubviewToBack(vc.view)
		let vcFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - vcHeightOffset)
		vc.view.frame = vcFrame
		vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		vc.didMove(toParent: self)
	}
	
	private func setupViewControllers() {
		for vc in childViewController {
			add(viewController: vc)
		}
	}
	
	private func setupInitialViewController() {

	}
	
	private func setConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		let tabBarConstants = FancyTabBarView.Constants.self
		
		NSLayoutConstraint.activate([
			tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tabBarView.heightAnchor.constraint(equalToConstant: tabBarConstants.height),
			tabBarView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tabBarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
		])
	}
}

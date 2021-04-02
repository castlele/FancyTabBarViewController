import UIKit

@available(iOS 11.0, *)
open class FancyTabBarViewController: UIViewController {
	
	open var childViewController: [UIViewController]!
	open var vcHeightOffset: CGFloat = 0
	
	open var tabBarItems: [TabBarItem]!
	open var tabBarDefaultItem: Int = 0
	open var tabBarColor: UIColor!
	
	open var highlighter: UIView!
	open var highlighterColor: UIColor!
	
	private var tabBarView: FancyTabBarView!
	private var selectedViewController: Int {
		tabBarView.selectedIndex
	}
	
	open func initialization() {
		guard childViewController.count == tabBarItems.count else {
			fatalError("Error: Amount of ViewController should be equal to items of tab bar")
		}
		
		setupTabBarView()
		setupViewControllers()
		setupInitialViewController()
		
		setConstraints()
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

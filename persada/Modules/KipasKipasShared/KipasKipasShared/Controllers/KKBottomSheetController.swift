//
//  KKBottomSheetController.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 30/05/24.
//

import UIKit

public struct KKBottomSheetConfigureItem {
    let viewHeight: CGFloat
    let canSlideUp: Bool
    let canSlideDown: Bool
    let isShowHeaderView: Bool
    
    public init(
        viewHeight: CGFloat = 300,
        canSlideUp: Bool = true,
        canSlideDown: Bool = true,
        isShowHeaderView: Bool = true
    ) {
        self.viewHeight = viewHeight
        self.canSlideUp = canSlideUp
        self.canSlideDown = canSlideDown
        self.isShowHeaderView = isShowHeaderView
    }
}

open class KKBottomSheetController: UIViewController {

    open lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        view.accessibilityIdentifier = "containerView"
        return view
    }()
    
    open lazy var layerView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "mainView"
        return view
    }()
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.accessibilityIdentifier = "dimmedView"
        return view
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.accessibilityIdentifier = "titleLabel"
        return label
    }()
    
    lazy var headerContainerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.accessibilityIdentifier = "headerContainerStack"
        stack.addArrangedSubview(titleLabel)
        
        let titleStack = UIStackView()
        titleStack.axis = .horizontal
        titleStack.distribution = .fill
        titleStack.alignment = .fill
        titleStack.spacing = 0
        titleStack.isLayoutMarginsRelativeArrangement = true
        titleStack.layoutMargins = UIEdgeInsets(top: 9, left: 33, bottom: 9, right: 9)
        titleStack.addArrangedSubview(titleLabel)
        
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("", for: .normal)
        let symbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let closeIconImage = UIImage(systemName: "xmark", withConfiguration: symbolConfiguration)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        closeButton.setImage(closeIconImage, for: .normal)
        closeButton.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        titleStack.addArrangedSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        stack.addArrangedSubview(titleStack)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spacer.heightAnchor.constraint(equalToConstant: titleLabel.text?.isEmpty == true ? 0 : 1)])
        spacer.backgroundColor = UIColor(hexString: "#EEEEEE")
        stack.addArrangedSubview(spacer)
        
        return stack
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    open var isShowHeaderView: Bool = true
    
    // Constants
    open var viewHeight: CGFloat = 300 {
        didSet{
            currentContainerHeight = viewHeight
            dismissibleHeight = viewHeight * 0.7
        }
    }
    var dismissibleHeight: CGFloat = 200
    public let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 100
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    open var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    var mainViewViewTopConstraint: NSLayoutConstraint?
    
    //for check slidable or not (slide to max)
    open var canSlideUp: Bool = true
    open var canSlideDown: Bool = true
    
    open var handleDraggingDirection: ((Double) -> Void)?
    open var handleDidEndDraggingDirection: ((Double) -> Void)?
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupView()
    }
    
    @objc open func handleCloseAction() {
        animateDismissView()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    open func setupView() {
        view.backgroundColor = .clear
        headerContainerStack.isHidden = !isShowHeaderView
        dismissibleHeight = viewHeight * 0.7
        currentContainerHeight = viewHeight
        setupConstraints()
        
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
    }
    
    public init(
        view: UIView = UIView(),
        title: String = "",
        configure: KKBottomSheetConfigureItem? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        layerView = view
        titleLabel.text = title
        self.configure(with: configure)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with item: KKBottomSheetConfigureItem?) {
        guard let item = item else { return }
        viewHeight = item.viewHeight
        canSlideUp = item.canSlideUp
        canSlideDown = item.canSlideDown
    }
    
    open func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        containerView.addSubview(headerContainerStack)
        containerView.addSubview(layerView)
        headerContainerStack.translatesAutoresizingMaskIntoConstraints = false
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        layerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 100),
        ])
        
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: viewHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: viewHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            headerContainerStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerContainerStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerContainerStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            layerView.topAnchor.constraint(equalTo: isShowHeaderView ? headerContainerStack.bottomAnchor : containerView.topAnchor),
            layerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            layerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            layerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    private func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        if !isDraggingDown && !canSlideUp { return }
        if isDraggingDown && !canSlideDown { return }
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
            handleDraggingDirection?(translation.y)
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < viewHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(viewHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(viewHeight)
            }
            else if newHeight > viewHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
            handleDidEndDraggingDirection?(translation.y)
        default:
            break
        }
    }
    
    open func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    open func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    open func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    open func animateDismissView(completion: (() -> Void)? = nil) {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            // once done, dismiss without animation
            self.dismiss(animated: false, completion: completion)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.containerViewBottomConstraint?.constant = self.currentContainerHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    open func animateDismissView() {
        animateDismissView(completion: nil)
    }
    
    open func animateHideView(completion: (() -> Void)? = nil) {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.dimmedView.alpha = 0
        } completion: { [weak self] _ in
            guard let self = self else { return }
            // once done, dismiss without animation
            completion?()
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.containerViewBottomConstraint?.constant = self.currentContainerHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}

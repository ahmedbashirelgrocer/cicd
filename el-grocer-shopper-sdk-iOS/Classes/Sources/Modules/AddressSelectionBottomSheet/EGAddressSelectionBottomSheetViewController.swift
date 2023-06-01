//
//  EGAddressSelectionBottomSheetViewController.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 29/05/2023.
//

import Foundation



class EGAddressSelectionBottomSheetViewController  : UIViewController {
    
    
    
    
    class func getAddressViews() -> [UIView] {
        
        
        func createAddressView(with address: String, detail: String) -> UIView {
               let addressView = UIView()
              // addressView.backgroundColor = .lightGray
               
               let pinImageView = UIImageView(image: UIImage(name: "DeliveryAddressPin"))
               pinImageView.translatesAutoresizingMaskIntoConstraints = false
               
               let addressLabel = UILabel()
               addressLabel.text = address
               addressLabel.font = .SFUISemiBoldFont(17)
               addressLabel.translatesAutoresizingMaskIntoConstraints = false
               
               let detailLabel = UILabel()
               detailLabel.text = detail
               detailLabel.font = .SFUIRegularFont(14)
               detailLabel.translatesAutoresizingMaskIntoConstraints = false
               detailLabel.numberOfLines = 0
            
            
               addressView.addSubview(pinImageView)
               addressView.addSubview(addressLabel)
               addressView.addSubview(detailLabel)
               
               // Setup constraints for the subviews
               NSLayoutConstraint.activate([
                   pinImageView.topAnchor.constraint(equalTo: addressView.topAnchor, constant: 16),
                   pinImageView.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 0),
                   pinImageView.widthAnchor.constraint(equalToConstant: 24),
                   pinImageView.heightAnchor.constraint(equalToConstant: 24),
                   
                   addressLabel.leadingAnchor.constraint(equalTo: pinImageView.trailingAnchor, constant: 10),
                   addressLabel.topAnchor.constraint(equalTo: pinImageView.topAnchor, constant: 0),
                   addressLabel.centerYAnchor.constraint(equalTo: addressView.centerYAnchor),
                   
                   detailLabel.leadingAnchor.constraint(equalTo: pinImageView.leadingAnchor, constant: 10),
                   detailLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5),
                   detailLabel.bottomAnchor.constraint(equalTo: addressView.bottomAnchor, constant: 5)
                   
                   
               ])
            
          //  addressView.heightAnchor.constraint(equalToConstant: 100).isActive = true
               
               return addressView
           }
        
        
        var views : [UIView] = []
        // Add address cells to the stack view (you can replace this with your own logic)
        for i in 1...20 {
                 let cell = EGAddressCellView.instantiate()
            cell.configureView(with: "Name goes here", and: "length string goes here aaaaa \n lonnng")
            views.append(cell)

        }
        return views
    }
    

    private var scrollView = UIScrollView()
    private var stackView = UIStackView()
       private let dimView = UIView()
    private lazy var spacer : UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
       private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    
    var views: [UIView] = []
    var singleCellHeight = 0.0
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose delivery Location"
        label.font = .boldSystemFont(ofSize: 20)
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
       // label.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16)
        return label
    }()

    init(views: [UIView]) {
        
        self.views = views
        if views.count > 0 {
            let view = views[0]
            self.singleCellHeight = view.frame.size.height
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    }

       override func viewDidLoad() {
           super.viewDidLoad()
           
           setupViews()
           setupGestureRecognizer()
       }
       
       private func setupViews() {
           
           
           stackView.addBackground(color: .white)
           scrollView.bounces = false
           scrollView.showsVerticalScrollIndicator = false
           scrollView.showsHorizontalScrollIndicator = false
           scrollView.layer.cornerRadius = 10
           
           scrollView.translatesAutoresizingMaskIntoConstraints = false
           stackView.translatesAutoresizingMaskIntoConstraints = false
           dimView.translatesAutoresizingMaskIntoConstraints = false
           
           // Configure the stack view properties
           stackView.axis = .vertical
           stackView.spacing = 0
           
           // Configure the dim view properties
           dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
           
           // Add subviews
           view.addSubview(dimView)
           view.addSubview(scrollView)
           scrollView.addSubview(stackView)
        
           stackView.addArrangedSubview(spacer)
           stackView.addArrangedSubview(titleLabel)
           stackView.addArrangedSubview(spacer)
           for data in self.views {
               stackView.addArrangedSubview(data)
               stackView.addArrangedSubview(spacer)
           }
           
           // Configure constraints
           NSLayoutConstraint.activate([
               
               titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 0 ),
            
               dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               dimView.topAnchor.constraint(equalTo: view.topAnchor),
               dimView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
               
               scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
               
               stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
               stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
               stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
               stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
               stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
               
              
            
           ])
           
//<<<<<<< Updated upstream
//           let heightConstraint = stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
//                  heightConstraint.priority = .defaultLow
//                  heightConstraint.isActive = true
//
//           scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
//
//=======
           
           let heightConstraint = stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
               heightConstraint.priority = .defaultLow
               heightConstraint.isActive = true

       }
       
       private func setupGestureRecognizer() {
           let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
           dimView.addGestureRecognizer(tapGestureRecognizer)
           
           let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                  dimView.addGestureRecognizer(panGestureRecognizer)
       }
       
       @objc private func dimViewTapped() {
           dismiss(animated: true, completion: nil)
       }

      
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
            let touchPoint = recognizer.location(in: view.window)
            
            switch recognizer.state {
            case .began:
                initialTouchPoint = touchPoint
            case .changed:
                let deltaY = touchPoint.y - initialTouchPoint.y
                
                // Update the position of the view based on the gesture translation
                if deltaY > 0 {
                    view.frame.origin.y = deltaY
                }
            case .ended, .cancelled:
                let dismissThreshold: CGFloat = 100
                if view.frame.origin.y > dismissThreshold {
                    dismiss(animated: true, completion: nil)
                } else {
                    // Reset the view position
                    UIView.animate(withDuration: 0.3) {
                        self.view.frame.origin.y = 0
                    }
                }
            default:
                break
            }
        }

    
    
}

/*

class EGAddressSelectionBottomSheetViewController : UIViewController {
    
    // define lazy views
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose delivery Location"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
//    lazy var deliveryAddressView: UIStackView = {
//        let adressView : UIStackView = UIStackView()
//        adressView.axis = .vertical
//        adressView.spacing = 10
//        adressView.translatesAutoresizingMaskIntoConstraints = false
//        for index in 0...1 {
//            adressView.addArrangedSubview(self.createAddressView(with: "test", detail: "asdkjfsadklfadsklfsdafkljsadfklsdfksadfk;"))
//        }
//        return adressView
//    }()
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView : UIStackView = UIStackView()  //= UIStackView(arrangedSubviews: [titleLabel, deliveryAddressView, spacer])
        
        stackView.addArrangedSubview(titleLabel)
        for index in 0...1 {
            stackView.addArrangedSubview(self.createAddressView(with: "test", detail: "asdkjfsadklfadsklfsdafkljsadfklsdfksadfk;"))
        }
        stackView.addArrangedSubview(spacer)
        stackView.axis = .vertical
        stackView.spacing = 12.0
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            // content stackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
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
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    
}


extension EGAddressSelectionBottomSheetViewController {
    
    func createAddressView(with address: String, detail: String) -> UIView {
           let addressView = UIView()
           addressView.backgroundColor = .lightGray
           
           let pinImageView = UIImageView(image: UIImage(named: "pin_icon"))
           pinImageView.translatesAutoresizingMaskIntoConstraints = false
           
           let addressLabel = UILabel()
           addressLabel.text = address
           addressLabel.translatesAutoresizingMaskIntoConstraints = false
           
           let detailLabel = UILabel()
           detailLabel.text = detail
           detailLabel.translatesAutoresizingMaskIntoConstraints = false
           
           addressView.addSubview(pinImageView)
           addressView.addSubview(addressLabel)
           addressView.addSubview(detailLabel)
           
           // Setup constraints for the subviews
           NSLayoutConstraint.activate([
               pinImageView.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 10),
               pinImageView.centerYAnchor.constraint(equalTo: addressView.centerYAnchor),
               pinImageView.widthAnchor.constraint(equalToConstant: 20),
               pinImageView.heightAnchor.constraint(equalToConstant: 20),
               
               addressLabel.leadingAnchor.constraint(equalTo: pinImageView.trailingAnchor, constant: 10),
               addressLabel.centerYAnchor.constraint(equalTo: addressView.centerYAnchor),
               
               detailLabel.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 10),
               detailLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5)
           ])
           
           return addressView
       }
    
}
*/

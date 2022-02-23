//
//  MenuDetailsViewController.swift
//  pizzadelivery-ios
//
//  Created by Bruno Costa on 11/01/22.
//

import UIKit

class DishDetailsViewController: UIViewController, MenuBaseCoordinated {
    
    // MARK: - ViewModel
    
    public var itemMenuViewModel: ItemMenuViewModel?
    private var orderViewModel: OrderViewModel?
    private var itemOrderViewModel: ItemOrderViewModel?
    private var itemOrderListViewModel: ItemOrderListViewModel?
    
    // MARK: - Variables
    
    private var flag = ItemOrderStatus.create
    
    // MARK: - Views
    
    var coordinator: MenuBaseCoordinator?
    private var dishImageView = DishImageView(frame: .zero)
    private let infoView = DishInfoView()
    private let commentView = DishCommentView()
    private let quantityView = DishQuantityView()
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let myCartButton = MyCartButton()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchOrder()
        fetchItems()
        fetchCurrentItem()
        setFlag()
        configureDishDetails()
        configureMyCartButton()
    }
    
    // MARK: - Initialization
    
    required init(coordinator: MenuBaseCoordinator) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setFlag() {
        if itemOrderViewModel != nil {
            flag = ItemOrderStatus.update
        }
    }
    
    private func configureDishDetails() {
        if let itemMenuVM = itemMenuViewModel?.itemMenu {
            dishImageView.configureWith(url: itemMenuVM.imageUrl)
            infoView.configureWith(name: itemMenuVM.name, description: itemMenuVM.description, price: itemMenuVM.price)
            quantityView.configureAddToCartButtonWith(flag: flag, price: String(itemMenuVM.price))
        }
        
        if let itemOrderVM = itemOrderViewModel {
            commentView.configureWith(comment: itemOrderVM.comment)
            quantityView.quantityLabel.text = String(describing: itemOrderVM.quantity)
            quantityView.configureAddToCartButtonWith(flag: flag, price: calculateItems(Int(itemOrderVM.quantity), price: itemOrderVM.price))
        }
    }
    
    private func configureMyCartButton() {
        if let itemListVM = itemOrderListViewModel {
           myCartButton.configureWithText(quantity: itemListVM.quantity, totalPrice: itemListVM.totalOrder)
           myCartButton.isHidden = false
        }
    }
    
    func updateQuantityView(quantity: Int, flag: ItemOrderStatus) {
        let itemPrice = itemMenuViewModel!.itemMenu.price
        
        if flag == ItemOrderStatus.create || flag == ItemOrderStatus.update {
            quantityView.quantityLabel.text = String(describing: quantity)
            quantityView.configureAddToCartButtonWith(flag: flag, price: calculateItems(quantity, price: itemPrice))
            quantityView.decreaseButton.isEnabled = true
        } else if flag == ItemOrderStatus.remove {
            quantityView.quantityLabel.text = "0"
            quantityView.configureAddToCartButtonWith(flag: flag, price: String(describing: itemPrice))
            quantityView.decreaseButton.isEnabled = false
        }
    }
    
    func calculateItems(_ quantity: Int, price: Double) -> String {
        let total = Double(quantity) * Double(price)
        return String(format: "%.2f", total)
    }
    
    private func configureButtons() {
        quantityView.addToCartButton.addTarget(self, action: #selector(addToCartButtonPressed(_:)), for: .touchUpInside)
        myCartButton.addTarget(self, action: #selector(goToCartScreen), for: .touchUpInside)
        quantityView.increaseButton.addTarget(self, action: #selector(increaseQuantityButtonPressed(_:)), for: .touchUpInside)
        quantityView.decreaseButton.addTarget(self, action: #selector(decreaseQuantityButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 2.0
    }
    
    // MARK: - Setup Constraints
    
    private func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupStackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupImageViewConstraints() {
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dishImageView.heightAnchor.constraint(equalToConstant: 120),
            dishImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    private func setupInfoViewConstraints() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupCommentViewConstraints() {
        commentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupQuantityViewConstraints() {
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            quantityView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupMyCartButtonConstraints() {
        myCartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myCartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myCartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            myCartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - ViewConfiguration
extension DishDetailsViewController: ViewConfiguration {
    func setupConstraints() {
        setupStackViewConstraints()
        setupScrollViewConstraints()
        setupImageViewConstraints()
        setupInfoViewConstraints()
        setupCommentViewConstraints()
        setupQuantityViewConstraints()
        setupMyCartButtonConstraints()
    }
    
    func buildViewHierarchy() {
        view.addSubview(scrollView)
        stackView.addArrangedSubview(dishImageView)
        stackView.addArrangedSubview(infoView)
        stackView.addArrangedSubview(commentView)
        stackView.addArrangedSubview(quantityView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(myCartButton)
    }
    
    func configureViews() {
        view.backgroundColor = .white
        configureStackView()
        configureButtons()
    }
}

// MARK: - CoreData

extension DishDetailsViewController {
    private func fetchOrder() {
        CoreDataHelper().fetchCurrentOrder { currentOrder in
            if let currentOrder = currentOrder {
                self.orderViewModel = OrderViewModel(currentOrder)
            }
        }
    }
    
    private func fetchItems() {
        if orderViewModel != nil {
            itemOrderListViewModel = CoreDataHelper().fetchItemsCurrentOrder(orderViewModel: orderViewModel)
        }
    }
    
    private func fetchCurrentItem() {
        if orderViewModel != nil {
            itemOrderViewModel = CoreDataHelper().fetchCurrentItem(itemMenuViewModel: itemMenuViewModel, orderViewModel: orderViewModel)
        }
    }
}

// MARK: - User Actions

extension DishDetailsViewController {
    @objc func increaseQuantityButtonPressed(_ sender: UIButton) {
        var quantity = Int(quantityView.quantityLabel.text!)
        quantity = quantity! + 1
        updateQuantityView(quantity: quantity!, flag: flag)
    }
    
    @objc func decreaseQuantityButtonPressed(_ sender: UIButton) {
        var quantity = Int(quantityView.quantityLabel.text!)
        var temporaryFlag: ItemOrderStatus = flag
        
        if flag == ItemOrderStatus.create && quantity! > 1 {
            quantity = quantity! - 1
        } else if flag == ItemOrderStatus.update && quantity! > 0 {
            quantity = quantity! - 1
            if quantity == 0 {
                temporaryFlag = ItemOrderStatus.remove
            }
        }
        updateQuantityView(quantity: quantity!, flag: temporaryFlag)
    }
    
    @objc func addToCartButtonPressed(_ sender: UIButton) {
        
    }
    
    @objc func goToCartScreen() {
        coordinator?.moveTo(flow: .menu(.cartScreen), data: [])
    }
    
    @objc func goToHomeScreen() {
        coordinator?.moveTo(flow: .menu(.menuScreen), data: [])
    }
}

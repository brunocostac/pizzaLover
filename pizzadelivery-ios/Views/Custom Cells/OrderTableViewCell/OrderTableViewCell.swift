//
//  OrderTableViewCell.swift
//  pizzadelivery-ios
//
//  Created by Bruno Costa on 07/01/22.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    // MARK: - Views
    
    let titleLabel: UILabel = MyLabel(font: UIFont(name: "avenir", size: 14)!, textColor: .black, numberOfLines: 0)
    let descriptionLabel: UILabel = MyLabel(font: UIFont(name: "avenir", size: 14)!, textColor: .black, numberOfLines: 2)
    let priceLabel: UILabel = MyLabel(font: UIFont(name: "avenir-heavy", size: 14)!, textColor: .black, numberOfLines: 0)
    let statusLabel: UILabel =  MyLabel(font: UIFont(name: "avenir-heavy", size: 16)!, textColor: .gray, numberOfLines: 0)
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithText(orderVM: OrderViewModel, itemOrderListVM: ItemOrderListViewModel) {
        titleLabel.text = "Data do pedido: \(orderVM.dateRequest)"
        descriptionLabel.text = itemOrderListVM.itemsDescription
        priceLabel.text = "Valor Total: R$ \(itemOrderListVM.totalOrder)"
        statusLabel.text = "Status: \(comparingDates(firstDate: Date(), secondDate: orderVM.order.dateCompletion!))"
    }
    
    func comparingDates(firstDate: Date, secondDate: Date) -> String {
        if firstDate.compare(secondDate) == .orderedAscending {
            return "Em andamento"
        } else if firstDate.compare(secondDate) == .orderedDescending {
          return "Entregue"
        } else {
          return "Entregue"
        }
    }
    
    // MARK: - Setup Constraints
    
    private func setupTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    private func setupDescriptionLabelConstraints() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    private func setupPriceLabelConstraints() {
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
           priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
           priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
    
    private func setupStatusLabelConstraints() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
           statusLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
           statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ])
    }
}

// MARK: - ViewConfiguration

extension OrderTableViewCell: ViewConfiguration {
    func setupConstraints() {
        setupTitleLabelConstraints()
        setupDescriptionLabelConstraints()
        setupPriceLabelConstraints()
        setupStatusLabelConstraints()
    }
    
    func buildViewHierarchy() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(priceLabel)
        addSubview(statusLabel)
    }
    
    func configureViews() {
        backgroundColor = .white
        selectionStyle = .none
    }
}

//
//  CoreDataHelper.swift
//  pizzadelivery-ios
//
//  Created by Bruno Costa on 02/02/22.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Order functions
    
    public func createOrder() {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        let predicate = NSPredicate(format: "isOpen == true")
        let orderEntity = Order(context: self.coreDataStack.managedObjectContext)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let orders: [Order] = try self.coreDataStack.managedObjectContext.fetch(request)
            if orders == [] {
                orderEntity.isOpen = true
                orderEntity.orderId = UUID()
                coreDataStack.saveContext()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    public func fetchCurrentOrder(completion: @escaping (Order?) -> Void) {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        let predicate = NSPredicate(format: "isOpen == true")
        var order: Order?
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let orders: [Order] = try self.coreDataStack.managedObjectContext.fetch(request)
            if orders != [] {
                order = orders[0]
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        completion(order)
    }
    
    public func updateOrder(orderViewModel: OrderViewModel?, completion: @escaping (Bool) -> Void) {
        if orderViewModel != nil {
            let request: NSFetchRequest<Order> = Order.fetchRequest()
            request.fetchLimit = 1
            do {
                let result = try self.coreDataStack.managedObjectContext.fetch(request)
                if result != [] {
                    coreDataStack.saveContext()
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
    }
    
    public func fetchOrders(completion: @escaping ([Order]?) -> Void) {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        let predicate = NSPredicate(format: "isOpen == false")
        var orderList = [Order]()
        
        request.predicate = predicate
        
        do {
            let orders: [Order] = try coreDataStack.managedObjectContext.fetch(request)
            orderList = orders
        } catch {
            print("Error fetching data from context \(error)")
        }
        completion(orderList)
    }
    
    // MARK: - ItemOrder functions
    
    public func saveItem(itemOrderViewModel: ItemOrderViewModel?, orderViewModel: OrderViewModel?, completion: @escaping (Bool) -> Void) {
        if let currentItemId = itemOrderViewModel?.itemId, let currentOrder = orderViewModel?.order {
            let request: NSFetchRequest<ItemOrder> = ItemOrder.fetchRequest()
            let itemIdAsString = String(describing: currentItemId)
            let predicateOne = NSPredicate(format: "itemId MATCHES %@", itemIdAsString)
            let predicateTwo = NSPredicate(format: "parentOrder == %@", currentOrder)
            
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateOne, predicateTwo])
            
            do {
                let result = try coreDataStack.managedObjectContext.fetch(request)
                if result == [] {
                    createItem(itemOrderViewModel: itemOrderViewModel, orderViewModel: orderViewModel)
                } else {
                    updateItem(itemOrderViewModel: itemOrderViewModel, orderViewModel: orderViewModel)
                }
                completion(true)
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
    }
    
    public func updateItem(itemOrderViewModel: ItemOrderViewModel?, orderViewModel: OrderViewModel?) {
        if let currentItemId = itemOrderViewModel?.itemId, let currentOrder = orderViewModel?.order {
            let request: NSFetchRequest<ItemOrder> = ItemOrder.fetchRequest()
            let itemIdAsString = String(describing: currentItemId)
            let predicateOne = NSPredicate(format: "(itemId MATCHES %@)", itemIdAsString)
            let predicateTwo = NSPredicate(format: "parentOrder == %@", currentOrder)
            
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateOne, predicateTwo])
            
            do {
                let itemEntity = try coreDataStack.managedObjectContext.fetch(request)
                itemEntity.first!.setValue(itemOrderViewModel!.price, forKey: "price")
                itemEntity.first!.setValue(itemOrderViewModel!.quantity, forKey: "quantity")
                itemEntity.first!.setValue(itemOrderViewModel!.name, forKey: "name")
                itemEntity.first!.setValue(itemOrderViewModel!.comment, forKey: "comment")
                
                coreDataStack.saveContext()
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
    }
    
    public func createItem(itemOrderViewModel: ItemOrderViewModel?, orderViewModel: OrderViewModel?) {
        let itemEntity = ItemOrder(context: coreDataStack.managedObjectContext)
        itemEntity.name = itemOrderViewModel!.name
        itemEntity.price = itemOrderViewModel!.price
        itemEntity.itemId = itemOrderViewModel!.itemId
        itemEntity.comment = itemOrderViewModel!.comment
        itemEntity.quantity = itemOrderViewModel!.quantity
        itemEntity.parentOrder = orderViewModel?.order
        
        coreDataStack.saveContext()
    }
    
    public func removeItem(itemOrderViewModel: ItemOrderViewModel?, orderViewModel: OrderViewModel?, completion: @escaping (Bool) -> Void) {
        if let currentItemId = itemOrderViewModel?.itemId, let currentOrder = orderViewModel?.order {
            let request: NSFetchRequest<ItemOrder> = ItemOrder.fetchRequest()
            let itemIdAsString = String(describing: currentItemId)
            let predicateOne = NSPredicate(format: "(itemId MATCHES %@)", itemIdAsString)
            let predicateTwo = NSPredicate(format: "parentOrder == %@", currentOrder)
            
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateOne, predicateTwo])
            
            do {
                let currentItem = try coreDataStack.managedObjectContext.fetch(request)
                coreDataStack.managedObjectContext.delete(currentItem[0])
                coreDataStack.saveContext()
                completion(true)
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
    }
    
    public func fetchCurrentItem(itemMenuViewModel: ItemMenuViewModel?, orderViewModel: OrderViewModel?) -> ItemOrderViewModel? {
        let request: NSFetchRequest<ItemOrder> = ItemOrder.fetchRequest()
        let currentItemId = String(describing: itemMenuViewModel!.itemMenu.itemId)
        var itemOrderVM: ItemOrderViewModel?
        
        if let currentOrder = orderViewModel?.order {
            let predicateOne = NSPredicate(format: "(itemId MATCHES %@)", currentItemId)
            let predicateTwo = NSPredicate(format: "parentOrder == %@", currentOrder)
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [predicateOne, predicateTwo])
            
            do {
                let currentItem = try coreDataStack.managedObjectContext.fetch(request)
                if currentItem != [] {
                    itemOrderVM = ItemOrderViewModel(itemOrder: currentItem[0])
                }
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
        return itemOrderVM
    }
    
    public func fetchItemsCurrentOrder(orderViewModel: OrderViewModel?) -> ItemOrderListViewModel? {
        let request: NSFetchRequest<ItemOrder> = ItemOrder.fetchRequest()
        var itemOrderListVM: ItemOrderListViewModel?
        if let currentOrder = orderViewModel?.order {
            let predicate = NSPredicate(format: "parentOrder == %@", currentOrder)
            var itemsVM = [ItemOrderViewModel]()

            request.predicate = predicate
           
            do {
                let itemOrders: [ItemOrder] = try coreDataStack.managedObjectContext.fetch(request)
                if itemOrders != [] {
                    for itemOrder in itemOrders {
                        let viewModel = ItemOrderViewModel(itemOrder: itemOrder)
                        itemsVM.append(viewModel)
                    }
                    itemOrderListVM = ItemOrderListViewModel(itemsOrder: itemsVM)
                }
            } catch {
                print("Error fetching data from context \(error)")
            }
        }
        return itemOrderListVM
    }
}

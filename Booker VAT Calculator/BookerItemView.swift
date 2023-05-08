import SwiftUI

struct BookerItemList: View {
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var itemHasVAT = true
    @State private var itemsList = [Item]()
    @FocusState private var isItemNameFocused: Bool
    @FocusState private var isItemPriceFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 8) {
                    TextField("Item name", text: $itemName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isItemNameFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            isItemNameFocused = false
                            isItemPriceFocused = true
                        }
                    
                    TextField("Item price in GBP", text: $itemPrice)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .focused($isItemPriceFocused)
                    
                    HStack {
                        Text("Has VAT?")
                        Spacer()
                        Toggle("", isOn: $itemHasVAT)
                    }
                    
                    Button(action: {
                        if !itemName.isEmpty && !itemPrice.isEmpty {
                            let newItem = Item(name: itemName, price: Float(itemPrice)!, hasVAT: itemHasVAT)
                            itemsList.append(newItem)
                            itemName = ""
                            itemPrice = ""
                            itemHasVAT = true
                            isItemNameFocused = true // set focus back to "Item name"
                        }
                    }) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .padding(18)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if !itemsList.isEmpty {
                        ForEach(itemsList.indices, id: \.self) { index in
                            let item = itemsList[index]
                            let itemPriceWithVAT = item.priceWithVAT()
                            let itemPriceString = item.hasVAT ? "£\(String(format: "%.2f", itemPriceWithVAT)) (incl. VAT)" : "£\(String(format: "%.2f", item.price)) (excl. VAT)"
                            
                            HStack {
                                Text("\(index + 1). \(item.name) - \(itemPriceString)")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button(action: {
                                    itemsList.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(12)
                        Spacer()
                        
                        let totalPrice = itemsList.map { $0.hasVAT ? $0.priceWithVAT() : $0.price }.reduce(0, +)
                        Text("Total Price: £\(String(format: "%.2f", totalPrice))")
                            .fontWeight(.semibold)
                            .padding(.bottom, 16)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Booker VAT Calculator")
            .navigationBarItems(trailing:
                                    Button(action: {
                let shareItems = itemsList.map { "\($0.name) - \(String(format: "%.2f", $0.priceWithVAT()))" }.joined(separator: "\n")
                let av = UIActivityViewController(activityItems: [shareItems], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            )
        }
    }
}

struct Item {
    let name: String
    let price: Float
    let hasVAT: Bool
    
    func priceWithVAT() -> Float {
        let vatRate: Float = 0.2
        return hasVAT ? price * (1 + vatRate) : price
    }
}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        BookerItemList()
    }
}

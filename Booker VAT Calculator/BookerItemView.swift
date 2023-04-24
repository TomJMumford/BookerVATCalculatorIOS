import SwiftUI

struct BookerItemList: View {
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var itemHasVAT = true
    @State private var itemsList = [Item]()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Item name", text: $itemName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 8)
                
                TextField("Item price in GBP", text: $itemPrice)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .padding(.bottom, 8)
                
                HStack {
                    Text("Has VAT?")
                    Spacer()
                    Toggle("", isOn: $itemHasVAT)
                }
                .padding(.bottom, 8)
                
                Button(action: {
                    if !itemName.isEmpty && !itemPrice.isEmpty {
                        let newItem = Item(name: itemName, price: Float(itemPrice)!, hasVAT: itemHasVAT)
                        itemsList.append(newItem)
                        itemName = ""
                        itemPrice = ""
                        itemHasVAT = true
                    }
                }) {
                    Text("Add Item")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 16)
                
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
                        .padding(.bottom, 8)
                    }
                    
                    Spacer()
                    
                    let totalPrice = itemsList.map { $0.hasVAT ? $0.priceWithVAT() : $0.price }.reduce(0, +)
                    Text("Total Price: £\(String(format: "%.2f", totalPrice))")
                        .fontWeight(.semibold)
                        .padding(.bottom, 16)
                }
            }
            .padding()
            .navigationBarTitle("Booker VAT Calculator")
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

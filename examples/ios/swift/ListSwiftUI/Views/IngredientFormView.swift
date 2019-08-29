import SwiftUI

struct RadioGrid<Data, ID, Content>: View, DynamicViewContent where Data : RandomAccessCollection,
Data.Index == Int, Content : View, ID: Hashable, Data.Element: Equatable {
    private var content: (Data.Element) -> Content
    private var columns: Int
    var data: Data
    @Binding var selection: Data.Element?

    public init(_ data: Data,
                id: KeyPath<Data.Element, ID>,
                columns: Int,
                selection: Binding<Data.Element?>,
                @ViewBuilder builder: @escaping (Data.Element) -> Content) {
        self.data = data
        self.columns = columns
        self.content = builder
        self._selection = selection
    }

    private func setSelection(_ row: Int, _ column: Int) {
        self.selection = self.data[row * self.columns + column]
    }

    private func radioButton(_ row: Int, _ column: Int) -> RadioButton {
        RadioButton(
        isSelected: selection == self.data[row * self.columns + column])
    }

    var body: some View {
        ForEach(0..<data.count/columns) { (row: Int) in
            HStack {
                Spacer()
                ForEach(0..<self.columns) { column in
                    Spacer()
                    VStack {
                        self.content(self.data[row * self.columns + column])
                        self.radioButton(row, column)
                    }.onTapGesture {
                        self.setSelection(row, column)
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct RadioButton: View {
    var isSelected: Bool

    var body: some View {
        if !isSelected {
            return AnyView(Circle().strokeBorder().foregroundColor(Color.black)
                .background(Color.clear).frame(width: 20, height: 20))
        } else {
            return AnyView(
                ZStack {
                    Circle().strokeBorder().foregroundColor(Color.black).frame(width: 20, height: 20)
                    Circle().fill(Color.green).foregroundColor(Color.black).frame(width: 8, height: 8)
                }
            )
        }
    }
}

struct IngredientFormView: View {
    @Binding var recipe: Recipe
    @Binding var showIngredientForm: Bool
    @State var ingredientName: String = ""
    @State var selection: FoodType? = nil

    var body: some View {
        Form {
            Section(header: HStack {
                Text("ingredient")
                Spacer()
                Button("save") {
                    self.recipe.ingredients.append(
                        Ingredient.new(name: self.ingredientName,
                                       foodType: self.selection!)
                    )
                    self.ingredientName = ""
                    self.selection = nil
                    self.showIngredientForm = false
                }
            }) {
                TextField("ingredient name", text: self.$ingredientName)
            }
            Section(header: Text("icon")) {
                RadioGrid(FoodType.allCases,
                          id: \.self,
                          columns: 4,
                          selection: $selection) { (foodType: FoodType) in
                            URLImage(foodType.imgUrl)
                }
            }
        }.navigationBarTitle("ingredient").navigationBarItems(trailing: Button("save") {
            self.recipe.ingredients.append(Ingredient.new(name: self.ingredientName,
                                                     foodType: self.selection!))
            self.showIngredientForm = false
        }).edgesIgnoringSafeArea(.top)
    }
}

struct IngredientFormView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientFormView(recipe: .constant(Recipe()), showIngredientForm: .constant(true))
    }
}


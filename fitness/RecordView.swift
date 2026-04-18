//
//  RecordView.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/12/07.
//  タブ名”登録”

import SwiftUI
import CoreData

struct RecordView: View {
    @State var path: [String] = []
    private let items = ["朝食","昼食","夜食","間食"]
    @Environment(\.managedObjectContext) private var viewContext
    
    // 選択したフードを各セクションごとに保持
    @State private var selectedFoods: [String: [Food]] = [
        "朝食": [],
        "昼食": [],
        "夜食": [],
        "間食": []
    ]
    
    private let defaultsKey = "selectedFoodsByMeal"

    private func saveSelectedFoods() {
        // Convert selectedFoods to dictionary of meal -> [URI String]
        var dict: [String: [String]] = [:]
        for (meal, foods) in selectedFoods {
            dict[meal] = foods.map { $0.objectID.uriRepresentation().absoluteString }
        }
        UserDefaults.standard.set(dict, forKey: defaultsKey)
    }

    private func loadSelectedFoods() {
        guard let dict = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: [String]] else { return }
        var restored: [String: [Food]] = [:]
        for (meal, uriStrings) in dict {
            var foods: [Food] = []
            for uriString in uriStrings {
                if let url = URL(string: uriString),
                   let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    do {
                        if let obj = try viewContext.existingObject(with: objectID) as? Food {
                            foods.append(obj)
                        }
                    } catch {
                        // Ignore missing objects
                    }
                }
            }
            restored[meal] = foods
        }
        // Ensure all meals exist
        for meal in items {
            if restored[meal] == nil { restored[meal] = [] }
        }
        selectedFoods = restored
    }
    
    var body: some View {
        NavigationStack (path :$path) {
            List {
                ForEach(items.indices, id: \.self) { i in
                    Section(header: Text(items[i])) {
                        NavigationLink {
                            NextView { food in
                                var current = selectedFoods[items[i]] ?? []
                                current.append(food)
                                selectedFoods[items[i]] = current
                                saveSelectedFoods()
                            }
                        } label: {
                            Text("フードを追加")
                                .foregroundColor(.blue)
                        }
                        
                        // 選択済みフードの表示
                        if let foods = selectedFoods[items[i]], !foods.isEmpty {
                            ForEach(Array(foods.enumerated()), id: \.element.objectID) { index, food in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(food.food_name ?? "")
                                        .font(.body)
                                    if let cal = food.calorie_value, let p = food.protein_value, let f = food.fat_value, let c = food.carbo_value {
                                        Text("\(cal)kcal たんぱく質 \(p) g ･ 脂質 \(f) g ･ 炭水化物 \(c) g")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        var arr = selectedFoods[items[i]] ?? []
                                        if index < arr.count {
                                            arr.remove(at: index)
                                            selectedFoods[items[i]] = arr
                                            saveSelectedFoods()
                                        }
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadSelectedFoods()
            }
        }
    }
}

#Preview {
    RecordView()
}


struct NextView: View {
    var onSelect: ((Food) -> Void)? = nil
    
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: []) //データ要求
    var foodsData: FetchedResults<Food>
    
    @State var inputfood = ""
    @State var isShowAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodsData) { food in
                    if(( food.food_name?.isEmpty) == false) {
                        HStack {
                            VStack {
                                Text(food.food_name!)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(food.calorie_value!)kcal たんぱく質 \(food.protein_value!) g ･ 脂質 \(food.fat_value!) g ･ 炭水化物 \(food.carbo_value!) g")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                            
                            Button {
                                onSelect?(food)
                                isShowAlert = true
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .alert("追加しました", isPresented: $isShowAlert) {
                                Button("OK") {
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: removeFood)
            }
        }
        .searchable(text: $inputfood, placement: .navigationBarDrawer(displayMode: .always), prompt: "フードを検索")
        .onChange(of: inputfood) {
            serchFood(text: inputfood)
        }
    }
    
    private func serchFood(text: String) {
        if text.isEmpty {
            foodsData.nsPredicate = nil
        } else {
            let foodPredicate: NSPredicate = NSPredicate(format: "food_name contains %@", text)
            foodsData.nsPredicate = foodPredicate
        }
    }
    
    private func removeFood(at offsets: IndexSet) {
        for index in offsets {
            let putFood = foodsData[index]
            viewContext.delete(putFood)
        }
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}



import SwiftUI
import CoreData
import Charts

struct HomeView2: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("goal_inputCalorie") private var goalCalorie: String = ""
    @AppStorage("goal_inputProtein") private var goalProteinPct: String = ""
    @AppStorage("goal_inputFat") private var goalFatPct: String = ""
    @AppStorage("goal_inputCarbo") private var goalCarbPct: String = ""

    private let defaultsKey = "selectedFoodsByMeal"
    private let meals = ["朝食", "昼食", "夜食", "間食"]

    @State private var foodsByMeal: [String: [Food]] = [:]

    // MARK: - Aggregations
    private var totalProtein: Double {
        foodsByMeal.values.flatMap { $0 }.compactMap { Double($0.protein_value ?? "0") }.reduce(0, +)
    }
    private var totalFat: Double {
        foodsByMeal.values.flatMap { $0 }.compactMap { Double($0.fat_value ?? "0") }.reduce(0, +)
    }
    private var totalCarb: Double {
        foodsByMeal.values.flatMap { $0 }.compactMap { Double($0.carbo_value ?? "0") }.reduce(0, +)
    }
    private var totalKcal: Double {
        foodsByMeal.values.flatMap { $0 }.compactMap { Double($0.calorie_value ?? "0") }.reduce(0, +)
    }
    
    private var goalCalorieDouble: Double { Double(goalCalorie) ?? 0 }
    private var goalProteinGram: Double {
        let pct = (Double(goalProteinPct) ?? 0) / 100.0
        return (goalCalorieDouble * pct) / 4.0
    }
    private var goalFatGram: Double {
        let pct = (Double(goalFatPct) ?? 0) / 100.0
        return (goalCalorieDouble * pct) / 9.0
    }
    private var goalCarbGram: Double {
        let pct = (Double(goalCarbPct) ?? 0) / 100.0
        return (goalCalorieDouble * pct) / 4.0
    }

    private var pfcData: [(label: String, value: Double, color: Color)] {
        [
            ("たんぱく質", totalProtein, .blue),
            ("脂質", totalFat, .orange),
            ("炭水化物", totalCarb, .green)
        ]
    }
    
    private var diffCalorie: Double { goalCalorieDouble - totalKcal }
    private var diffProtein: Double { goalProteinGram - totalProtein }
    private var diffFat: Double { goalFatGram - totalFat }
    private var diffCarb: Double { goalCarbGram - totalCarb }
    private var diffPFCData: [(label: String, value: Double, color: Color)] {
        [
            ("たんぱく質", diffProtein, .blue),
            ("脂質", diffFat, .orange),
            ("炭水化物", diffCarb, .green)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(Date.now, style: .date)
                        .font(.largeTitle).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("摂取カロリー")
                        .font(.headline)

                    Chart(pfcData, id: \.label) { item in
                        SectorMark(
                            angle: .value("量", item.value),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .foregroundStyle(item.color)
                        .annotation(position: .overlay) {
                            if item.value > 0 {
                                VStack(spacing: 2) {
                                    Text("\(item.label)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("\(format(item.value)) g")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .padding(2)
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geo in
                            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                            ZStack {
                                // Center total kcal
                                VStack(spacing: 2) {
                                    Text("合計")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(totalKcal)) kcal")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .position(center)
                            }
                        }
                    }
                    .frame(height: 260)

                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("目標との差分（ドーナツ）")
                            .font(.headline)
                        Text("カロリー差分: \(Int(diffCalorie)) kcal")
                            .font(.subheadline)
                            .foregroundColor(diffCalorie < 0 ? .red : .primary)

                        // Protein
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("たんぱく質")
                                    .font(.subheadline).bold()
                                Text("摂取: \(format(totalProtein))g / 目標: \(format(goalProteinGram))g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            let proteinDiff = goalProteinGram - totalProtein
                            let proteinRemaining = max(0, proteinDiff) // 未達
                            let proteinOver = max(0, -proteinDiff)      // 超過

                            let proteinData: [(label: String, value: Double, color: Color)] = {
                                if proteinDiff < 0 {
                                    // 超過時: 表裏をひっくり返した並び（超過→赤 を先頭、目標ベース→グレー を後ろ）
                                    return [
                                        ("Over", proteinOver, .red),
                                        ("Goal", max(0, goalProteinGram), Color.gray.opacity(0.25))
                                    ]
                                } else {
                                    // 未達時: 従来の並び（摂取済み→グレー、残量→カラー）
                                    return [
                                        ("Consumed", max(0, min(totalProtein, goalProteinGram)), Color.gray.opacity(0.25)),
                                        ("Remaining", max(0, proteinRemaining), .blue)
                                    ]
                                }
                            }()

                            Chart(proteinData, id: \.label) { item in
                                SectorMark(
                                    angle: .value("量", item.value),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(2)
                            }
                            .chartOverlay { proxy in
                                GeometryReader { geo in
                                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                    VStack(spacing: 2) {
                                        Text(proteinDiff >= 0 ? "残量" : "超過")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(format(proteinDiff >= 0 ? proteinRemaining : proteinOver)) g")
                                            .font(.subheadline)
                                            .foregroundColor(proteinDiff >= 0 ? .primary : .red)
                                    }
                                    .position(center)
                                }
                            }
                            .rotationEffect(proteinDiff < 0 ? .degrees(180) : .degrees(0))
                            .frame(width: 120, height: 120)
                        }

                        // Fat
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("脂質")
                                    .font(.subheadline).bold()
                                Text("摂取: \(format(totalFat))g / 目標: \(format(goalFatGram))g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            let fatDiff = goalFatGram - totalFat
                            let fatRemaining = max(0, fatDiff)
                            let fatOver = max(0, -fatDiff)

                            let fatData: [(label: String, value: Double, color: Color)] = {
                                if fatDiff < 0 {
                                    return [
                                        ("Over", fatOver, .red),
                                        ("Goal", max(0, goalFatGram), Color.gray.opacity(0.25))
                                    ]
                                } else {
                                    return [
                                        ("Consumed", max(0, min(totalFat, goalFatGram)), Color.gray.opacity(0.25)),
                                        ("Remaining", max(0, fatRemaining), .orange)
                                    ]
                                }
                            }()

                            Chart(fatData, id: \.label) { item in
                                SectorMark(
                                    angle: .value("量", item.value),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(2)
                            }
                            .chartOverlay { proxy in
                                GeometryReader { geo in
                                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                    VStack(spacing: 2) {
                                        Text(fatDiff >= 0 ? "残量" : "超過")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(format(fatDiff >= 0 ? fatRemaining : fatOver)) g")
                                            .font(.subheadline)
                                            .foregroundColor(fatDiff >= 0 ? .primary : .red)
                                    }
                                    .position(center)
                                }
                            }
                            .rotationEffect(fatDiff < 0 ? .degrees(180) : .degrees(0))
                            .frame(width: 120, height: 120)
                        }

                        // Carb
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("炭水化物")
                                    .font(.subheadline).bold()
                                Text("摂取: \(format(totalCarb))g / 目標: \(format(goalCarbGram))g")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            let carbDiff = goalCarbGram - totalCarb
                            let carbRemaining = max(0, carbDiff)
                            let carbOver = max(0, -carbDiff)

                            let carbData: [(label: String, value: Double, color: Color)] = {
                                if carbDiff < 0 {
                                    return [
                                        ("Over", carbOver, .red),
                                        ("Goal", max(0, goalCarbGram), Color.gray.opacity(0.25))
                                    ]
                                } else {
                                    return [
                                        ("Consumed", max(0, min(totalCarb, goalCarbGram)), Color.gray.opacity(0.25)),
                                        ("Remaining", max(0, carbRemaining), .green)
                                    ]
                                }
                            }()

                            Chart(carbData, id: \.label) { item in
                                SectorMark(
                                    angle: .value("量", item.value),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 1
                                )
                                .foregroundStyle(item.color)
                                .cornerRadius(2)
                            }
                            .chartOverlay { proxy in
                                GeometryReader { geo in
                                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                    VStack(spacing: 2) {
                                        Text(carbDiff >= 0 ? "残量" : "超過")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(format(carbDiff >= 0 ? carbRemaining : carbOver)) g")
                                            .font(.subheadline)
                                            .foregroundColor(carbDiff >= 0 ? .primary : .red)
                                    }
                                    .position(center)
                                }
                            }
                            .rotationEffect(carbDiff < 0 ? .degrees(180) : .degrees(0))
                            .frame(width: 120, height: 120)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding()
            }
        }
        .onAppear {
            // Migrate any old stored value from the misspelled key to the correct one
            let oldKey = "goal_inpußtCarbo"
            let newKey = "goal_inputCarbo"
            let defaults = UserDefaults.standard
            if let oldValue = defaults.string(forKey: oldKey), defaults.string(forKey: newKey) == nil {
                defaults.set(oldValue, forKey: newKey)
            }
            loadSelectedFoods()
        }
    }

    // MARK: - Loading
    private func loadSelectedFoods() {
        guard let dict = UserDefaults.standard.dictionary(forKey: defaultsKey) as? [String: [String]] else {
            foodsByMeal = meals.reduce(into: [:]) { $0[$1] = [] }
            return
        }
        var restored: [String: [Food]] = [:]
        for (meal, uriStrings) in dict {
            var foods: [Food] = []
            for uriString in uriStrings {
                if let url = URL(string: uriString),
                   let objectID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let food = try? viewContext.existingObject(with: objectID) as? Food {
                        foods.append(food)
                    }
                }
            }
            restored[meal] = foods
        }
        for meal in meals { if restored[meal] == nil { restored[meal] = [] } }
        foodsByMeal = restored
    }

    // MARK: - Helpers
    private func format(_ value: Double) -> String {
        if value.rounded() == value { return String(Int(value)) }
        return String(format: "%.1f", value)
    }
}

#Preview {
    // Build an in-memory NSPersistentContainer for preview to avoid relying on PersistenceController.preview
    let container = NSPersistentContainer(name: "Model")
    let description = NSInMemoryStoreType
    container.persistentStoreDescriptions = [NSPersistentStoreDescription()]
    container.persistentStoreDescriptions.first?.type = description
    container.loadPersistentStores(completionHandler: { _, _ in })

    return HomeView2()
        .environment(\.managedObjectContext, container.viewContext)
}


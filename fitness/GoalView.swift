//
//  GoalView.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/12/07.
//  タブ名”目標”

import SwiftUI
import Combine

struct GoalView: View {
    @AppStorage("goal_inputCalorie") private var inputCalorie: String = ""
    @AppStorage("goal_inputProtein") private var inputProtein: String = ""
    @AppStorage("goal_inputFat") private var inputFat: String = ""
    @AppStorage("goal_inputCarbo") private var inputCarbo: String = ""
    let maxLength = 3
    
    @State var PFCtuple2 = (0,0,0,0,0,0)
    
    func calcPFC2(calorie: String, protein: String, fat: String, carbo: String) -> (proteing: Int, proteinc: Int, fatg: Int, fatc: Int, carbog: Int, carboc: Int) {
        
        let calorieDouble = changeDouble(calorie)
        let proteinDouble = changeDouble(protein)
        let fatDouble = changeDouble(fat)
        let carboDouble = changeDouble(carbo)
        let proteing = Int(round((calorieDouble * (proteinDouble / 100) / 4)))
        let proteinc = proteing * 4
        let fatg = Int(round((calorieDouble * (fatDouble / 100) / 9)))
        let fatc = fatg * 9
        let carbog = Int(round((calorieDouble * (carboDouble / 100) / 4)))
        let carboc = carbog * 4
        return (proteing,proteinc,fatg,fatc,carbog,carboc)
    }
    
    func changeInt(_ str:String) -> Int {
        guard let result = Int(str) else {
            return 0
        }
        return result
    }
    
    func changeDouble(_ str:String) -> Double {
        guard let result = Double(str) else {
            return 0
        }
        return result
    }
    
    var body: some View {
        VStack {
            // カロリーの入力フィールド作成
            HStack(spacing: 1){
                Text("カロリー")
                    .frame(width: 120, alignment: .leading)
                    .foregroundColor(inputCalorie.isEmpty ? .primary : Color.blue)
                TextField("", text: $inputCalorie)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputCalorie)) { _ in
                        if inputCalorie.count > 5 {
                            inputCalorie = String(inputCalorie.prefix(5))
                        }
                    }
                Text("kcal")
                    .frame(width: 50)
            }
            // たんぱく質の入力フィールド作成
            HStack(spacing: 1){
                Text("たんぱく質(P)")
                    .frame(width: 120, alignment: .leading)
                    .foregroundColor(inputProtein.isEmpty ? .primary : Color.blue)
                TextField("", text: $inputProtein)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputProtein)) { _ in
                        if inputProtein.count > 3 {
                            inputProtein = String(inputProtein.prefix(3))
                        }
                    }
                Text("%")
                    .frame(width: 50)
                
            }
            
            // 脂質の入力フィールド作成
            HStack(spacing: 1){
                Text("脂質(F)")
                    .frame(width: 120, alignment: .leading)
                    .foregroundColor(inputFat.isEmpty ? .primary : Color.blue)
                TextField("", text: $inputFat)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputFat)) { _ in
                        if inputFat.count > 3 {
                            inputFat = String(inputFat.prefix(3))
                        }
                    }
                Text("%")
                    .frame(width: 50)
                
            }
            // 炭水化物の入力フィールド作成
            HStack(spacing: 1){
                Text("炭水化物(C)")
                    .frame(width: 120, alignment: .leading)
                    .foregroundColor(inputCarbo.isEmpty ? .primary : Color.blue)
                TextField("", text: $inputCarbo)
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputCarbo)) { _ in
                        if inputCarbo.count > 3 {
                            inputCarbo = String(inputCarbo.prefix(3))
                        }
                    }
                Text("%")
                    .frame(width: 50)
                
            }
             
            // 摂取タンパク質量の表示
            HStack(spacing: 20){
                let PFCtuple2 = calcPFC2(calorie: inputCalorie, protein: inputProtein, fat: inputFat, carbo: inputCarbo)
                Text("たんぱく質(P)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.proteing)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.proteinc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
            
            // 摂取脂質量の表示
            HStack (spacing: 20){
                let PFCtuple2 = calcPFC2(calorie: inputCalorie, protein: inputProtein, fat: inputFat, carbo: inputCarbo)
                Text("脂質(F)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.fatg)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.fatc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
            
            // 摂取炭水化物量の表示
            HStack(spacing: 20){
                let PFCtuple2 = calcPFC2(calorie: inputCalorie, protein: inputProtein, fat: inputFat, carbo: inputCarbo)
                Text("炭水化物(C)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.carbog)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple2.carboc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
            
        }
    }
}

#Preview {
    GoalView()
}

//
//  CalView.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/12/07.
//  タブ名”計算”

import SwiftUI
import Combine

struct CalView: View {
    @State var selectJenderIndex = 0
    let selectJender = ["男性","女性"]
    
    @State var inputAge = ""
    @State var inputHeight = ""
    @State var inputWeight = ""
    let maxLength = 3

    @State var basalmetabolism = 0
    @State var usedcalorie = 0
     
    @State var selectListIndex = 0
    let selectList = [
                        "活動量が低い人\n    デスクワーク中心で座っていることが多く、\n   １日の運動は通勤・通学や近所のお買い物程度",
                        "活動量がやや低い人\n  １週間1に１,２回程度軽い運動や筋トレをする",
                        "活動量が標準の人\n  営業の外回りや肉体労働で一日中よく動いている\n  または１週間に２,３回程度の高い運動や筋トレをする",
                        "活動量が高い人\n  １週間に４,５回程度強度の高い運動や筋トレをする",
                        "活動量がかなり高い人\n  スポーツ選手・アスリート"]
    
    @State var inputPeriod = ""
    @State var inputDietweight = ""
    @State var consumedcalorie = 0
    
    @State var PFCtuple = (0,0,0,0,0,0)
    
    func calcCalorie(jen: String, age: String, height: String, weight: String) -> Int {
        if age == "" || height == "" || weight == "" {
            return 0
        }
        
        let ageDouble = changeDouble(age)
        let heightDouble = changeDouble(height)
        let weightDouble = changeDouble(weight)
        if jen == "男性" {
            return Int(round(((0.0481 * weightDouble) + (0.0234 * heightDouble) - (0.0138 * ageDouble) - 0.4235) * 1000 / 4.186))
        } else {
            return Int(round(((0.0481 * weightDouble) + (0.0234 * heightDouble) - (0.0138 * ageDouble) - 0.9708) * 1000 / 4.186))
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                // ラジオボタンの作成
                HStack {
                    Text("性別")
                    ForEach(0..<selectJender.count, id: \.self, content: { index in
                        Image(systemName: selectJenderIndex == index  ? "checkmark.circle.fill" : "circle")
                        Text(selectJender[index])
                            .frame(height: 40)
                            .onTapGesture {
                                selectJenderIndex = index
                            }
                    })
                }
                .padding(5)
                

                // 年齢の入力フィールド作成
                HStack(spacing: 20){
                    Text("年齢")
                        .frame(width: 100)
                        .foregroundColor(inputAge.isEmpty ? .primary : Color.blue)
                    TextField("歳", text: $inputAge)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .foregroundColor(.primary)
                        .onReceive(Just(inputAge)) { _ in
                            if inputAge.count > maxLength {
                                inputAge = String(inputAge.prefix(maxLength))
                            }
                        }
                }
                .frame(width: 200,alignment: .trailing)
                .padding(5)
                
                // 身長の入力フィールド作成
                HStack(spacing: 20){
                    Text("身長")
                        .frame(width: 100)
                        .foregroundColor(inputHeight.isEmpty ? .primary : Color.blue)
                    TextField("cm", text: $inputHeight)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .foregroundColor(.primary)
                        .onReceive(Just(inputHeight)) { _ in
                            if inputHeight.count > maxLength {
                                inputHeight = String(inputHeight.prefix(maxLength))
                            }
                        }
                }
                .frame(width: 200,alignment: .trailing)
                .padding(5)
                
                // 体重の入力フィールド作成
                HStack(spacing: 20){
                    Text("体重")
                        .frame(width: 100)
                        .foregroundColor(inputWeight.isEmpty ? .primary : Color.blue)
                    TextField("Kg", text: $inputWeight)
                        .frame(width: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(TextAlignment.trailing)
                        .foregroundColor(.primary)
                        .onReceive(Just(inputWeight)) { _ in
                            if inputWeight.count > maxLength {
                                inputWeight = String(inputWeight.prefix(maxLength))
                            }
                        }
                }
                .frame(width: 200,alignment: .trailing)
                .padding(5)
                
                // 基礎代謝を表示
                HStack {
                    Button {
                        basalmetabolism = calcCalorie(jen: selectJender[selectJenderIndex], age: inputAge, height: inputHeight, weight: inputWeight)
                    } label: {
                        Text("基礎代謝")
                            .frame(width: 125, height: 30)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    Text("\(basalmetabolism)")
                        .font(.title)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .foregroundColor(basalmetabolism == 0 ? .white : .orange)
                        .frame(width: 125,alignment: .trailing)
                    Text("Kcal")
                }
                .frame(width: 300, height: 60)
                .padding()
                
                // 活動量のフィールド作成
                ForEach(0..<selectList.count, id: \.self, content: { index in
                    ZStack {
                        if selectListIndex == index {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 360, height: 60)
                        } else {
                            Rectangle()
                                .stroke(Color.primary, lineWidth: 1)
                                .frame(width: 360, height: 60)
                        }
                        HStack {
                            if selectListIndex == index {
                                Image(systemName: "largecircle.fill.circle")
                                    .foregroundColor(.white)
                                    .frame(width: 50)
                                Text(selectList[index])
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        selectListIndex = index
                                    }
                                Spacer()
                            } else {
                                Image(systemName:"circle")
                                    .foregroundColor(.primary)
                                    .frame(width: 50)
                                Text(selectList[index])
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .onTapGesture {
                                        selectListIndex = index
                                    }
                                Spacer()
                            }
                        }
                        .frame(width: 360)
                    }
                })
                
                // 消費カロリーを表示
                HStack {
                    Button {
                        usedcalorie = calcusedcalorie(bm: Double(basalmetabolism), flg:  selectListIndex)
                    } label: {
                        Text("消費カロリー")
                            .frame(width: 125, height: 30)
                            .background(.orange)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    Text("\(usedcalorie)")
                        .font(.title)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .foregroundColor(usedcalorie == 0 ? .white : .orange)
                        .frame(width: 125,alignment: .trailing)
                    Text("Kcal")
                }
                .frame(width: 500, height: 60)
                .padding()
            }
            
            // 摂取カロリーの入力フィールド作成
            HStack {
                Text("私は")
                    .frame(width: 40)
                TextField("", text: $inputPeriod)
                    .frame(width: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputPeriod)) { _ in
                        if inputPeriod.count > 2 {
                            inputPeriod = String(inputPeriod.prefix(2))
                        }
                    }
                Text("ヶ月間で")
                    .frame(width: 80)
                TextField("", text: $inputDietweight)
                    .frame(width: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                    .onReceive(Just(inputDietweight)) { _ in
                        if inputDietweight.count > 2 {
                            inputDietweight = String(inputDietweight.prefix(2))
                        }
                    }
                Text("Kg痩せたい")
                    .frame(width: 100)
            }
            .padding(5)
            
            // 摂取カロリーを表示
            HStack {
                Button {
                    consumedcalorie = calcConsumedCalories(uc: usedcalorie, period: inputPeriod, dietweight: inputDietweight)
                } label: {
                    Text("摂取カロリー")
                        .frame(width: 125, height: 30)
                        .background(.orange)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Text("\(consumedcalorie)")
                    .font(.title)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .foregroundColor(consumedcalorie == 0 ? .white : .orange)
                    .frame(width: 125,alignment: .trailing)
                Text("Kcal")
            }
            .frame(width: 500, height: 60)
            Spacer()
            
            Text("<1日に摂るべきPFC>")
                .font(.title)
                .padding()
        
            // 摂取タンパク質量の表示
            HStack(spacing: 20){
                let PFCtuple = calcPFC(cc: Double(consumedcalorie))
                Text("たんぱく質(P)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.proteing)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.proteinc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
            
            // 摂取脂質量の表示
            HStack (spacing: 20){
                let PFCtuple = calcPFC(cc: Double(consumedcalorie))
                Text("脂質(F)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.fatg)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.fatc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
            
            // 摂取炭水化物量の表示
            HStack(spacing: 20){
                let PFCtuple = calcPFC(cc: Double(consumedcalorie))
                Text("炭水化物(F)")
                    .frame(width: 120)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.carbog)g")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
                Text("\(PFCtuple.carboc)kcal")
                    .frame(width: 100)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: 200)
            .padding(5)
                    
        }// Scrolの終わり
    }
    
    private func calcusedcalorie(bm: Double, flg: Int) -> Int {
        switch flg {
        case 0:
            return Int(round(bm * 1.2))
        case 1:
            return Int(round(bm * 1.375))
        case 2:
            return Int(round(bm * 1.55))
        case 3:
            return Int(round(bm * 1.725))
        default:
            return Int(round(bm * 1.9))
        }
    }
    
    private func calcConsumedCalories(uc: Int, period: String, dietweight: String) -> Int {
        if period == "" || dietweight == "" {
            return 0
        }
        
        let periodInt = changeInt(period)
        let dietweightInt = changeInt(dietweight)
        return uc - (dietweightInt * 7200 / (periodInt * 30))
    }
    
    private func calcPFC(cc: Double) -> (proteing: Int, proteinc: Int, fatg: Int, fatc: Int, carbog: Int, carboc: Int) {
        let proteing = Int(round((cc * 0.3 / 4)))
        let proteinc = proteing * 4
        let fatg = Int(round((cc * 0.2 / 9)))
        let fatc = fatg * 9
        let carbog = Int(round((cc * 0.5 / 4)))
        let carboc = carbog * 4
        return (proteing,proteinc,fatg,fatc,carbog,carboc)
    }
    
    private func changeInt(_ str:String) -> Int {
        guard let result = Int(str) else {
            return 0
        }
        return result
    }
    
    private func changeDouble(_ str:String) -> Double {
        guard let result = Double(str) else {
            return 0
        }
        return result
    }
    
}

#Preview {
 CalView()
}

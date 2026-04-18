//
//  RegistView.swift
//  fitness
//
//  Created by 鬼頭拓万 on 2023/12/07.
//  タブ名”管理”

import SwiftUI
import CoreData

struct RegistView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: []) //データ要求
    var foodsData: FetchedResults<Food>
    
    @State var inputfood = ""
    @State var inputcalorie = ""
    @State var inputprotein = ""
    @State var inputfat = ""
    @State var inputcarbo = ""
    @State var isShowAlert = false
    @State var messageflg = false
    
    private func resetForm() {
        inputfood = ""
        inputcalorie = ""
        inputprotein = ""
        inputfat = ""
        inputcarbo = ""
    }
    
    var body: some View {
        VStack {
            Text("台帳登録")
                .font(.title)
                .foregroundColor(.primary)
                .padding()
            
            HStack(spacing: 50) {
                Text("フード名")
                TextField("入力", text: $inputfood)
                    .frame(width: 150)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .padding(5)
            
            HStack(spacing: 100) {
                Text("カロリー")
                TextField("kcal", text: $inputcalorie)
                    .frame(width: 100)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .padding(5)
            
            HStack(spacing: 85) {
                Text("たんぱく質")
                TextField("g", text: $inputprotein)
                    .frame(width: 100)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .padding(5)
            
            HStack(spacing: 130) {
                Text("脂質")
                TextField("g", text: $inputfat)
                    .frame(width: 100)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .padding(5)
            
            HStack(spacing: 100) {
                Text("炭水化物")
                TextField("g", text: $inputcarbo)
                    .frame(width: 100)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.primary)
            }
            .padding(5)
            
            Button {
                if inputfood == "" || inputcalorie == "" || inputprotein == "" || inputfat == "" || inputcarbo == "" {
                    isShowAlert = true
                } else {
                   addfood()
                    messageflg = true
                    resetForm()
                }
            } label: {
                Text("登録")
                    .frame(width: 125, height: 30)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .alert("入力エラー", isPresented: $isShowAlert) {
                Button("OK") {
                }
            } message: {
                Text("入力漏れがあります")
            }
            
            .padding()
            
            if messageflg == true {
                Text("登録しました")
            }
        }
    }
    
    private func addfood() {
        let newFood = Food(context: viewContext)
        newFood.food_name = inputfood
        newFood.calorie_value = inputcalorie
        newFood.protein_value = inputprotein
        newFood.fat_value = inputfat
        newFood.carbo_value = inputcarbo
        
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

#Preview {
    RegistView()
}

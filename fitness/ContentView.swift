//
//  ContentView.swift
//  fitness aaa
//
//  Created by 鬼頭拓万 on 2023/11/23.
//  

import SwiftUI

struct ContentView: View {
    @State var selection = 1
    @FocusState var isActive:Bool
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView2()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(1)
                .focused($isActive)
            
            CalView()
                .tabItem {
                    Label("計算", systemImage: "pencil.and.scribble")
                }
                .tag(2)
                .focused($isActive)
            
            GoalView()
                .tabItem {
                    Label("目標", systemImage: "flag")
                }
                .tag(3)
                .focused($isActive)
            
            
            RecordView()
                .tabItem {
                    Label("登録", systemImage: "note.text")
                }
                .tag(4)
                .focused($isActive)
            
            RegistView()
                .tabItem {
                    Label("管理", systemImage: "cylinder.split.1x2")
                }
                .tag(5)
                .focused($isActive)
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("閉じる") {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
